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
                    style: AppTypography.text2.copyWith(
                      color: AnakraPalette.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              CustomPaint(
                painter: _MessageSurface(isUser: isUser),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isUser ? 14 : 19,
                    10,
                    isUser ? 19 : 14,
                    10,
                  ),
                  child: Text(
                    message.text,
                    style: AppTypography.text1.copyWith(
                      color: isUser
                          ? Colors.white
                          : AnakraPalette.backgroundDeep,
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

class _MessageSurface extends CustomPainter {
  const _MessageSurface({required this.isUser});
  final bool isUser;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = anakraBubblePath(
      size,
      isUser ? AnakraBubbleSide.outgoing : AnakraBubbleSide.incoming,
      21,
    );
    final base = isUser ? AnakraPalette.purpleDark : const Color(0xFFE7DDEE);
    canvas.drawShadow(
      shape,
      AnakraPalette.backgroundDeep.withValues(alpha: .38),
      2,
      false,
    );
    canvas.save();
    canvas.clipPath(shape);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(base, Colors.white, isUser ? .13 : .4)!,
          base,
          Color.lerp(base, AnakraPalette.backgroundDeep, isUser ? .19 : .12)!,
        ],
        stops: const [0, .50, 1],
      ).createShader(rect);
    canvas.drawPath(shape, paint);
    // A soft highlight follows the silhouette, keeping the reading area quiet.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x99FFFFFF), Color(0x11FFFFFF), Color(0x337F6294)],
      ).createShader(rect);
    canvas.drawPath(shape, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MessageSurface oldDelegate) =>
      oldDelegate.isUser != isUser;
}
