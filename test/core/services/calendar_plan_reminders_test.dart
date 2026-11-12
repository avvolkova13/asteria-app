import 'package:asteria_app/core/services/calendar_plan_reminders.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('asteria/calendar-plan-reminders');
  const reminders = CalendarPlanReminders();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final pending = <String, int>{};
  final calls = <MethodCall>[];

  setUp(() {
    pending.clear();
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      final args = Map<Object?, Object?>.from(call.arguments as Map);
      switch (call.method) {
        case 'schedule':
          pending[args['id']! as String] = args['at']! as int;
          return 'scheduled';
        case 'scheduledTime':
          return pending[args['id']];
        case 'cancel':
          pending.remove(args['id']);
          return null;
        case 'cancelOwner':
          pending.removeWhere(
            (key, _) => key.startsWith(args['prefix']! as String),
          );
          return null;
        default:
          throw MissingPluginException();
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  Future<PlanReminderResult> schedule(
    DateTime at,
    String owner, [
    String plan = 'Haircut',
  ]) => reminders.schedule(
    owner: owner,
    planId: plan,
    at: at,
    title: 'Asteria',
    body: 'Стрижка',
  );

  test(
    'lookup does not request authorization; editing replaces one request scoped to the owner',
    () async {
      final at = DateTime.now().add(const Duration(days: 1));
      final later = at.add(const Duration(hours: 2));
      expect(
        await reminders.scheduledTime(owner: 'A', planId: 'Haircut'),
        isNull,
      );
      expect(calls.single.method, 'scheduledTime');
      expect(await schedule(at, 'A'), PlanReminderResult.scheduled);
      expect(await schedule(later, 'A'), PlanReminderResult.scheduled);
      expect(pending, hasLength(1));
      expect(
        (await reminders.scheduledTime(
          owner: 'A',
          planId: 'Haircut',
        ))!.millisecondsSinceEpoch,
        later.millisecondsSinceEpoch,
      );
      expect(await schedule(at, 'B'), PlanReminderResult.scheduled);
      expect(pending, hasLength(2));
      expect(await reminders.cancel(owner: 'A', planId: 'Haircut'), isTrue);
      expect(pending, hasLength(1));
      expect(await schedule(at, 'B', 'other'), PlanReminderResult.scheduled);
      expect(await schedule(at, 'A', 'again'), PlanReminderResult.scheduled);
      expect(await reminders.cancelOwner('B'), isTrue);
      expect(pending, hasLength(1));
      expect(
        await reminders.scheduledTime(owner: 'A', planId: 'again'),
        isNotNull,
      );
    },
  );

  test(
    'past time and unsupported platforms never schedule; permission denial is distinguishable',
    () async {
      expect(
        await schedule(
          DateTime.now().subtract(const Duration(seconds: 1)),
          'A',
        ),
        PlanReminderResult.past,
      );
      expect(calls, isEmpty);
      final future = DateTime.now().add(const Duration(days: 1));
      messenger.setMockMethodCallHandler(channel, (_) async => 'denied');
      expect(await schedule(future, 'A'), PlanReminderResult.denied);
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'schedule_failed'),
      );
      expect(await schedule(future, 'A'), PlanReminderResult.unavailable);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(reminders.supported, isFalse);
      expect(await schedule(future, 'A'), PlanReminderResult.unavailable);
    },
  );
}
