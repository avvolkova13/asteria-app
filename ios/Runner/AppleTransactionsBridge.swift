import Flutter
import StoreKit

@available(iOS 15.0, *)
@MainActor
struct AppleNativeTransaction {
  let id: String
  let finish: () async throws -> Void
}

@available(iOS 15.0, *)
@MainActor
protocol AppleTransactionsStore {
  func currentEntitlements() async throws -> [String]
  func unfinishedTransactions() async throws -> [AppleNativeTransaction]
  func historicalTransaction(id: String) async throws -> AppleNativeTransaction?
}

@available(iOS 15.0, *)
@MainActor
private final class StoreKitTransactionsStore: AppleTransactionsStore {
  private enum VerificationFailure: Error { case unverified }
  func currentEntitlements() async throws -> [String] {
    var snapshot: [String] = []
    for await result in Transaction.currentEntitlements {
      guard case .verified = result else { throw VerificationFailure.unverified }
      snapshot.append(result.jwsRepresentation)
    }
    return snapshot
  }
  func unfinishedTransactions() async throws -> [AppleNativeTransaction] {
    var snapshot: [AppleNativeTransaction] = []
    for await result in Transaction.unfinished {
      guard case .verified(let transaction) = result else { throw VerificationFailure.unverified }
      snapshot.append(AppleNativeTransaction(id: String(transaction.id), finish: { await transaction.finish() }))
    }
    return snapshot
  }
  func historicalTransaction(id: String) async throws -> AppleNativeTransaction? {
    for await result in Transaction.all {
      guard case .verified(let transaction) = result else { throw VerificationFailure.unverified }
      if String(transaction.id) == id {
        return AppleNativeTransaction(id: id, finish: { await transaction.finish() })
      }
    }
    return nil
  }
}

/// Small app-local adapter: complete snapshots and explicit exact finish outcomes.
/// A separate deadline completes Flutter even if StoreKit ignores cancellation.
@available(iOS 15.0, *)
@MainActor
final class AppleTransactionsBridge {
  private let store: AppleTransactionsStore
  private let timeout: TimeInterval
  private var channel: FlutterMethodChannel?

  init(store: AppleTransactionsStore? = nil, timeout: TimeInterval = 25) {
    self.store = store ?? StoreKitTransactionsStore()
    self.timeout = timeout
  }
  func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "asteria/apple-transactions", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "bridge_unavailable", message: "Apple transaction bridge unavailable", details: nil)); return
      }
      self.handle(call, result: result)
    }
  }
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "currentEntitlements" || call.method == "finish" else {
      result(FlutterMethodNotImplemented); return
    }
    let target = (call.arguments as? [String: Any])?["transactionId"] as? String
    if call.method == "finish" && (target == nil || target!.isEmpty) {
      result(FlutterError(code: "invalid_arguments", message: "Exact transaction ID required", details: nil)); return
    }
    let gate = CompletionGate(result)
    // Do not use a task group: its scope could wait forever for StoreKit.
    DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
      gate.complete(FlutterError(code: "apple_timeout", message: "Apple transaction status is still unknown", details: nil))
    }
    Task { @MainActor [store] in
      do {
        if call.method == "currentEntitlements" {
          gate.complete(try await store.currentEntitlements())
        } else if let target {
          if let transaction = try await store.unfinishedTransactions().first(where: { $0.id == target }) {
            try await transaction.finish()
            gate.complete("finished")
          } else if let transaction = try await store.historicalTransaction(id: target) {
            // Verified exact history is present. Idempotently finish again;
            // absence in unfinished alone is never sufficient evidence.
            try await transaction.finish()
            gate.complete("already_finished")
          } else {
            gate.complete("not_present")
          }
        }
      } catch {
        gate.complete(FlutterError(code: "apple_transaction_error", message: "Apple transaction operation could not be confirmed", details: nil))
      }
    }
  }
}

@MainActor
private final class CompletionGate {
  private var result: FlutterResult?
  init(_ result: @escaping FlutterResult) { self.result = result }
  func complete(_ value: Any?) {
    guard let callback = result else { return }
    result = nil
    callback(value)
  }
}
