import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:asteria_app/features/auth/presentation/email_auth_failure_localization.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailLoginScreen extends StatefulWidget {
  final bool deleteAfterVerification;
  final bool isRoot;
  final String? expectedUid;
  final String? expectedEmail;
  final VoidCallback? onAuthStarted;

  const EmailLoginScreen({
    super.key,
    this.deleteAfterVerification = false,
    this.isRoot = false,
    this.expectedUid,
    this.expectedEmail,
    this.onAuthStarted,
  });

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _showValidationError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.expectedEmail ?? '');
    if (widget.isRoot) {
      final callback = widget.onAuthStarted;
      if (callback != null) {
        callback();
      } else {
        di.get<AnalyticsFacade>().trackEvent(AnalyticsEvents.authStarted);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final cubit = context.read<EmailAuthCubit>();
    final email = _controller.text;
    final valid = EmailAuthCubit.isValidEmail(email);
    setState(() => _showValidationError = !valid);
    if (!valid) return;

    await cubit.requestCode(email, expectedEmail: widget.expectedEmail);
    if (!mounted || cubit.state is! EmailAuthCodeSent) return;
    AuthEmailCodeRoute.push(
      context,
      cubit: cubit,
      deleteAfterVerification: widget.deleteAfterVerification,
      expectedUid: widget.expectedUid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFlowScaffold(
      showBackButton: !widget.isRoot,
      backgroundOpacity: 0.38,
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
                    child: BlocBuilder<EmailAuthCubit, EmailAuthState>(
                      builder: (context, state) {
                        final isLoading = state is EmailAuthRequesting;
                        final apiError = state is EmailAuthFailure
                            ? localizedEmailAuthFailure(context, state.code)
                            : null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isCompact ? 58 : 68),
                            Text(
                              l10n.emailAuthTitle,
                              style: context.textTheme.inversePlayfairSemiBold24
                                  .copyWith(height: 1.24),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.emailAuthMessage,
                              style: context.textTheme.inverseUrbanistRegular16
                                  .copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.68,
                                    ),
                                    fontSize: 17,
                                    height: 1.2,
                                  ),
                            ),
                            SizedBox(height: isCompact ? 24 : 36),
                            AuthTextInput(
                              controller: _controller,
                              focusNode: _focusNode,
                              hintText: l10n.emailHint,
                              isError: _showValidationError || apiError != null,
                              errorText: _showValidationError
                                  ? l10n.emailInvalidError
                                  : apiError,
                              inputFormatters: const [],
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              readOnly: widget.expectedEmail != null,
                              onChanged: (_) {
                                if (_showValidationError || apiError != null) {
                                  setState(() => _showValidationError = false);
                                  context.read<EmailAuthCubit>().clearError();
                                }
                              },
                              onSubmitted: (_) => _requestCode(),
                            ),
                            const SizedBox(height: 16),
                            AuthGradientButton(
                              text: l10n.getCodeText,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _requestCode,
                            ),
                            if (widget.isRoot) ...[
                              const SizedBox(height: 12),
                              const _LoginPolicyText(),
                            ],
                            const Spacer(),
                            if (!widget.isRoot && widget.expectedEmail == null)
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

class _LoginPolicyText extends StatefulWidget {
  const _LoginPolicyText();

  @override
  State<_LoginPolicyText> createState() => _LoginPolicyTextState();
}

class _LoginPolicyTextState extends State<_LoginPolicyText> {
  late final TapGestureRecognizer _agreementRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _agreementRecognizer = TapGestureRecognizer();
    _privacyRecognizer = TapGestureRecognizer();
  }

  @override
  void dispose() {
    _agreementRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _agreementRecognizer.onTap = () => AboutUsRoute.push(
      context,
      params: const AboutUsRouteParams(document: LegalDocumentType.agreement),
    );
    _privacyRecognizer.onTap = () => AboutUsRoute.push(
      context,
      params: const AboutUsRouteParams(document: LegalDocumentType.privacy),
    );

    final baseStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      color: AppColors.white.withValues(alpha: 0.58),
      fontSize: 12,
      height: 1.32,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.white.withValues(alpha: 0.76),
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${context.l10n.emailAuthConsentPrefix} ',
            style: baseStyle,
          ),
          TextSpan(
            text: context.l10n.agreementText,
            style: linkStyle,
            recognizer: _agreementRecognizer,
          ),
          TextSpan(
            text: ' ${context.l10n.legalTermsConnector} ',
            style: baseStyle,
          ),
          TextSpan(
            text: context.l10n.policyText,
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
        ],
      ),
    );
  }
}
