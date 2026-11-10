import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'anakra_glass_surface.dart';
import 'anakra_layout.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnakraComposer extends StatelessWidget {
  const AnakraComposer({
    super.key,
    required this.controller,
    required this.busy,
    required this.hasInput,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool busy;
  final bool hasInput;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final enabled = !busy && hasInput;
    final style = TextStyle(
      fontFamily: defaultTargetPlatform == TargetPlatform.iOS
          ? '.SF Pro Text'
          : 'Onest',
      fontSize: 17,
      height: 22 / 17,
      letterSpacing: 0,
      color: const Color(0xFFF5F5F5),
    );
    return Row(
      children: [
        Expanded(
          child: AnakraGlassSurface(
            shadow: true,
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: controller,
                enabled: !busy,
                style: style,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.white,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (enabled) onSend();
                },
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  hintText: context.l10n.anakraInputHint,
                  hintStyle: style.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  suffixIcon: hasInput
                      ? LotusButtons.icon(
                          tooltip: context.l10n.clearMessage,
                          onPressed: busy ? null : controller.clear,
                          padding: EdgeInsets.zero,
                          icon: ClayIcon(
                            Icons.cancel,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 44,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnakraGlassSurface(
          shadow: true,
          child: SizedBox(
            width: 48,
            height: 48,
            child: LotusButtons.icon(
              tooltip: context.l10n.anakraSendMessageLabel,
              onPressed: enabled ? onSend : null,
              padding: EdgeInsets.zero,
              icon: Opacity(
                opacity: enabled ? 1 : 0.4,
                child: LotusRasterIcon(
                  AnakraAssets.send,
                  width: 25.41,
                  height: 25.41,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
