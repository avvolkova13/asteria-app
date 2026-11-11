import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextInputFieldState { defaultState, active, typing, typed, error, toggle }

class TextInputFieldWidget extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final TextInputFieldState state;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onToggle;
  final bool showClearButton;
  final bool showToggleButton;
  final bool toggleValue;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const TextInputFieldWidget({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.state = TextInputFieldState.defaultState,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.onClear,
    this.onToggle,
    this.showClearButton = true,
    this.showToggleButton = false,
    this.toggleValue = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  State<TextInputFieldWidget> createState() => _TextInputFieldWidgetState();
}

class _TextInputFieldWidgetState extends State<TextInputFieldWidget> {
  late TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Color _getBorderColor() {
    switch (widget.state) {
      case TextInputFieldState.error:
        return const Color(0xFFDB4C4C);
      case TextInputFieldState.active:
      case TextInputFieldState.typing:
        return const Color(0xFF9747FF);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getBorderColor(), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onTap: LotusFeedback.selection,
                    inputFormatters: widget.inputFormatters,
                    controller: _controller,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    obscureText: _obscureText,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: context.textTheme.inputText,
                    cursorColor: AppColors.textPrimary,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: context.textTheme.inputHint,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              if (widget.showToggleButton) ...[
                LotusTap(
                  onTap: widget.onToggle,
                  child: Container(
                    width: 51,
                    height: 31,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: widget.toggleValue
                          ? const Color(0xFF8A6CAF)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(15.5),
                    ),
                    child: AnimatedAlign(
                      alignment: widget.toggleValue
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 27,
                        height: 27,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(13.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (widget.showClearButton &&
                  _controller.text.isNotEmpty) ...[
                LotusTap(
                  onTap: () {
                    _controller.clear();
                    widget.onClear?.call();
                    widget.onChanged?.call('');
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 16),
                    child: ClayAssetIcon(
                      'assets/icons/close_icon.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.errorText != null &&
            widget.state == TextInputFieldState.error) ...[
          const SizedBox(height: 8),
          Text(widget.errorText!, style: context.textTheme.inputErrorText),
        ],
      ],
    );
  }
}
