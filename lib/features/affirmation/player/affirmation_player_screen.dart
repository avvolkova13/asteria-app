import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_glyph_motion.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import 'player_artwork.dart';
import 'player_pebble.dart';
import 'practice_link.dart';
import 'practice_playback_controller.dart';

const _ink = Color(0xfff7f1fb);
const _headerInk = Color(0xfffff6fe);
const _recordingTitle = 'У меня есть время';
const _favoriteKey = 'time';
const _transcript = [
  (1.2, 'Я чувствую опору под ногами.'),
  (8.0, 'Делаю выдох.'),
  (12.6, 'Я замечаю, как опускаются плечи.'),
  (19.6, 'Воздух входит и выходит сам.'),
  (26.1, 'Ещё один вдох я оставляю только для себя.'),
  (35.0, 'Мне не нужно решать всё сразу.'),
  (42.4, 'Я выбираю одно небольшое дело.'),
  (49.1, 'Остальное немного подождёт.'),
  (55.2, 'Я начну, когда почувствую, что готова.'),
  (63.0, 'И дальше пойду в своём темпе.'),
  (70.2, 'У меня есть время.'),
];

String _formatTime(Duration time) =>
    '${time.inMinutes}:${(time.inSeconds % 60).toString().padLeft(2, '0')}';

class AffirmationPlayerScreen extends StatefulWidget {
  const AffirmationPlayerScreen({
    super.key,
    this.controller,
    this.showBack = false,
    this.autoPlay = false,
    this.onCompleted,
  });

  final bool showBack;
  final bool autoPlay;

  /// Called once after playback finishes naturally, never after a seek or loop.
  final VoidCallback? onCompleted;

  /// An injected controller belongs to its caller.
  final PracticePlaybackController? controller;

  @override
  State<AffirmationPlayerScreen> createState() =>
      _AffirmationPlayerScreenState();
}

class _AffirmationPlayerScreenState extends State<AffirmationPlayerScreen> {
  final _scroll = ScrollController();
  final _readingProgress = ValueNotifier(0.0);
  final _transcriptKey = GlobalKey();
  final _chevronOffset = ValueNotifier<double?>(null);
  late final _player = widget.controller ?? PracticePlaybackController();
  Timer? _noticeTimer;
  String? _notice;
  bool _favorite = false;
  bool _savingFavorite = false;
  bool _sharing = false;
  bool _playbackPressed = false;
  bool _wasPlaying = false;
  bool _seeking = false;
  bool _completionReported = false;
  double? _seekPreview;
  Box<bool>? _favorites;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateReadingProgress);
    _wasPlaying = _player.isPlaying;
    _player.addListener(_onPlaybackChanged);
    _readFavorite();
    _perform(() async {
      await _player.initialize();
      if (mounted &&
          widget.autoPlay &&
          !_playbackPressed &&
          !_player.isPlaying &&
          ModalRoute.of(context)?.isCurrent != false) {
        await _player.toggle();
      }
    });
  }

  void _onPlaybackChanged() {
    final finished =
        _wasPlaying &&
        !_player.isPlaying &&
        _player.isComplete &&
        !_player.isLooping &&
        !_seeking &&
        _seekPreview == null;
    _wasPlaying = _player.isPlaying;
    if (!finished || _completionReported || widget.onCompleted == null) return;
    _completionReported = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent != false) {
        widget.onCompleted?.call();
      }
    });
  }

  Future<void> _readFavorite() async {
    try {
      final box = await Hive.openBox<bool>('affirmation_player_favorites');
      if (!mounted) return;
      setState(() {
        _favorites = box;
        _favorite = box.get(_favoriteKey, defaultValue: false) ?? false;
      });
    } catch (_) {
      // Opening the player works even when local preferences are unavailable.
    }
  }

  void _announce(String message) {
    if (!mounted) return;
    _noticeTimer?.cancel();
    setState(() => _notice = message);
    _noticeTimer = Timer(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  Future<bool> _perform(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (_) {
      if (mounted) _announce(AppLocalizations.of(context).playerPlayError);
      return false;
    }
  }

  Future<void> _commitSeek(Duration position) async {
    if (position == _player.position) return;
    LotusFeedback.selection();
    _seeking = true;
    try {
      await _perform(() => _player.seek(position));
    } finally {
      _seeking = false;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_savingFavorite) return;
    _savingFavorite = true;
    final strings = AppLocalizations.of(context);
    try {
      final box =
          _favorites ??
          await Hive.openBox<bool>('affirmation_player_favorites');
      final next = !(box.get(_favoriteKey, defaultValue: false) ?? false);
      await box.put(_favoriteKey, next);
      if (!mounted) return;
      setState(() {
        _favorites = box;
        _favorite = next;
      });
      _announce(
        next ? strings.playerAddedFavorite : strings.playerRemovedFavorite,
      );
    } catch (_) {
      _announce(strings.playerFavoriteError);
    } finally {
      _savingFavorite = false;
    }
  }

  Future<void> _toggleRepeat() async {
    final next = !_player.isLooping;
    if (await _perform(() => _player.setLooping(next)) && mounted) {
      final strings = AppLocalizations.of(context);
      _announce(next ? strings.playerRepeatOn : strings.playerRepeatOff);
    }
  }

  Future<void> _share(BuildContext buttonContext) async {
    if (_sharing) return;
    _sharing = true;
    final strings = AppLocalizations.of(context);
    try {
      final box = buttonContext.findRenderObject() as RenderBox;
      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(PracticeLink.url),
          subject: '$_recordingTitle · Asteria',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      _announce(strings.playerShareError);
    } finally {
      _sharing = false;
    }
  }

  void _updateReadingProgress() {
    if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) return;
    final section = _transcriptKey.currentContext?.findRenderObject();
    final viewport = section == null
        ? null
        : RenderAbstractViewport.maybeOf(section);
    if (viewport != null && section != null) {
      final top =
          viewport.getOffsetToReveal(section, 0).offset - _scroll.offset;
      _chevronOffset.value = math.max(0, top - 9);
    }
    final travel = _scroll.position.maxScrollExtent;
    _readingProgress.value = travel <= 0
        ? 0
        : (_scroll.offset / travel).clamp(0, 1);
  }

  void _toggleReading() {
    final scroll = _scroll.position;
    final target = scroll.extentAfter < 2 ? 0.0 : scroll.maxScrollExtent;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _player.removeListener(_onPlaybackChanged);
    _scroll.dispose();
    _readingProgress.dispose();
    _chevronOffset.dispose();
    if (widget.controller == null) _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xff130d20),
        body: DefaultTextStyle(
          style: AppTypography.text1.copyWith(color: _ink),
          child: LayoutBuilder(
            builder: (context, bounds) {
              final wide = bounds.maxWidth > 540 && bounds.maxHeight >= 580;
              final panelHeight = wide
                  ? math.min(870.0, bounds.maxHeight * .92)
                  : bounds.maxHeight;
              final panel = SizedBox(
                width: wide
                    ? math.min(416.0, bounds.maxWidth)
                    : bounds.maxWidth,
                height: panelHeight,
                child: _buildPanel(
                  wide ? EdgeInsets.zero : insets,
                  panelHeight <= 620,
                ),
              );
              if (!wide) return panel;
              return DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xff45314c),
                      Color(0xff24192d),
                      Color(0xff100c18),
                    ],
                    stops: [0, .43, .83],
                    radius: .85,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: panel,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(EdgeInsets safeArea, bool compact) {
    final strings = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ListenableBuilder(
          listenable: _player,
          builder: (_, _) => PlayerArtwork(
            position: _player.position,
            duration: _player.duration,
            playing: _player.isPlaying,
          ).withEntrance(),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _readingProgress,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x0034213e),
                  Color(0x9134213e),
                  Color(0xae34213e),
                  Color(0x8834213e),
                ],
                stops: [.08, .33, .68, 1],
              ),
            ),
          ),
          builder: (_, value, child) => IgnorePointer(
            child: Opacity(opacity: value, child: child),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            safeArea.left,
            safeArea.top + (compact ? 10 : 29),
            safeArea.right,
            0,
          ),
          child: LayoutBuilder(
            builder: (context, bounds) {
              // With extra-large type or a short landscape window let the whole
              // composition scroll so a pinned header cannot cover the controls.
              final scrollHeader =
                  bounds.maxHeight < 360 ||
                  MediaQuery.textScalerOf(context).scale(18) > 27;
              final header = _PlayerHeader(
                showBack: widget.showBack,
                compact: compact,
                onExit: () => Navigator.of(context).maybePop(),
                repeatButton: ListenableBuilder(
                  listenable: _player,
                  builder: (_, _) => PlayerPebble(
                    glyph: ClayGlyph.repeat,
                    label: strings.playerRepeat,
                    value: _player.isLooping,
                    onTap: _toggleRepeat,
                  ),
                ),
              );
              Widget contents(double viewportHeight) {
                return NotificationListener<ScrollMetricsNotification>(
                  onNotification: (_) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _updateReadingProgress();
                    });
                    return false;
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SingleChildScrollView(
                        controller: _scroll,
                        child: Column(
                          children: [
                            if (scrollHeader) header,
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: scrollHeader
                                    ? 210
                                    : math.max(
                                        200,
                                        viewportHeight - 56 - safeArea.bottom,
                                      ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                heightFactor: 1,
                                child: _controls(compact),
                              ),
                            ),
                            _transcriptSection(safeArea.bottom),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<double?>(
                        valueListenable: _chevronOffset,
                        builder: (_, y, _) {
                          if (y == null || y >= viewportHeight) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            right: 13,
                            top: y,
                            child: ValueListenableBuilder<double>(
                              valueListenable: _readingProgress,
                              builder: (_, progress, _) {
                                final end = progress >= .997;
                                return LotusButtons.icon(
                                  constraints: const BoxConstraints.tightFor(
                                    width: 44,
                                    height: 44,
                                  ),
                                  padding: EdgeInsets.zero,
                                  tooltip: end
                                      ? strings.playerHideTranscript
                                      : strings.playerShowTranscript,
                                  onPressed: _toggleReading,
                                  icon: LotusIconSurface(
                                    diameter: LotusArrowBubble.diameter,
                                    child: RotatedBox(
                                      quarterTurns: end ? 1 : 3,
                                      child: LotusGlyphMotion(
                                        child: const PlayerClayGlyph(
                                          ClayGlyph.chevron,
                                          LotusArrowBubble.glyphSize,
                                        ),
                                        frameBuilder: (frame) =>
                                            PlayerClayGlyph(
                                              ClayGlyph.chevron,
                                              LotusArrowBubble.glyphSize,
                                              frame: frame,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              if (scrollHeader) return contents(bounds.maxHeight);
              return Column(
                children: [
                  header,
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, view) => contents(view.maxHeight),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (_notice != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: math.min(
              MediaQuery.sizeOf(context).height * .36,
              220 + safeArea.bottom,
            ),
            child: IgnorePointer(
              child: Center(
                child: Semantics(
                  liveRegion: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xf021172d),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      child: Text(
                        _notice!,
                        textAlign: TextAlign.center,
                        style: AppTypography.subtext,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _controls(bool compact) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: AsteriaEntrance.sections([
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (buttonContext) => PlayerPebble(
                  glyph: ClayGlyph.share,
                  label: strings.playerShare,
                  onTap: () => _share(buttonContext),
                ),
              ),
              const SizedBox(width: 16),
              ListenableBuilder(
                listenable: _player,
                builder: (_, _) => PlayerPebble(
                  primary: true,
                  compact: compact,
                  glyph: _player.isPlaying ? ClayGlyph.pause : ClayGlyph.play,
                  label: _player.isPlaying
                      ? strings.playerPause
                      : _player.isComplete
                      ? strings.playerReplay
                      : strings.playerPlay,
                  value: _player.isPlaying,
                  onTap: () {
                    _playbackPressed = true;
                    _perform(_player.toggle);
                  },
                ),
              ),
              const SizedBox(width: 16),
              PlayerPebble(
                glyph: _favorite ? ClayGlyph.saved : ClayGlyph.bookmark,
                label: strings.playerFavorite,
                value: _favorite,
                onTap: _toggleFavorite,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: compact ? 4 : 22,
              bottom: compact ? 4 : 10,
            ),
            child: ListenableBuilder(
              listenable: _player,
              builder: (context, _) {
                final max = math
                    .max(1, _player.duration.inMilliseconds)
                    .toDouble();
                final ms =
                    (_seekPreview ?? _player.position.inMilliseconds.toDouble())
                        .clamp(0.0, max);
                final elapsed = Duration(milliseconds: ms.round());
                final gap = (MediaQuery.sizeOf(context).width * .05).clamp(
                  14.0,
                  22.0,
                );
                final next = Duration(
                  milliseconds: (ms + 5000).clamp(0.0, max).round(),
                );
                final previous = Duration(
                  milliseconds: (ms - 5000).clamp(0.0, max).round(),
                );
                final style = AppTypography.label14.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                );
                return Row(
                  children: [
                    Text(_formatTime(elapsed), style: style),
                    SizedBox(width: gap),
                    Expanded(
                      child: Semantics(
                        container: true,
                        enabled: true,
                        slider: true,
                        excludeSemantics: true,
                        label: strings.playerPosition,
                        value: _formatTime(elapsed),
                        increasedValue: _formatTime(next),
                        decreasedValue: _formatTime(previous),
                        onIncrease: () => _commitSeek(next),
                        onDecrease: () => _commitSeek(previous),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            padding: EdgeInsets.zero,
                            trackHeight: 5,
                            trackShape: const _TimelineTrack(),
                            thumbShape: const _TimelineThumb(),
                            overlayShape: SliderComponentShape.noOverlay,
                            activeTrackColor: _ink,
                            inactiveTrackColor: const Color(0x47efdfef),
                            thumbColor: _ink,
                          ),
                          child: SizedBox(
                            height: 44,
                            child: Slider(
                              max: max,
                              value: ms,
                              semanticFormatterCallback: (v) => _formatTime(
                                Duration(milliseconds: v.round()),
                              ),
                              onChangeStart: (v) =>
                                  setState(() => _seekPreview = v),
                              onChanged: (v) =>
                                  setState(() => _seekPreview = v),
                              onChangeEnd: (v) async {
                                await _commitSeek(
                                  Duration(milliseconds: v.round()),
                                );
                                if (mounted) {
                                  setState(() => _seekPreview = null);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    Text(_formatTime(_player.duration), style: style),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _transcriptSection(double safeBottom) {
    return SizedBox(
      width: double.infinity,
      key: _transcriptKey,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 40 + safeBottom),
        child: ListenableBuilder(
          listenable: _player,
          builder: (context, _) {
            final time = _player.position.inMilliseconds / 1000;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AsteriaEntrance.sections([
                for (int i = 0; i < _transcript.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == _transcript.length - 1 ? 0 : 12,
                      right: i == 0 ? 36 : 0,
                    ),
                    child: Text(
                      _transcript[i].$2,
                      style: AppTypography.text1.copyWith(
                        color:
                            time >= _transcript[i].$1 &&
                                time <
                                    (i + 1 < _transcript.length
                                        ? _transcript[i + 1].$1
                                        : _player.duration.inMilliseconds /
                                              1000)
                            ? const Color(0xffffdfc6)
                            : const Color(0xfffff8fb),
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 6,
                            color: Color(0x5c3f2747),
                          ),
                        ],
                      ),
                    ),
                  ),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.compact,
    required this.onExit,
    required this.showBack,
    required this.repeatButton,
  });
  final bool compact;
  final VoidCallback onExit;
  final bool showBack;
  final Widget repeatButton;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    const shadow = [
      Shadow(offset: Offset(0, 1), blurRadius: 8, color: Color(0x54382039)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: AsteriaEntrance.sections([
                Padding(
                  padding: const EdgeInsets.fromLTRB(51, 12, 51, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const PlayerClayGlyph(ClayGlyph.spark, 16),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          strings.affirmationCategoryCalm.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTypography.h4.copyWith(
                            color: _headerInk,
                            shadows: shadow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: compact ? 11 : 24,
                    bottom: compact ? 3 : 7,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      _recordingTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.h1.copyWith(shadows: shadow),
                    ),
                  ),
                ),
                Text(
                  strings.playerMetadata,
                  textAlign: TextAlign.center,
                  style: AppTypography.text2.copyWith(
                    color: _headerInk,
                    shadows: shadow,
                  ),
                ),
              ]),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child:
                (showBack
                        ? LotusButtons.icon(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).backButtonTooltip,
                            onPressed: onExit,
                            icon: const LotusArrowBubble(back: true),
                          )
                        : PlayerPebble(
                            glyph: ClayGlyph.close,
                            label: strings.playerClose,
                            onTap: onExit,
                          ))
                    .withEntrance(order: 0),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: repeatButton.withEntrance(order: 1),
          ),
        ],
      ),
    );
  }
}

// HTML range controls keep the entire thumb inside the visible track.
class _TimelineTrack extends SliderTrackShape {
  const _TimelineTrack();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const inset = 15.5;
    return Rect.fromLTWH(
      offset.dx + inset,
      offset.dy + (parentBox.size.height - 5) / 2,
      math.max(0, parentBox.size.width - 2 * inset),
      5,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rail = Rect.fromLTWH(
      offset.dx,
      thumbCenter.dy - 2.5,
      parentBox.size.width,
      5,
    );
    final active = textDirection == TextDirection.ltr
        ? Rect.fromLTRB(rail.left, rail.top, thumbCenter.dx, rail.bottom)
        : Rect.fromLTRB(thumbCenter.dx, rail.top, rail.right, rail.bottom);
    const radius = Radius.circular(2.5);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rail, radius),
      Paint()..color = sliderTheme.inactiveTrackColor!,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(active, radius),
      Paint()..color = sliderTheme.activeTrackColor!,
    );
  }
}

class _TimelineThumb extends SliderComponentShape {
  const _TimelineThumb();
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(31, 20);
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = Rect.fromCenter(center: center, width: 31, height: 20);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = _ink,
    );
  }
}
