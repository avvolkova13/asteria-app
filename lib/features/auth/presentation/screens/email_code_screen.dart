import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/scenarios/first_session.dart';
import 'package:go_router/go_router.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:asteria_app/features/auth/presentation/email_auth_failure_localization.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/auth/presentation/widgets/code_input_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailCodeScreen extends StatefulWidget {
  final bool deleteAfterVerification;
  final String? expectedUid;

  const EmailCodeScreen({
    super.key,
    this.deleteAfterVerification = false,
    this.expectedUid,
  });

  @override
  State<EmailCodeScreen> createState() => _EmailCodeScreenState();
}

class _EmailCodeScreenState extends State<EmailCodeScreen> {
  bool _isDeleting = false;
  bool _deleteFailed = false;
  bool _profileDeleted = false;
  String? _verifiedUid;

  Future<void> _deleteAccount() async {
    final uid = _verifiedUid;
    if (_isDeleting || uid == null || uid != widget.expectedUid) return;
    setState(() {
      _isDeleting = true;
      _deleteFailed = false;
    });
    try {
      if (!_profileDeleted) {
        await di.get<UserRepository>().deleteUser(uid);
        _profileDeleted = true;
      }
      await di.get<AuthSessionService>().deleteCurrentIdentity();
      await di.get<UserProvider>().clearUser();
      if (mounted) AuthLoginRoute.go(context);
    } catch (_) {
      if (mounted) setState(() => _deleteFailed = true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFlowScaffold(
      showBackButton: true,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 720;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocConsumer<EmailAuthCubit, EmailAuthState>(
                      listener: (context, state) async {
                        if (state is! EmailAuthVerified) return;
                        if (widget.deleteAfterVerification) {
                          if (state.identity.userId != widget.expectedUid) {
                            return;
                          }
                          _verifiedUid = state.identity.userId;
                          await _deleteAccount();
                          return;
                        }
                        if (state.profileExists) {
                          context.go(
                            FirstSession.pending(state.identity.userId)
                                ? FirstSession.path
                                : HomeRoute.routeName,
                          );
                        } else {
                          AuthPersonalInfoRoute.pushReplacement(
                            context,
                            identity: state.identity,
                          );
                        }
                      },
                      builder: (context, state) {
                        final cubit = context.read<EmailAuthCubit>();
                        final email = cubit.currentEmail ?? '';
                        final isLoading =
                            state is EmailAuthVerifying || _isDeleting;
                        final isResending = state is EmailAuthRequesting;
                        final error = state is EmailAuthFailure
                            ? localizedEmailAuthFailure(context, state.code)
                            : null;
                        final remaining = switch (state) {
                          EmailAuthCodeSent value => value.remainingSeconds,
                          EmailAuthVerifying value => value.remainingSeconds,
                          EmailAuthFailure value => value.remainingSeconds,
                          _ => cubit.remainingSeconds,
                        };
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AsteriaEntrance.sections([
                            SizedBox(height: isCompact ? 58 : 68),
                            Text(
                              l10n.emailCodeSentText,
                              style:
                                  context.textTheme.inversePlayfairSemiBold24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              softWrap: true,
                              style: context.textTheme.inverseUrbanistRegular16
                                  .copyWith(color: AppColorsDark.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            if (_deleteFailed)
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  l10n.emailUnknownError,
                                  style: context
                                      .textTheme
                                      .inverseUrbanistRegular16,
                                ),
                              ),
                            if (_verifiedUid != null)
                              AuthGradientButton(
                                text: l10n.retry,
                                isLoading: _isDeleting,
                                onPressed: _deleteFailed
                                    ? _deleteAccount
                                    : null,
                              )
                            else
                              ExcludeFocus(
                                excluding: isLoading || isResending,
                                child: IgnorePointer(
                                  ignoring: isLoading || isResending,
                                  child: CodeInputWidget(
                                    codeLength: 6,
                                    isError: error != null,
                                    errorMessage: error,
                                    clearTrigger: cubit.challengeVersion,
                                    onErrorCleared: cubit.clearError,
                                    onCodeEntered: (code) {
                                      if (code.length == 6 &&
                                          !isLoading &&
                                          !isResending) {
                                        cubit.verifyCode(
                                          code,
                                          expectedUid: widget.expectedUid,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            if (isLoading)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Row(
                                    children: [
                                      const ExcludeSemantics(
                                        child: AsteriaActivityIndicator(
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          l10n.loading,
                                          style: context
                                              .textTheme
                                              .inverseUrbanistRegular16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            if (_verifiedUid == null && remaining == 0)
                              AuthGradientButton(
                                text: l10n.resendCodeButtonText,
                                isLoading: isResending,
                                onPressed: isResending || isLoading
                                    ? null
                                    : cubit.resendCode,
                              )
                            else if (_verifiedUid == null)
                              Text(
                                '${l10n.resendCodeText} ${_formatTime(remaining)}',
                                style: context
                                    .textTheme
                                    .inverseUrbanistRegular16
                                    .copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                              ),
                            const Spacer(),
                            AuthBottomLink(
                              text: l10n.emailAccessIssueText,
                              onTap: _isDeleting
                                  ? null
                                  : () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 18),
                          ]),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
