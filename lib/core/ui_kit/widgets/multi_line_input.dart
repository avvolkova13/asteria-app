import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MultiLineInputState { defaultState, active, typing, typed, error }

class MultiLineInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final MultiLineInputState state;
  final TextEditingController? controller;
  final int minLines;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const MultiLineInput({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.state = MultiLineInputState.defaultState,
    this.controller,
    this.minLines = 5,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  State<MultiLineInput> createState() => _MultiLineInputState();
}

class _MultiLineInputState extends State<MultiLineInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textInverse
        : AppColors.textPrimary;
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
        InputBubbleSurface(
          focused:
              widget.state == MultiLineInputState.active ||
              widget.state == MultiLineInputState.typing,
          hasError: widget.state == MultiLineInputState.error,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onTap: LotusFeedback.selection,
              inputFormatters: widget.inputFormatters,
              controller: _controller,
              keyboardType: TextInputType.multiline,
              minLines: widget.minLines,
              maxLines: null,
              onChanged: widget.onChanged,
              style: AppTypography.text1.copyWith(color: foreground),
              cursorColor: foreground,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTypography.placeholder.copyWith(
                  color: foreground.withValues(alpha: .65),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        if (widget.errorText != null &&
            widget.state == MultiLineInputState.error) ...[
          const SizedBox(height: 8),
          Text(widget.errorText!, style: context.textTheme.inputErrorText),
        ],
      ],
    );
  }
}
