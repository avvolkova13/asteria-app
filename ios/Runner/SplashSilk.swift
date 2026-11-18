import AVFoundation
import Flutter
import UIKit

/// Keep the silk moving across the native-to-Flutter handoff. The foreground
/// has its own playback clock, with one pass followed by the held final frame.
private final class SilkPlayback {
  static let shared = SilkPlayback()
  private var player: AVQueuePlayer?
  private var looper: AVPlayerLooper?
  private let layer = AVPlayerLayer()
  private var readiness: NSKeyValueObservation?
  private weak var surface: SilkSurface?
  private var artworkPlayer: AVPlayer?
  private let artworkLayer = AVPlayerLayer()

  private func prepareArtwork() {
    guard let url = Bundle.main.url(forResource: "SplashArtwork", withExtension: "mov") else { return }
    let player = AVPlayer(url: url)
    player.isMuted = true
    player.preventsDisplaySleepDuringVideoPlayback = false
    player.automaticallyWaitsToMinimizeStalling = false
    player.actionAtItemEnd = .pause
    artworkLayer.isOpaque = false
    artworkLayer.opacity = 0
    artworkLayer.backgroundColor = UIColor.clear.cgColor
    artworkLayer.videoGravity = .resize
    artworkLayer.player = player
    artworkPlayer = player
  }

  func startArtwork() -> Bool {
    guard surface?.window != nil, !UIAccessibility.isReduceMotionEnabled,
          let player = artworkPlayer, player.currentItem?.status == .readyToPlay
    else { return false }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    artworkLayer.opacity = 1
    CATransaction.commit()
    player.playImmediately(atRate: 1)
    #if DEBUG
    NSLog("Asteria splash: playing prepared artwork")
    #endif
    return true
  }

  func stopArtwork() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    artworkLayer.opacity = 0
    CATransaction.commit()
    artworkPlayer?.pause()
    artworkPlayer?.seek(to: .zero)
  }

  private func sizeLayers(in bounds: CGRect) {
    layer.frame = bounds
    let side = min(bounds.width * 0.49, bounds.height * 0.32)
    artworkLayer.frame = CGRect(x: bounds.midX - side * 0.60,
                                y: bounds.minY + bounds.height * 0.4 - side * 0.51,
                                width: side * 1.20, height: side * 1.42)
  }

  func attach(to next: SilkSurface) {
    guard !UIAccessibility.isReduceMotionEnabled,
          let url = Bundle.main.url(forResource: "SplashSilk", withExtension: "mp4")
    else { return }
    if next.isNativeLaunch && surface?.isNativeLaunch == false { return }
    if player == nil {
      let queue = AVQueuePlayer()
      queue.isMuted = true
      queue.preventsDisplaySleepDuringVideoPlayback = false
      queue.automaticallyWaitsToMinimizeStalling = false
      looper = AVPlayerLooper(player: queue, templateItem: AVPlayerItem(url: url))
      player = queue
      layer.opacity = 0
      layer.player = queue
      layer.videoGravity = .resizeAspectFill
      layer.backgroundColor = UIColor.clear.cgColor
      readiness = layer.observe(\.isReadyForDisplay, options: [.initial, .new]) {
        [weak self, weak queue] layer, _ in
        guard layer.isReadyForDisplay else { return }
        DispatchQueue.main.async {
          guard let self, let queue, self.player === queue, self.layer.opacity == 0 else { return }
          // The decoder may deliver its first frame after the launch poster
          // is visible. Blend it in rather than exposing a later frame at once.
          let fade = CABasicAnimation(keyPath: "opacity")
          fade.fromValue = 0
          fade.toValue = 1
          fade.duration = 0.45
          fade.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
          CATransaction.begin()
          CATransaction.setDisableActions(true)
          self.layer.opacity = 1
          self.layer.add(fade, forKey: "silkEntrance")
          CATransaction.commit()
          self.readiness = nil
        }
      }
    }

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    if surface !== next {
      if surface?.isNativeLaunch == true { surface?.isHidden = true }
      layer.removeFromSuperlayer()
      next.layer.addSublayer(layer)
      next.layer.addSublayer(artworkLayer)
      surface = next
    }
    sizeLayers(in: next.bounds)
    CATransaction.commit()
    player?.play()
    if artworkPlayer == nil {
      DispatchQueue.main.async { [weak self] in
        guard let self, self.player != nil, self.artworkPlayer == nil else { return }
        self.prepareArtwork()
      }
    }
  }

  func layout(_ view: SilkSurface) {
    guard surface === view else { return }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    sizeLayers(in: view.bounds)
    CATransaction.commit()
  }

  func detach(from view: SilkSurface) {
    guard surface === view else { return }
    // UIKit can briefly detach a platform view while transferring it to the
    // composited Flutter scene. Retain its media time across that transfer.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
      guard let self, self.surface?.window == nil else { return }
      self.artworkPlayer?.pause()
      self.artworkLayer.removeFromSuperlayer()
      self.artworkLayer.player = nil
      self.artworkPlayer = nil
      self.player?.pause()
      self.readiness = nil
      self.layer.removeAnimation(forKey: "silkEntrance")
      self.layer.player = nil
      self.layer.removeFromSuperlayer()
      self.looper = nil
      self.player = nil
      self.surface = nil
    }
  }
}

private final class SilkSurface: UIImageView {
  let isNativeLaunch: Bool
  init(frame: CGRect, nativeLaunch: Bool) {
    isNativeLaunch = nativeLaunch
    super.init(frame: frame)
    image = UIImage(named: "SplashSilk")
    contentMode = .scaleAspectFill
    clipsToBounds = true
    isUserInteractionEnabled = false
    accessibilityElementsHidden = true
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  required init?(coder: NSCoder) { fatalError("Create SilkSurface programmatically") }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil { SilkPlayback.shared.attach(to: self) }
    else { SilkPlayback.shared.detach(from: self) }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    SilkPlayback.shared.layout(self)
  }
}

@objc(AsteriaLaunchViewController)
final class AsteriaLaunchViewController: FlutterViewController {
  override func loadView() {
    if !UIAccessibility.isReduceMotionEnabled {
      splashScreenView = SilkSurface(frame: .zero, nativeLaunch: true)
    }
    super.loadView()
  }
}

private final class FlutterSilkSurface: NSObject, FlutterPlatformView {
  private let surface: SilkSurface
  init(frame: CGRect) { surface = SilkSurface(frame: frame, nativeLaunch: false) }
  func view() -> UIView { surface }
}

final class SplashSilkFactory: NSObject, FlutterPlatformViewFactory {
  init(messenger: FlutterBinaryMessenger) {
    super.init()
    FlutterMethodChannel(name: "asteria/launch-artwork", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        switch call.method {
        case "start": result(SilkPlayback.shared.startArtwork())
        case "stop":
          SilkPlayback.shared.stopArtwork()
          result(nil)
        default: result(FlutterMethodNotImplemented)
        }
      }
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64,
              arguments args: Any?) -> FlutterPlatformView {
    FlutterSilkSurface(frame: frame)
  }
}
