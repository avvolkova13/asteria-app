import 'package:asteria_app/features/practices/presentation/practice_note_indicators.dart';
import 'package:asteria_app/core/ui_kit/widgets/deck_catalog_scroll.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/practice_pencil.dart';
import 'package:asteria_app/features/practices/presentation/practice_notes_screen.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/swipe_card_stack.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, TextButton;
import 'package:provider/provider.dart';

part 'practice_catalog_content.dart';

const _morningArt = 'assets/images/home/hand_with_star.webp';
const _practiceArtDirectory = 'assets/images/practices';

enum PracticeCategory {
  meditation(
    'Медитации',
    'Meditations',
    'На утро, после работы или перед сном.',
    'For mornings, after work, or bedtime.',
    _morningArt,
  ),
  body(
    'Телесные практики',
    'Body practices',
    'Дыхание, движение, самомассаж и доска садху.',
    'Breathing, movement, self-massage, and nail-board sessions.',
    '$_practiceArtDirectory/cloud-hands.webp',
  );

  const PracticeCategory(
    this._ruTitle,
    this._enTitle,
    this._ruDescription,
    this._enDescription,
    this.art,
  );

  final String _ruTitle, _enTitle, _ruDescription, _enDescription, art;
  String title(bool ru) => ru ? _ruTitle : _enTitle;
  String description(bool ru) => ru ? _ruDescription : _enDescription;
}

enum _PracticeKind {
  meditation('Медитации', 'Meditations', _morningArt),
  breathing(
    'Дыхание',
    'Breathing',
    '$_practiceArtDirectory/easy-breathing-rhythm.webp',
  ),
  movement(
    'Движение',
    'Movement',
    '$_practiceArtDirectory/shake-off-the-day.webp',
  ),
  massage(
    'Самомассаж',
    'Self-massage',
    '$_practiceArtDirectory/feel-the-difference.webp',
  ),
  sadhu(
    'Гвоздестояние',
    'Nail board',
    '$_practiceArtDirectory/sadhu-board.webp',
  );

  const _PracticeKind(this._ru, this._en, this.art);
  final String _ru, _en, art;
  String title(bool ru) => ru ? _ru : _en;
}

class _Practice {
  const _Practice({
    required this.id,
    required this.kind,
    required this.minutes,
    required this.scene,
    required this.title,
    required this.description,
    required this.setup,
    required this.steps,
  });

  final String id;
  final _PracticeKind kind;
  final int minutes;
  final PracticeScene scene;
  final (String, String) title, description, setup;
  final List<(int, String, String)> steps;

  String get art => id == 'unhurried-morning'
      ? _morningArt
      : '$_practiceArtDirectory/$id.webp';

  String metadata(bool ru) =>
      [ru ? '$minutes мин' : '$minutes min', _localized(setup, ru)].join(' · ');
}

String _localized((String, String) value, bool ru) => ru ? value.$1 : value.$2;
bool _isRussian(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ru';

void openPracticeCatalog(BuildContext context, PracticeCategory category) {
  Navigator.of(context).push<void>(
    CupertinoPageRoute(builder: (_) => _PracticeCatalogScreen(category)),
  );
}

class _PracticeCatalogScreen extends StatelessWidget {
  const _PracticeCatalogScreen(this.category);
  final PracticeCategory category;

  @override
  Widget build(BuildContext context) {
    final ru = _isRussian(context);
    final kinds = category == PracticeCategory.meditation
        ? [_PracticeKind.meditation]
        : _PracticeKind.values.skip(1);

    return DeckCatalogScroll(
      child: ScenarioPage(
        title: category.title(ru),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final kind in kinds) ...[
              if (kind != kinds.first) const SizedBox(height: 30),
              if (category == PracticeCategory.body) ...[
                Semantics(
                  header: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          kind.title(ru),
                          style: context.textTheme.inversePlayfairSemiBold24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        kind.art,
                        height: 29,
                        width: 29,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _PracticeDeck(kind: kind, showHint: kind == kinds.first),
            ],
          ],
        ),
      ),
    );
  }
}

class _PracticeDeck extends StatelessWidget {
  const _PracticeDeck({required this.kind, required this.showHint});
  final _PracticeKind kind;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final ru = _isRussian(context);
    final practices = _practices.where((entry) => entry.kind == kind).toList();
    return SwipeCardStack<_Practice>(
      key: ValueKey(kind),
      items: practices,
      idOf: (practice) => practice.id,
      label: (_, practice) =>
          '${_localized(practice.title, ru)}. ${practice.metadata(ru)}',
      showSwipeHint: showHint,
      onOpen: (context, practice, _) => Navigator.of(context).push<void>(
        CupertinoPageRoute(builder: (_) => _PracticeDetailScreen(practice)),
      ),
      cardBuilder: (context, index, front, hint) => PracticeDeckCard(
        artwork: _PracticeDeckArtwork(asset: practices[index].art),
        isFront: front,
        showSwipeHint: hint,
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: IndexedStack(
            index: index,
            children: [
              for (final practice in practices)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _localized(practice.title, ru),
                      style: context.textTheme.inversePlayfairSemiBold24,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      practice.metadata(ru),
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeDeckArtwork extends StatelessWidget {
  const _PracticeDeckArtwork({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/scenarios/picker_sky.webp',
          fit: BoxFit.cover,
          alignment: const Alignment(0, .7),
          excludeFromSemantics: true,
        ),
        Center(
          child: Image.asset(
            asset,
            height: 150,
            width: 174,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}

class _PracticeDetailScreen extends StatelessWidget {
  const _PracticeDetailScreen(this.practice);
  final _Practice practice;

  void _openPlayer(BuildContext context, bool ru) {
    final locale = ru ? 'ru' : 'en';
    Navigator.of(context).push<void>(
      CupertinoPageRoute(
        builder: (playerContext) => AffirmationPlayerScreen(
          showBack: true,
          onOpenNotes: _hasPracticeNotes(playerContext)
              ? () => _openNotes(playerContext, practice, ru)
              : null,
          onCompleted: () =>
              Navigator.of(playerContext).pushReplacement<void, void>(
                CupertinoPageRoute(
                  builder: (_) => _PracticeCompletionScreen(practice),
                ),
              ),
          autoPlay: true,
          session: PracticePlayerSession(
            id: practice.id,
            scene: practice.scene,
            subjectAsset: practice.art,
            title: _localized(practice.title, ru),
            category: practice.kind.title(ru),
            metadata: practice.metadata(ru),
            audioAsset: 'assets/audio/${practice.id}-$locale.m4a',
            duration: Duration(minutes: practice.minutes),
            transcript: [
              for (final (seconds, russian, english) in practice.steps)
                (seconds.toDouble(), ru ? russian : english),
            ],
            previewLabel: ru
                ? 'Пока без озвучки'
                : 'Voice recording coming soon',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ru = _isRussian(context);
    final bodyStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      height: 1.5,
    );

    return ScenarioPage(
      title: _localized(practice.title, ru),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasPracticeNotes(context)) ...[
            HomeGlassSurface(
              animateEntrance: false,
              radius: 16,
              child: LotusButtons.text(
                onPressed: () => _openNotes(context, practice, ru),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox.square(
                      dimension: 34,
                      child: LotusIconSurface(
                        diameter: 34,
                        child: Center(child: PracticePencil()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ru ? 'Мои заметки' : 'My notes',
                            style: context.textTheme.inverseUrbanistMedium16,
                          ),
                          PracticeNotesMarker(practiceId: practice.id),
                        ],
                      ),
                    ),
                    const ClayIcon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.cardTinted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          AuthGradientButton(
            key: const ValueKey('open-practice-player'),
            text: ru ? 'Начать практику' : 'Start practice',
            onPressed: () => _openPlayer(context, ru),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeGlassSurface(
            animateEntrance: false,
            child: _PracticeCover(art: practice.art),
          ),
          const SizedBox(height: 18),
          Text(practice.metadata(ru), style: bodyStyle),
          const SizedBox(height: 8),
          Text(_localized(practice.description, ru), style: bodyStyle),
          const SizedBox(height: 26),
          Semantics(
            header: true,
            child: Text(
              ru ? 'Как проходит практика' : 'Session guide',
              style: context.textTheme.inversePlayfairSemiBold24,
            ),
          ),
          const SizedBox(height: 10),
          for (final step in practice.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(ru ? step.$2 : step.$3, style: bodyStyle),
            ),
        ],
      ),
    );
  }
}

String? practiceTitleById(String id, bool ru) {
  final practice = _practices.where((item) => item.id == id).firstOrNull;
  return practice == null ? null : _localized(practice.title, ru);
}

bool _hasPracticeNotes(BuildContext context) =>
    context.watch<UserProvider?>()?.currentUser?.id.isNotEmpty == true;

Future<void> _openNotes(
  BuildContext context,
  _Practice practice,
  bool ru, {
  bool startNew = false,
}) => openPracticeNotes(
  context,
  practiceId: practice.id,
  practiceTitle: _localized(practice.title, ru),
  startNew: startNew,
);

class _PracticeCompletionScreen extends StatelessWidget {
  const _PracticeCompletionScreen(this.practice);

  final _Practice practice;

  @override
  Widget build(BuildContext context) {
    final ru = _isRussian(context);
    final hasNotes = _hasPracticeNotes(context);
    final doneLabel = ru ? 'Готово' : 'Done';
    void close() => Navigator.of(context).pop();
    return ScenarioPage(
      title: ru ? 'Практика завершена' : 'Practice complete',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasNotes)
            AsteriaActionButton(
              onPressed: () =>
                  _openNotes(context, practice, ru, startNew: true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PracticePencil(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      ru ? 'Написать заметку' : 'Write a note',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          else
            AuthGradientButton(text: doneLabel, onPressed: close),
          if (hasNotes)
            LotusButtons.text(onPressed: close, child: Text(doneLabel)),
        ],
      ),
      child: Text(
        _localized(practice.title, ru),
        style: context.textTheme.inverseUrbanistRegular16,
      ),
    );
  }
}

class _PracticeCover extends StatefulWidget {
  const _PracticeCover({required this.art});
  final String art;

  @override
  State<_PracticeCover> createState() => _PracticeCoverState();
}

class _PracticeCoverState extends State<_PracticeCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 128 : 200,
    child: Center(
      child: AnimatedBuilder(
        animation: _motion,
        child: FractionallySizedBox(
          heightFactor: .8,
          child: Image.asset(
            widget.art,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        builder: (_, child) {
          final phase = Curves.easeInOut.transform(_motion.value);
          return Transform.translate(
            offset: Offset(0, -5 * phase),
            child: Transform.scale(scale: 1 + .05 * phase, child: child),
          );
        },
      ),
    ),
  );
}
