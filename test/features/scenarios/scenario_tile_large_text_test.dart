import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Onest')..addFont(rootBundle.load('assets/fonts/onest/Onest-VariableFont_wght.ttf'))).load();
  });
  for (final title in ['Пересадка комнатных растений','Repotting indoor plants']) {
    testWidgets('large text keeps the first word intact: $title', (tester) async {
      tester.view.physicalSize = const Size(320,568); tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var taps = 0;
      await tester.pumpWidget(MaterialApp(home: Builder(builder:(context)=>Theme(data: AppThemeDark.instance.getThemeData(context), child: MediaQuery(data:MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)), child:Scaffold(body: Padding(padding:const EdgeInsets.all(16), child: ScenarioTile(title:title,art:'assets/images/scenarios/compass.webp',onTap:()=>taps++))))))));
      await tester.pumpAndSettle();
      final text = find.text(title);
      final paragraph = tester.renderObject<RenderParagraph>(find.descendant(of:text,matching:find.byType(RichText)));
      final firstWord = title.split(' ').first;
      expect(paragraph.getBoxesForSelection(TextSelection(baseOffset:0,extentOffset:firstWord.length)),hasLength(1));
      await tester.tap(text); expect(taps,1); expect(tester.takeException(),isNull);
    });
  }
}
