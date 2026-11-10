import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/global_loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'natal loading starts with a phrase, rotates, and releases its timer',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final loader = GlobalLoaderService()
        ..showWithSpheres(GlobalLoaderType.natalCard);
      addTearDown(loader.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: GlobalLoaderWidget(
                  loaderService: loader,
                  child: const Scaffold(body: Text('Content')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.textContaining('Соединяем звёзды'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Читаем тайный язык планет…'), findsOneWidget);
      expect(find.textContaining('Соединяем звёзды'), findsNothing);
      expect(tester.takeException(), isNull);
      loader.hide();
      await tester.pump();
      expect(find.text('Content'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    },
  );
}
