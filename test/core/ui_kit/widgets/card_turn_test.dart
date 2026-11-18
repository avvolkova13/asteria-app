import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/flip_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const frontKey = ValueKey('front-face');
const backKey = ValueKey('back-face');

Widget screen(Widget child, {bool reducedMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reducedMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

Widget face(Key key, String label) => SizedBox(
  key: key,
  width: 100,
  height: 150,
  child: ColoredBox(color: Colors.purple, child: Text(label)),
);

void main() {
  Transform rotation(WidgetTester tester) => tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(CardTurn),
          matching: find.byType(Transform),
        ),
      )
      .last;

  testWidgets(
    'turn keeps both faces mounted and reveals front through its edge',
    (tester) async {
      final mounts = <String>[];
      Future<void> show(double progress) => tester.pumpWidget(
        screen(
          SizedBox(
            width: 100,
            height: 150,
            child: CardTurn(
              progress: progress,
              front: _MountedFace(
                key: frontKey,
                label: 'front',
                mounts: mounts,
              ),
              back: _MountedFace(key: backKey, label: 'back', mounts: mounts),
            ),
          ),
        ),
      );
      await show(0);
      expect(mounts, containsAll(['front', 'back']));
      expect(find.byKey(backKey), findsOneWidget);
      expect(find.byKey(frontKey), findsNothing);
      expect(find.byKey(frontKey, skipOffstage: false), findsOneWidget);
      expect(rotation(tester).transform.entry(0, 0), 1);
      await show(.25);
      expect(find.byKey(backKey), findsOneWidget);
      expect(rotation(tester).transform.entry(0, 0), inExclusiveRange(0, 1));
      // The onboarding cubic crosses its edge near the temporal midpoint.
      await show(.5);
      expect(rotation(tester).transform.entry(0, 0).abs(), lessThan(.08));
      expect(find.byKey(frontKey), findsOneWidget);
      await show(.75);
      expect(rotation(tester).transform.entry(0, 0), inExclusiveRange(0, 1));
      await show(1);
      expect(find.byKey(frontKey), findsOneWidget);
      expect(find.byKey(backKey), findsNothing);
      expect(rotation(tester).transform.entry(0, 0), 1);
      expect(mounts, hasLength(2));
      for (final type in [
        Opacity,
        AnimatedOpacity,
        FadeTransition,
        SlideTransition,
        AsteriaEntrance,
      ]) {
        expect(
          find.descendant(
            of: find.byType(CardTurn),
            matching: find.byType(type),
          ),
          findsNothing,
        );
      }
    },
  );

  testWidgets(
    'horizontal turn rotates around X and finishes without distortion',
    (tester) async {
      Future<void> show(double progress) => tester.pumpWidget(
        screen(
          SizedBox(
            width: 150,
            height: 100,
            child: CardTurn(
              progress: progress,
              horizontal: true,
              front: face(frontKey, 'front'),
              back: face(backKey, 'back'),
            ),
          ),
        ),
      );
      // The onboarding cubic crosses its edge near the temporal midpoint.
      await show(.5);
      expect(rotation(tester).transform.entry(0, 0), 1);
      expect(rotation(tester).transform.entry(1, 1).abs(), lessThan(.08));
      await show(1);
      expect(rotation(tester).transform.entry(1, 1), 1);
      expect(find.byKey(frontKey), findsOneWidget);
    },
  );

  testWidgets(
    'reduced motion switches face immediately without lift or rotation',
    (tester) async {
      await tester.pumpWidget(
        screen(
          CardTurn(
            progress: .1,
            front: face(frontKey, 'front'),
            back: face(backKey, 'back'),
          ),
          reducedMotion: true,
        ),
      );
      expect(find.byKey(frontKey), findsOneWidget);
      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(CardTurn),
          matching: find.byType(Transform),
        ),
      );
      expect(transforms.first.transform.entry(1, 3).abs(), lessThan(.001));
      expect(transforms.last.transform.entry(0, 0), 1);
    },
  );

  testWidgets(
    'rapid taps complete one reveal and opened taps use detail action',
    (tester) async {
      var starts = 0;
      var completes = 0;
      var details = 0;
      await tester.pumpWidget(
        screen(
          FlipCardWidget(
            front: face(frontKey, 'front'),
            back: face(backKey, 'back'),
            isOpened: false,
            flipOnTap: true,
            width: 100,
            height: 150,
            onFlipStart: () => starts++,
            onFlipComplete: () => completes++,
            onTap: () => details++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final point = tester.getCenter(find.byType(FlipCardWidget));
      await tester.tapAt(point);
      await tester.pump();
      await tester.tapAt(point);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tapAt(point);
      expect(starts, 1);
      expect(completes, 0);
      expect(details, 0);
      await tester.pumpAndSettle();
      expect(completes, 1);
      expect(find.byKey(frontKey), findsOneWidget);
      await tester.tapAt(point);
      expect(details, 1);
      expect(starts, 1);
    },
  );

  testWidgets(
    'external opened state animates without user completion callbacks',
    (tester) async {
      var completes = 0;
      Widget host(bool opened) => screen(
        FlipCardWidget(
          front: face(frontKey, 'front'),
          back: face(backKey, 'back'),
          isOpened: opened,
          flipOnTap: true,
          width: 100,
          height: 150,
          onFlipComplete: () => completes++,
        ),
      );
      await tester.pumpWidget(host(false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(host(true));
      expect(tester.widget<CardTurn>(find.byType(CardTurn)).progress, 0);
      await tester.pump(const Duration(milliseconds: 425));
      expect(
        tester.widget<CardTurn>(find.byType(CardTurn)).progress,
        inExclusiveRange(0, 1),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(frontKey), findsOneWidget);
      expect(completes, 0);
    },
  );

  testWidgets('reset conceals replacement artwork in its first frame', (
    tester,
  ) async {
    Widget host(bool opened) => screen(
      FlipCardWidget(
        front: face(frontKey, opened ? 'Old card' : 'New card'),
        back: face(backKey, 'back'),
        isOpened: opened,
        width: 100,
        height: 150,
      ),
    );
    await tester.pumpWidget(host(true));
    expect(find.text('Old card'), findsOneWidget);
    await tester.pumpWidget(host(false));
    expect(find.text('New card'), findsNothing);
    expect(find.byKey(backKey), findsOneWidget);
    expect(tester.widget<CardTurn>(find.byType(CardTurn)).progress, 0);
  });

  testWidgets(
    'reduced motion completes immediately and disposal cancels a turn',
    (tester) async {
      var completes = 0;
      Widget host(bool reduced) => screen(
        FlipCardWidget(
          front: face(frontKey, 'front'),
          back: face(backKey, 'back'),
          isOpened: false,
          flipOnTap: true,
          width: 100,
          height: 150,
          onFlipComplete: () => completes++,
        ),
        reducedMotion: reduced,
      );
      await tester.pumpWidget(host(true));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pump();
      expect(completes, 1);
      expect(find.byKey(frontKey), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(host(false));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      expect(completes, 1);
      expect(tester.takeException(), isNull);
    },
  );
}

class _MountedFace extends StatefulWidget {
  const _MountedFace({super.key, required this.label, required this.mounts});
  final String label;
  final List<String> mounts;
  @override
  State<_MountedFace> createState() => _MountedFaceState();
}

class _MountedFaceState extends State<_MountedFace> {
  @override
  void initState() {
    super.initState();
    widget.mounts.add(widget.label);
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 100, height: 150, child: Text(widget.label));
}
