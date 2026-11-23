import AVFoundation
import Flutter
import Speech

final class DictationBridge {
  private struct AudioConfiguration {
    let category: AVAudioSession.Category
    let mode: AVAudioSession.Mode
    let options: AVAudioSession.CategoryOptions
  }

  private let channel: FlutterMethodChannel
  private var sessionID: String?
  private var completion: FlutterResult?
  private var recognizer: SFSpeechRecognizer?
  private var task: SFSpeechRecognitionTask?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var engine: AVAudioEngine?
  private var previousAudio: AudioConfiguration?
  private var hasTap = false
  private var transcript = ""
  private var timer: DispatchWorkItem?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "asteria/dictation", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: nil, details: nil))
        return
      }
      guard let args = call.arguments as? [String: String], let id = args["id"] else {
        result(FlutterError(code: "unavailable", message: nil, details: nil))
        return
      }
      switch call.method {
      case "start":
        self.start(id: id, locale: args["locale"] ?? "ru-RU", result: result)
      case "stop":
        if self.sessionID == id { self.stop(id: id) }
        result(nil)
      case "cancel":
        if self.sessionID == id { self.finish(nil) }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func start(id: String, locale: String, result: @escaping FlutterResult) {
    guard sessionID == nil else {
      result(FlutterError(code: "busy", message: nil, details: nil))
      return
    }
    sessionID = id
    completion = result
    SFSpeechRecognizer.requestAuthorization { [weak self] status in
      DispatchQueue.main.async {
        guard let self, self.sessionID == id else { return }
        guard status == .authorized else {
          self.fail("permission_denied")
          return
        }
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
          DispatchQueue.main.async {
            guard let self, self.sessionID == id else { return }
            guard allowed else {
              self.fail("permission_denied")
              return
            }
            self.listen(id: id, locale: locale)
          }
        }
      }
    }
  }

  private func listen(id: String, locale: String) {
    let preferred = Locale(identifier: locale)
    let fallback = Locale(identifier: preferred.languageCode == "ru" ? "ru-RU" : "en-US")
    guard let recognizer = SFSpeechRecognizer(locale: preferred) ??
            SFSpeechRecognizer(locale: fallback), recognizer.isAvailable else {
      fail("unavailable")
      return
    }
    self.recognizer = recognizer
    let audio = AVAudioSession.sharedInstance()
    previousAudio = AudioConfiguration(
      category: audio.category, mode: audio.mode, options: audio.categoryOptions
    )
    do {
      try audio.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
      try audio.setActive(true)

      let engine = AVAudioEngine()
      self.engine = engine
      let input = engine.inputNode
      let format = input.outputFormat(forBus: 0)
      guard format.sampleRate > 0, format.channelCount > 0 else {
        fail("unavailable")
        return
      }

      let request = SFSpeechAudioBufferRecognitionRequest()
      request.shouldReportPartialResults = true
      request.taskHint = .dictation
      request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
      self.request = request
      input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
        request.append(buffer)
      }
      hasTap = true
      engine.prepare()
      try engine.start()

      task = recognizer.recognitionTask(with: request) { [weak self] result, error in
        DispatchQueue.main.async {
          guard let self, self.sessionID == id else { return }
          if let result {
            self.transcript = result.bestTranscription.formattedString
            if result.isFinal {
              self.finishTranscript(errorCode: "no_speech")
              return
            }
          }
          if error != nil { self.finishTranscript(errorCode: "unavailable") }
        }
      }

      schedule(after: 55) { [weak self] in self?.stop(id: id) }
    } catch {
      fail("unavailable")
    }
  }

  private func stop(id: String) {
    guard let request else {
      finish(nil)
      return
    }
    stopAudio()
    request.endAudio()
    task?.finish()
    schedule(after: 3) { [weak self] in
      guard let self, self.sessionID == id else { return }
      self.finishTranscript(errorCode: "no_speech")
    }
  }

  private func stopAudio() {
    engine?.stop()
    if hasTap { engine?.inputNode.removeTap(onBus: 0) }
    hasTap = false
    engine = nil
  }

  private func schedule(after seconds: TimeInterval, _ action: @escaping () -> Void) {
    timer?.cancel()
    let work = DispatchWorkItem(block: action)
    timer = work
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
  }

  private func finishTranscript(errorCode: String) {
    if transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      fail(errorCode)
    } else {
      finish(transcript)
    }
  }

  private func fail(_ code: String) {
    finish(FlutterError(code: code, message: nil, details: nil))
  }

  private func finish(_ value: Any?) {
    let callback = completion
    sessionID = nil
    completion = nil
    timer?.cancel()
    timer = nil
    stopAudio()
    request?.endAudio()
    task?.cancel()
    request = nil
    task = nil
    recognizer = nil
    transcript = ""
    if let previousAudio {
      let audio = AVAudioSession.sharedInstance()
      try? audio.setActive(false, options: .notifyOthersOnDeactivation)
      try? audio.setCategory(previousAudio.category, mode: previousAudio.mode, options: previousAudio.options)
    }
    previousAudio = nil
    callback?(value)
  }
}
