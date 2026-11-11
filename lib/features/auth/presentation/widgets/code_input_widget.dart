import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeInputWidget extends StatefulWidget {
  final Function(String) onCodeEntered;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onErrorCleared;
  final int? clearTrigger;
  final int codeLength;

  const CodeInputWidget({
    super.key,
    required this.onCodeEntered,
    this.isError = false,
    this.errorMessage,
    this.onErrorCleared,
    this.clearTrigger,
    this.codeLength = 4,
  });

  @override
  State<CodeInputWidget> createState() => _CodeInputWidgetState();
}

class _CodeInputWidgetState extends State<CodeInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _previousCodeLength = 0;

  @override
  void didUpdateWidget(CodeInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clearTrigger != null &&
        widget.clearTrigger != oldWidget.clearTrigger) {
      Future.microtask(() {
        if (mounted) {
          clearCode();
        }
      });
    }
  }

  void clearCode() {
    _controller.clear();
    _previousCodeLength = 0;
    _focusNode.requestFocus();
    widget.onCodeEntered('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    if (value.length < _previousCodeLength && widget.isError) {
      widget.onErrorCleared?.call();
    }
    _previousCodeLength = value.length;
    setState(() {});
    widget.onCodeEntered(value);
  }

  @override
  Widget build(BuildContext context) {
    final boxWidth = widget.codeLength > 4 ? 40.0 : 50.0;
    final spacing = widget.codeLength > 4 ? 8.0 : 12.0;
    final totalWidth =
        boxWidth * widget.codeLength + spacing * (widget.codeLength - 1);
    return AutofillGroup(
      child: Column(
        children: [
          LotusTap(
            onTap: () => _focusNode.requestFocus(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExcludeSemantics(
                  child: ListenableBuilder(
                    listenable: _focusNode,
                    builder: (context, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.codeLength, (index) {
                        final digit = _controller.text.length > index
                            ? _controller.text[index]
                            : '';
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == widget.codeLength - 1 ? 0 : spacing,
                          ),
                          child: SizedBox(
                            width: boxWidth,
                            height: 50,
                            child: InputBubbleSurface(
                              surfaceBrightness: Brightness.dark,
                              borderRadius: BorderRadius.circular(14),
                              hasError: widget.isError,
                              focused:
                                  _focusNode.hasFocus &&
                                  index == _controller.text.length,
                              child: Center(
                                child: Text(
                                  digit,
                                  style: context
                                      .textTheme
                                      .inverseUrbanistSemiBold20
                                      .copyWith(color: AppColors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Positioned(
                  width: totalWidth,
                  height: 50,
                  child: ClipRect(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(widget.codeLength),
                        ],
                        maxLength: widget.codeLength,
                        showCursor: false,
                        cursorColor: Colors.transparent,
                        enableInteractiveSelection: false,
                        style: const TextStyle(
                          color: Colors.transparent,
                          fontSize: 1,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          filled: false,
                        ),
                        onChanged: _onCodeChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isError && widget.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.errorMessage!,
              style: context.textTheme.urbanistRegular12.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
