import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PlanReminderResult { scheduled, denied, past, unavailable }

class CalendarPlanReminders {
  const CalendarPlanReminders();

  static const _channel = MethodChannel('asteria/calendar-plan-reminders');
  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  String _digest(String text) => sha256.convert(utf8.encode(text)).toString();

  String _prefix(String owner) => 'asteria.plan.${_digest(owner)}.';
  String _id(String owner, String planId) =>
      '${_prefix(owner)}${_digest(planId)}';

  Future<DateTime?> scheduledTime({
    required String owner,
    required String planId,
  }) async {
    if (!supported) return null;
    final time = await _channel.invokeMethod<int>('scheduledTime', {
      'id': _id(owner, planId),
    });
    return time == null ? null : DateTime.fromMillisecondsSinceEpoch(time);
  }

  Future<PlanReminderResult> schedule({
    required String owner,
    required String planId,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!supported || owner.isEmpty || planId.isEmpty) {
      return PlanReminderResult.unavailable;
    }
    if (!at.isAfter(DateTime.now())) return PlanReminderResult.past;
    try {
      final status = await _channel.invokeMethod<String>('schedule', {
        'id': _id(owner, planId),
        'at': at.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      });
      return switch (status) {
        'scheduled' => PlanReminderResult.scheduled,
        'denied' => PlanReminderResult.denied,
        'past' => PlanReminderResult.past,
        _ => PlanReminderResult.unavailable,
      };
    } on PlatformException {
      return PlanReminderResult.unavailable;
    } on MissingPluginException {
      return PlanReminderResult.unavailable;
    }
  }

  Future<bool> cancel({required String owner, required String planId}) =>
      _remove('cancel', {'id': _id(owner, planId)});

  Future<bool> cancelOwner(String owner) =>
      _remove('cancelOwner', {'prefix': _prefix(owner)});

  Future<bool> _remove(String method, Map<String, String> arguments) async {
    if (!supported) return false;
    try {
      await _channel.invokeMethod<void>(method, arguments);
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
