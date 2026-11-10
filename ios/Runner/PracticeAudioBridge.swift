import AVFoundation
import Flutter

final class PracticeAudioBridge: NSObject, AVAudioPlayerDelegate {
  private let channel: FlutterMethodChannel
  private let asset = "assets/audio/practice-75.wav"
  private var player: AVAudioPlayer?
  private var session: Int?
  private var complete = false
  private var sessionActive = false

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "asteria/practice-audio", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(interruption), name: AVAudioSession.interruptionNotification, object: nil)
    center.addObserver(self, selector: #selector(routeChanged), name: AVAudioSession.routeChangeNotification, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    channel.setMethodCallHandler(nil)
    releasePlayer()
  }

  private func audioURL() throws -> URL {
    let key = FlutterDartProject.lookupKey(forAsset: asset)
    guard let url = Bundle.main.url(forResource: key, withExtension: nil) else {
      throw CocoaError(.fileNoSuchFile)
    }
    return url
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    guard let owner = args?["session"] as? Int else {
      result(FlutterError(code: "bad-request", message: "Missing playback session", details: nil))
      return
    }
    do {
      switch call.method {
      case "load":
        releasePlayer()
        let next = try AVAudioPlayer(contentsOf: audioURL())
        next.delegate = self
        session = owner
        player = next
      case "close":
        if session == owner { releasePlayer() }
        result(nil)
        return
      default:
        guard session == owner, let player = player else { result(nil); return }
        switch call.method {
        case "toggle":
          if player.isPlaying {
            pause()
          } else {
            if complete || player.currentTime >= player.duration {
              player.currentTime = 0
              complete = false
            }
            let audio = AVAudioSession.sharedInstance()
            try audio.setCategory(.playback, mode: .spokenAudio)
            try audio.setActive(true)
            sessionActive = true
            guard player.play() else {
              deactivateSession()
              throw CocoaError(.fileReadCorruptFile)
            }
          }
        case "pause":
          pause()
        case "seek":
          let requested = Double(args?["ms"] as? Int ?? 0) / 1000
          let target = min(max(0, requested), player.duration)
          complete = target >= player.duration
          if complete { pause() }
          player.currentTime = target
        case "loop":
          player.numberOfLoops = args?["value"] as? Bool == true ? -1 : 0
        case "state": break
        default: result(FlutterMethodNotImplemented); return
        }
      }
      guard let player = player else { result(nil); return }
      let position = complete ? player.duration : player.currentTime
      result(["position": Int((position * 1000).rounded()),
              "duration": Int((player.duration * 1000).rounded()),
              "playing": player.isPlaying, "loop": player.numberOfLoops != 0,
              "complete": complete])
    } catch {
      result(FlutterError(code: "practice-audio", message: error.localizedDescription, details: nil))
    }
  }

  private func deactivateSession() {
    guard sessionActive else { return }
    sessionActive = false
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  private func pause() {
    player?.pause()
    deactivateSession()
  }

  private func releasePlayer() {
    player?.delegate = nil
    player?.stop()
    player = nil
    deactivateSession()
    session = nil
    complete = false
  }

  @objc private func interruption(_ note: Notification) {
    guard let type = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
          type == AVAudioSession.InterruptionType.began.rawValue else { return }
    DispatchQueue.main.async { [weak self] in self?.pause() }
  }

  @objc private func routeChanged(_ note: Notification) {
    guard let reason = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
          reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue else { return }
    DispatchQueue.main.async { [weak self] in self?.pause() }
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    guard self.player === player else { return }
    complete = flag
    deactivateSession()
  }
}
