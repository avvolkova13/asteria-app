import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_glass_surface.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:flutter/material.dart';

class AnakraChatMessage extends StatelessWidget {
  const AnakraChatMessage({super.key, required this.message});
  final AnakraChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final width = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: isUser ? 16 : 11, right: 16, bottom: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width * (isUser ? 280 / 390 : 310 / 390),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    context.l10n.anakraName,
                    style: const TextStyle(
                      fontFamily: 'Onest',
                      fontSize: 13,
                      height: 1.2,
                      letterSpacing: 0,
                      color: AnakraPalette.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              AnakraGlassSurface(
                side: isUser
                    ? AnakraBubbleSide.outgoing
                    : AnakraBubbleSide.incoming,
                radius: 16,
                light: 0.8,
                tint: isUser
                    ? const Color(0x335B3FD2)
                    : const Color(0x331B1433),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isUser ? 12 : 17,
                    6,
                    isUser ? 17 : 12,
                    6,
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      fontFamily: 'Onest',
                      fontSize: 17,
                      height: 1.2,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
