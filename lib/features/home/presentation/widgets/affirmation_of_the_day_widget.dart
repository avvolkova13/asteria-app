import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_pebble.dart';
import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';
import 'package:flutter/material.dart';

class AffirmationOfTheDayWidget extends StatefulWidget {
  const AffirmationOfTheDayWidget({
    super.key,
    required this.onOpenCollection,
    this.onPlay,
  });

  final Future<void> Function() onOpenCollection;
  final VoidCallback? onPlay;

  @override
  State<AffirmationOfTheDayWidget> createState() => _AffirmationOfTheDayState();
}

class _AffirmationOfTheDayState extends State<AffirmationOfTheDayWidget> {
  PracticePlaybackController? _player;
  Duration _resumeAt = Duration.zero;
  bool _visible = false;
  bool _opening = false;
  bool _commandPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.isCurrentOf(context) ?? true;
    _visible = current && TickerMode.valuesOf(context).enabled;
    if (!_visible) _release();
  }

  void _release() {
    final player = _player;
    if (player == null) return;
    _resumeAt = player.isComplete ? Duration.zero : player.position;
    player.removeListener(_sync);
    player.dispose();
    _player = null;
  }

  void _sync() => setState(() {});

  Future<void> _toggle() async {
    if (_commandPending || !_visible) return;
    _commandPending = true;
    final fresh = _player == null;
    final player = _player ??= (PracticePlaybackController()
      ..addListener(_sync));
    final starting = !player.isPlaying;
    try {
      if (fresh && _resumeAt > Duration.zero) await player.seek(_resumeAt);
      await player.toggle();
      if (identical(_player, player) && starting && player.isPlaying) {
        widget.onPlay?.call();
      }
    } catch (_) {
      if (mounted && _visible) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.playerPlayError)));
      }
    } finally {
      _commandPending = false;
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  Future<void> _openCollection() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await widget.onOpenCollection();
    } catch (_) {
      if (mounted && _visible) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.affirmationLoadError)),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    final playing = player?.isPlaying ?? false;
    final strings = context.l10n;
    const linkColor = Color(0xFF6330A0);
    const radius = BorderRadius.all(Radius.circular(AsteriaCardRadii.card));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: CardLensDecoration(borderRadius: radius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: ExcludeFocus(
                    child: LotusTap(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggle,
                      child: RepaintBoundary(
                        child: PlayerArtwork(
                          position: player?.position ?? _resumeAt,
                          duration:
                              player?.duration ?? const Duration(seconds: 75),
                          playing: playing,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x80291B36),
                          Color(0x70291B36),
                          Color(0x00291B36),
                          Color(0x00291B36),
                          Color(0x80F3E4F8),
                          Color(0xE6F3E4F8),
                        ],
                        stops: [0, .16, .42, .58, .84, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IgnorePointer(
                      child: Text(
                        strings.affirmationOfDay,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textInverse,
                          shadows: const [
                            Shadow(color: Color(0x88402A55), blurRadius: 5),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 94),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PlayerPebble(
                          primary: true,
                          compact: true,
                          glyph: playing ? ClayGlyph.pause : ClayGlyph.play,
                          label: playing
                              ? strings.playerPause
                              : player?.isComplete == true
                              ? strings.playerReplay
                              : strings.playerPlay,
                          onTap: _toggle,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: LotusButtons.text(
                              onPressed: _openCollection,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(44, 44),
                                visualDensity: VisualDensity.standard,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.bottomRight,
                                foregroundColor: linkColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: _opening
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      strings.allAffirmations,
                                      textAlign: TextAlign.end,
                                      style: AppTypography.link.copyWith(
                                        color: linkColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
