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
                      color: AppColors.textInverse,
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
    final tint = isUser
        ? Color.lerp(AnakraPalette.purple, Colors.white, .42)!
        : Colors.white;
    canvas.drawShadow(
      shape,
      AnakraPalette.backgroundDeep.withValues(alpha: .28),
      3,
      false,
    );
    canvas.save();
    canvas.clipPath(shape);
    void fill(Gradient gradient) =>
        canvas.drawPath(shape, Paint()..shader = gradient.createShader(rect));
    fill(
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tint.withValues(alpha: isUser ? .48 : .25),
          tint.withValues(alpha: isUser ? .31 : .13),
          tint.withValues(alpha: isUser ? .39 : .20),
        ],
        stops: const [0, .55, 1],
      ),
    );
    fill(
      RadialGradient(
        center: const Alignment(-.8, -1),
        radius: 1.2,
        colors: [
          Colors.white.withValues(alpha: .18),
          Colors.white.withValues(alpha: 0),
        ],
      ),
    );
    fill(
      RadialGradient(
        center: const Alignment(.85, 1),
        radius: .9,
        colors: [tint.withValues(alpha: .15), tint.withValues(alpha: 0)],
      ),
    );
    // A broad inner lip gives the translucent body a softly rounded edge.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: .56),
          tint.withValues(alpha: .08),
          tint.withValues(alpha: .34),
        ],
        stops: const [0, .55, 1],
      ).createShader(rect);
    canvas.drawPath(shape, rim);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .75
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: .52),
            Colors.white.withValues(alpha: .07),
            Colors.white.withValues(alpha: .27),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MessageSurface oldDelegate) =>
      oldDelegate.isUser != isUser;
}
