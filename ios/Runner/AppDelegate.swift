import Flutter
import AdSupport
import AppTrackingTransparency
import StoreKit
import UIKit

@available(iOS 15.0, *)
private final class StorefrontUpdatesHandler: NSObject, FlutterStreamHandler {
  private var task: Task<Void, Never>?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    task?.cancel()
    task = Task { @MainActor in
      for await storefront in Storefront.updates {
        guard !Task.isCancelled else { break }
        events(storefront.countryCode)
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    task?.cancel()
    task = nil
    return nil
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var practiceAudio: PracticeAudioBridge?
  private var appleTransactionsBridge: AnyObject?
  private var storefrontUpdatesHandler: AnyObject?
  private var storefrontMethodChannel: FlutterMethodChannel?
  private var storefrontEventChannel: FlutterEventChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()
    practiceAudio = PracticeAudioBridge(messenger: messenger)
    if #available(iOS 15.0, *) {
      let bridge = AppleTransactionsBridge()
      bridge.register(messenger: messenger)
      appleTransactionsBridge = bridge
    }
    let analyticsDevice = FlutterMethodChannel(name: "asteria/analytics-device", binaryMessenger: messenger)
    analyticsDevice.setMethodCallHandler { call, result in
      guard call.method == "read" else { result(FlutterMethodNotImplemented); return }
      var context: [String: Any] = ["os": UIDevice.current.systemVersion]
      if let idfv = UIDevice.current.identifierForVendor?.uuidString {
        context["idfv"] = idfv
      }
      if #available(iOS 14, *) {
        let status = ATTrackingManager.trackingAuthorizationStatus
        context["att"] = Int(status.rawValue)
        if status == .authorized {
          let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
          if idfa != "00000000-0000-0000-0000-000000000000" { context["idfa"] = idfa }
        }
      }
      result(context)
    }
    let methodChannel = FlutterMethodChannel(
      name: "asteria/storefront",
      binaryMessenger: messenger
    )
    storefrontMethodChannel = methodChannel
    methodChannel.setMethodCallHandler { call, result in
      // Flutter only emits this method name when kDebugMode is true.
      let isDebugOverride = call.method.hasPrefix("debugGetCurrentStorefront:")
      guard call.method == "getCurrentStorefront" || isDebugOverride else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard #available(iOS 15.0, *) else {
        result(nil)
        return
      }
      if isDebugOverride {
        let override = String(call.method.dropFirst("debugGetCurrentStorefront:".count))
        result(override == "UNAVAILABLE" ? nil : override)
        return
      }
      Task { @MainActor in
        result(await Storefront.current?.countryCode)
      }
    }

    if #available(iOS 15.0, *) {
      let handler = StorefrontUpdatesHandler()
      storefrontUpdatesHandler = handler
      let eventChannel = FlutterEventChannel(
        name: "asteria/storefront-updates",
        binaryMessenger: messenger
      )
      storefrontEventChannel = eventChannel
      eventChannel.setStreamHandler(handler)
    }
  }

}
