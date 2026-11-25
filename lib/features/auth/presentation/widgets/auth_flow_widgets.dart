import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _authBackgroundAsset = 'assets/images/auth/auth_flow_background.webp';
const _authBackdrop = Color(0xFF0F0A1A);
const _authBackgroundHeightFactor = 780 / 844;
const _authGoldStart = Color(0xFFE6994D);
const _authGoldMiddle = Color(0xFFF3B76A);
const _authGoldEnd = Color(0xFFE6994D);

const authGoldGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [_authGoldStart, _authGoldMiddle, _authGoldEnd],
  stops: [0, 0.5, 1],
);

/// A still from the splash silk, framed against the full window so focusing
/// a field does not scale or move the fold behind the form.
class AuthSilkBackground extends StatelessWidget {
  const AuthSilkBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return IgnorePointer(
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: height,
          maxHeight: height,
          child: Image.asset(
            'assets/images/auth/auth_silk.webp',
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

class AuthFlowScaffold extends StatelessWidget {
  final Widget child;
  final Widget? background;
  final bool showBackButton;
  final bool resizeToAvoidBottomInset;
  final String backgroundAsset;
  final double backgroundOpacity;
  final double backgroundHeightFactor;
  final double maxContentWidth;
  final double? tabletFormHeight;

  const AuthFlowScaffold({
    super.key,
    required this.child,
    this.background,
    this.showBackButton = false,
    this.resizeToAvoidBottomInset = true,
    this.maxContentWidth = 580,
    this.tabletFormHeight,
    this.backgroundAsset = _authBackgroundAsset,
    this.backgroundOpacity = 0.5,
    this.backgroundHeightFactor = _authBackgroundHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final tabletForm =
        tabletFormHeight != null &&
        MediaQuery.sizeOf(context).shortestSide >= 600;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _authBackdrop,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null)
              background!
            else ...[
              ColoredBox(
                color: _authBackdrop,
                child: Opacity(
                  opacity: backgroundOpacity,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: backgroundHeightFactor,
                    alignment: Alignment.center,
                    child: Image.asset(
                      backgroundAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: _AuthTopGradient(),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: _AuthBottomGradient(),
              ),
            ],
            Align(
              alignment: tabletForm
                  ? const Alignment(0, -.24)
                  : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: tabletForm ? 660 : maxContentWidth,
                  maxHeight: tabletForm ? tabletFormHeight! : double.infinity,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: child,
                ),
              ),
            ),
            if (showBackButton)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: LotusButtons.icon(
                      onPressed: () => Navigator.pop(context),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      icon: const LotusArrowBubble(back: true),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthTopGradient extends StatelessWidget {
  const _AuthTopGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _authBackdrop,
              _authBackdrop,
              _authBackdrop.withValues(alpha: 0),
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
      ),
    );
  }
}

class _AuthBottomGradient extends StatelessWidget {
  const _AuthBottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 123,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              _authBackdrop,
              _authBackdrop.withValues(alpha: 0.95),
              _authBackdrop.withValues(alpha: 0),
            ],
            stops: const [0, 0.2, 1],
          ),
        ),
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => AsteriaActionButton(
    text: text,
    onPressed: onPressed,
    isLoading: isLoading,
    width: double.infinity,
  );
}

class AuthTextInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final String? errorText;
  final bool isError;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  final bool readOnly;

  const AuthTextInput({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.isError,
    required this.onChanged,
    required this.onSubmitted,
    required this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
    this.readOnly = false,
    this.errorText,
  });

  @override
  State<AuthTextInput> createState() => _AuthTextInputState();
}

class _AuthTextInputState extends State<AuthTextInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(AuthTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputBubbleSurface(
          surfaceBrightness: Brightness.dark,
          enabled: !widget.readOnly,
          hasError: widget.isError,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onTap: LotusFeedback.selection,
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    inputFormatters: widget.inputFormatters,
                    keyboardType: widget.keyboardType,
                    autofillHints: widget.autofillHints,
                    readOnly: widget.readOnly,
                    autocorrect: false,
                    enableSuggestions:
                        widget.keyboardType != TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: AppTypography.placeholder.copyWith(
                      color: AppColors.white,
                    ),
                    cursorColor: AppColors.white,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTypography.placeholder.copyWith(
                        color: AppColorsDark.textSecondary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty && !widget.readOnly)
                  LotusButtons.icon(
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    tooltip: context.l10n.commonClear,
                    icon: const ClayIcon(
                      CupertinoIcons.clear_circled_solid,
                      color: AppColorsDark.textSecondary,
                      size: 20,
                    ),
                    padding: const EdgeInsets.only(right: 14),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.isError && widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: context.textTheme.urbanistRegular12.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthGoldenText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  const AuthGoldenText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => authGoldGradient.createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: AppColors.white),
      ),
    );
  }
}

class AuthBottomLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const AuthBottomLink({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.link.copyWith(
          color: AppColors.white.withValues(alpha: 0.82),
          decorationColor: AppColors.white.withValues(alpha: 0.66),
          decorationThickness: 1,
        ),
      ),
    );

    return Center(
      child: onTap == null
          ? textWidget
          : LotusFeedback(
              onActivate: onTap,
              keyboard: true,
              builder: (activate) => Semantics(
                button: true,
                label: text,
                onTap: activate,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: activate,
                    child: textWidget,
                  ),
                ),
              ),
            ),
    );
  }
}
