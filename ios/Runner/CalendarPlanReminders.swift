import Flutter
import UserNotifications

/// Pending requests in Notification Center are the source of truth, including
/// after relaunch. Identifiers are stable hashes scoped to the signed-in owner.
@MainActor
final class CalendarPlanReminders {
  static let prefix = "asteria.plan."
  private let center = UNUserNotificationCenter.current()
  private var activeSchedules: [String: UUID] = [:]

  init(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "asteria/calendar-plan-reminders", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      Task { @MainActor in
        guard let self else { result(FlutterMethodNotImplemented); return }
        await self.handle(call, result: result)
      }
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) async {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "invalid_arguments", message: nil, details: nil))
      return
    }
    if call.method == "cancelOwner", let prefix = args["prefix"] as? String, prefix.hasPrefix(Self.prefix) {
      let inFlight = activeSchedules.keys.filter { $0.hasPrefix(prefix) }
      for id in inFlight { activeSchedules.removeValue(forKey: id) }
      // An add already submitted to the system may not yet appear in its snapshot.
      center.removePendingNotificationRequests(withIdentifiers: inFlight)
      let pending = await center.pendingNotificationRequests().map(\.identifier).filter { $0.hasPrefix(prefix) }
      center.removePendingNotificationRequests(withIdentifiers: pending)
      let delivered = await center.deliveredNotifications().map(\.request.identifier).filter { $0.hasPrefix(prefix) }
      center.removeDeliveredNotifications(withIdentifiers: delivered)
      result(nil)
      return
    }
    guard let id = args["id"] as? String, id.hasPrefix(Self.prefix) else {
      result(FlutterError(code: "invalid_arguments", message: nil, details: nil))
      return
    }
    switch call.method {
    case "scheduledTime":
      if await center.notificationSettings().authorizationStatus == .denied {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        result(nil)
        return
      }
      let request = await center.pendingNotificationRequests().first { $0.identifier == id }
      let trigger = request?.trigger as? UNCalendarNotificationTrigger
      let date = trigger?.nextTriggerDate()
      result(date.map { Int64(($0.timeIntervalSince1970 * 1000).rounded()) })
    case "cancel":
      activeSchedules.removeValue(forKey: id)
      center.removePendingNotificationRequests(withIdentifiers: [id])
      center.removeDeliveredNotifications(withIdentifiers: [id])
      result(nil)
    case "schedule":
      guard let milliseconds = args["at"] as? NSNumber, let title = args["title"] as? String,
            let body = args["body"] as? String else {
        result(FlutterError(code: "invalid_arguments", message: nil, details: nil))
        return
      }
      let date = Date(timeIntervalSince1970: milliseconds.doubleValue / 1000)
      let revision = UUID()
      activeSchedules[id] = revision
      defer { if activeSchedules[id] == revision { activeSchedules.removeValue(forKey: id) } }
      do {
        let authorization = await center.notificationSettings().authorizationStatus
        if authorization == .denied { result("denied"); return }
        if authorization == .notDetermined {
          guard try await center.requestAuthorization(options: [.alert, .sound]) else {
            result("denied")
            return
          }
        }
        let pending = await center.pendingNotificationRequests()
        guard pending.count < 64 || pending.contains(where: { $0.identifier == id }) else {
          result("unavailable")
          return
        }
        guard activeSchedules[id] == revision else { result("unavailable"); return }
        guard date > Date() else { result("past"); return }
        let components = Calendar(identifier: .gregorian).dateComponents(
          [.year, .month, .day, .hour, .minute, .second], from: date
        )
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        result(activeSchedules[id] == revision ? "scheduled" : "unavailable")
      } catch {
        result(FlutterError(code: "schedule_failed", message: nil, details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
