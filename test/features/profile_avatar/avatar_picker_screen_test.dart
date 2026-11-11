import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/profile_avatar.dart';
import 'package:asteria_app/features/profile_avatar/avatar_picker_screen.dart';
import 'package:asteria_app/features/profile_avatar/avatar_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Storage implements AvatarStorage {
  final data = <String, String>{};
  bool fail = false;
  @override
  String? read(String userId) => data[userId];
  @override
  Future<void> write(String userId, String presetId) async {
    if (fail) throw StateError('storage unavailable');
    data[userId] = presetId;
  }
}

Widget _app(AvatarPreferences preferences, {double scale = 1}) => MaterialApp(
  locale: const Locale('ru'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.delegate.supportedLocales,
  builder: (context, child) => Theme(
    data: AppThemeDark.instance.getThemeData(context),
    child: MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
  ),
  home: Builder(
    builder: (context) => Scaffold(
      body: Column(
        children: [
          ProfileAvatar(
            size: 36,
            userId: 'one',
            gender: Gender.female,
            preferences: preferences,
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AvatarPickerScreen(
                  userId: 'one',
                  gender: Gender.female,
                  preferences: preferences,
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'draft cancels, confirmation updates the avatar and survives reopening',
    (tester) async {
      final storage = _Storage();
      final preferences = AvatarPreferences(storage: storage);
      addTearDown(preferences.dispose);
      await tester.pumpWidget(_app(preferences));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Выберите свой образ'), findsOneWidget);
      await tester.ensureVisible(find.text('Единорог'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Единорог'));
      await tester.pumpAndSettle();
      expect(preferences.selectedFor('one', Gender.female).id, 'elf_woman');
      await tester.tap(find.bySemanticsLabel('Назад'));
      await tester.pumpAndSettle();
      expect(storage.data, isEmpty);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Единорог'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Единорог'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выбрать образ'));
      await tester.pumpAndSettle();
      expect(find.byType(AvatarPickerScreen), findsNothing);
      expect(storage.data['one'], 'unicorn');
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as ResizeImage).imageProvider, isA<AssetImage>());
      expect(
        ((image.image as ResizeImage).imageProvider as AssetImage).assetName,
        endsWith('/unicorn.png'),
      );
      expect(
        AvatarPreferences(
          storage: storage,
        ).selectedFor('one', Gender.female).id,
        'unicorn',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'save failure keeps the picker open and supports retry at 200 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final storage = _Storage()..fail = true;
      final preferences = AvatarPreferences(storage: storage);
      addTearDown(preferences.dispose);
      await tester.pumpWidget(_app(preferences, scale: 2));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Единорог'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Единорог'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выбрать образ'));
      await tester.pumpAndSettle();
      expect(
        find.text('Не удалось сохранить образ. Попробуйте ещё раз.'),
        findsOneWidget,
      );
      expect(preferences.selectedFor('one', Gender.female).id, 'elf_woman');
      storage.fail = false;
      await tester.tap(find.text('Выбрать образ'));
      await tester.pumpAndSettle();
      expect(storage.data['one'], 'unicorn');
      expect(tester.takeException(), isNull);
    },
  );
}
