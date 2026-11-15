import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_pebble.dart';
import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';
import 'package:flutter/material.dart';

class NativeIntroAudio extends StatefulWidget {
  const NativeIntroAudio({super.key, required this.active});

  final bool active;

  @override
  State<NativeIntroAudio> createState() => _NativeIntroAudioState();
}

class _NativeIntroAudioState extends State<NativeIntroAudio> {
  PracticePlaybackController? _player;
  bool _pending = false;

  void _onPositionChanged() => setState(() {});

  Future<void> _toggle() async {
    if (!widget.active || _pending) return;
    _pending = true;
    final player = _player ??= (PracticePlaybackController()
      ..addListener(_onPositionChanged));
    try {
      await player.toggle();
    } catch (_) {
      if (mounted && widget.active && identical(_player, player)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.introAudioError)));
      }
    } finally {
      if (identical(_player, player)) _pending = false;
    }
  }

  void _release() {
    _player?.removeListener(_onPositionChanged);
    _player?.dispose();
    _player = null;
    _pending = false;
  }

  @override
  void didUpdateWidget(NativeIntroAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active && oldWidget.active) _release();
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AsteriaCardRadii.card));
    final playing = _player?.isPlaying ?? false;
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: const CardLensDecoration(borderRadius: radius),
        child: LayoutBuilder(
          builder: (context, bounds) {
            final compact = bounds.maxHeight < 310;
            return Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: PlayerArtwork(
                    position: _player?.position ?? Duration.zero,
                    duration: _player?.duration ?? const Duration(seconds: 75),
                    playing: playing,
                  ),
                ),
                Align(
                  alignment: compact
                      ? Alignment.bottomLeft
                      : Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: PlayerPebble(
                      primary: true,
                      compact: compact,
                      glyph: playing ? ClayGlyph.pause : ClayGlyph.play,
                      label: playing
                          ? context.l10n.introPause
                          : context.l10n.introPlay,
                      onTap: _toggle,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
