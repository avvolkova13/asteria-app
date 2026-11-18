import 'dart:async';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_pebble.dart';
import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

class NativeIntroAudio extends StatefulWidget {
  const NativeIntroAudio({
    super.key,
    required this.active,
    this.showControls = true,
    this.autoPlay = false,
  });

  final bool active;
  final bool showControls;
  final bool autoPlay;

  @override
  State<NativeIntroAudio> createState() => _NativeIntroAudioState();
}

class _NativeIntroAudioState extends State<NativeIntroAudio> {
  PracticePlaybackController? _player;
  bool _pending = false;
  bool _autoStarted = false;
  bool _resumeWithStory = false;
  IntroPlaybackController? _story;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final story = IntroPlaybackScope.maybeOf(context);
    if (story != _story) {
      _story?.removeListener(_syncStoryPause);
      _story = story;
      _story?.addListener(_syncStoryPause);
    }
    _scheduleAutoPlay();
  }

  void _scheduleAutoPlay() {
    if (!widget.active || !widget.autoPlay || _autoStarted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active || _autoStarted) return;
      if (_story?.mode == IntroPlaybackMode.resume) return;
      _autoStarted = true;
      unawaited(_toggle());
    });
  }

  void _syncStoryPause() {
    if (!mounted || !widget.active || _pending) return;
    final playing = _player?.isPlaying ?? false;
    if (_story?.mode == IntroPlaybackMode.resume && playing) {
      _resumeWithStory = true;
      unawaited(_toggle());
    } else if (_story?.mode == IntroPlaybackMode.pause) {
      if (_resumeWithStory && !playing) {
        _resumeWithStory = false;
        unawaited(_toggle());
      } else {
        _scheduleAutoPlay();
      }
    }
  }

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
      if (identical(_player, player)) {
        _pending = false;
        _syncStoryPause();
      }
    }
  }

  void _release() {
    _player?.removeListener(_onPositionChanged);
    _player?.dispose();
    _player = null;
    _pending = false;
    _autoStarted = false;
    _resumeWithStory = false;
  }

  @override
  void didUpdateWidget(NativeIntroAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active && oldWidget.active) _release();
    _scheduleAutoPlay();
  }

  @override
  void dispose() {
    _story?.removeListener(_syncStoryPause);
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
                if (widget.showControls)
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
