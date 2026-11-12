import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/calendar_plan_reminders.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/calendar_plan.dart';
import 'package:asteria_app/features/scenarios/calendar_plan_reminder_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Reminders extends CalendarPlanReminders {
  @override
  bool supported = true;
  final times = <(String, String), DateTime>{};
  var result = PlanReminderResult.scheduled;
  var notificationBody = '';
  int writes = 0;

  @override
  Future<DateTime?> scheduledTime({
    required String owner,
    required String planId,
  }) async => times[(owner, planId)];

  @override
  Future<PlanReminderResult> schedule({
    required String owner,
    required String planId,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    writes++;
    if (result == PlanReminderResult.scheduled) {
      times[(owner, planId)] = at;
      notificationBody = body;
    }
    return result;
  }

  @override
  Future<bool> cancel({required String owner, required String planId}) async {
    times.remove((owner, planId));
    return true;
  }
}

void main() {
  final now = DateTime.now();
  final day = DateTime.utc(now.year, now.month, now.day + 2);
  const owner = 'test-account';
  const planId = 'test-id';
  Future<void> show(
    WidgetTester tester,
    _Reminders service,
    DateTime date,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (c, child) =>
            Theme(data: AppThemeDark.instance.getThemeData(c), child: child!),
        home: Scaffold(
          body: CalendarPlanReminderControl(
            plan: CalendarPlan(
              id: planId,
              owner: owner,
              day: date,
              activity: CalendarActivity.haircut,
              title: 'Стрижка',
              recommendation: null,
            ),
            reminders: service,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'reminder is opt-in, persists on reopen, can be edited and removed',
    (tester) async {
      final reminders = _Reminders();
      await show(tester, reminders, day);
      await tap(tester, 'Напомнить в день плана');
      await tap(tester, 'Отмена');
      expect(reminders.writes, 0);
      await tap(tester, 'Напомнить в день плана');
      await tap(tester, 'Выбрать');
      expect(
        reminders.times[(owner, planId)],
        DateTime(day.year, day.month, day.day, 9),
      );
      expect(reminders.notificationBody, 'Стрижка');
      await tester.pumpWidget(const SizedBox());
      await show(tester, reminders, day);
      await tap(tester, 'Изменить время');
      tester
          .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
          .onDateTimeChanged(DateTime(day.year, day.month, day.day, 15, 45));
      await tap(tester, 'Выбрать');
      expect(
        reminders.times[(owner, planId)],
        DateTime(day.year, day.month, day.day, 15, 45),
      );
      expect(reminders.times.length, 1);
      await tap(tester, 'Убрать напоминание');
      expect(reminders.times, isEmpty);
      expect(find.text('Напомнить в день плана'), findsOneWidget);
    },
  );

  testWidgets('permission denial is explained without a false confirmation', (
    tester,
  ) async {
    final reminders = _Reminders()..result = PlanReminderResult.denied;
    await show(tester, reminders, day);
    await tap(tester, 'Напомнить в день плана');
    await tap(tester, 'Выбрать');
    expect(find.textContaining('настройках iPhone'), findsOneWidget);
    expect(find.text('Убрать напоминание'), findsNothing);
    expect(reminders.times, isEmpty);
  });

  testWidgets(
    'past plans and unsupported platforms have no dead reminder button',
    (tester) async {
      final reminders = _Reminders();
      await show(tester, reminders, day.subtract(const Duration(days: 4)));
      expect(find.text('Напомнить в день плана'), findsNothing);
      reminders.supported = false;
      await show(tester, reminders, day);
      expect(find.text('Напомнить в день плана'), findsNothing);
    },
  );
}
