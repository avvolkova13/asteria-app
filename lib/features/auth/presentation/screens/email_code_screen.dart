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

class EmailCodeScreen extends StatelessWidget {
  final bool deleteAfterVerification;
  final String? expectedUid;

  const EmailCodeScreen({
    super.key,
    this.deleteAfterVerification = false,
    this.expectedUid,
  });

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
                        if (deleteAfterVerification) {
                          final uid = state.identity.userId;
                          if (uid != expectedUid) return;
                          await di.get<UserRepository>().deleteUser(uid);
                          await di
                              .get<AuthSessionService>()
                              .deleteCurrentIdentity();
                          await di.get<UserProvider>().clearUser();
                          if (context.mounted) AuthLoginRoute.go(context);
                          return;
                        }
                        if (state.profileExists) {
                          HomeRoute.go(context);
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
                        final isLoading = state is EmailAuthVerifying;
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
                          children: [
                            SizedBox(height: isCompact ? 58 : 68),
                            Text(
                              l10n.emailCodeSentText,
                              style:
                                  context.textTheme.inversePlayfairSemiBold24,
                            ),
                            const SizedBox(height: 4),
                            AuthGoldenText(
                              text: email,
                              style:
                                  context.textTheme.inversePlayfairSemiBold24,
                            ),
                            const SizedBox(height: 24),
                            CodeInputWidget(
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
                                    expectedUid: expectedUid,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            if (remaining == 0)
                              AuthGradientButton(
                                text: l10n.resendCodeButtonText,
                                isLoading: isResending,
                                onPressed: isResending
                                    ? null
                                    : cubit.resendCode,
                              )
                            else
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
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 18),
                          ],
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
