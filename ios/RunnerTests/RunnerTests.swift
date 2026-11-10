import Flutter
import XCTest
@testable import Runner

@available(iOS 15.0, *)
@MainActor
final class RunnerTests: XCTestCase {
  func testCompleteSnapshotAndEmptySnapshot() async throws {
    let store = FakeAppleTransactions()
    store.receipts = ["one", "two"]
    let bridge = AppleTransactionsBridge(store: store)
    let complete = expectation(description: "complete")
    bridge.handle(FlutterMethodCall(methodName: "currentEntitlements", arguments: nil)) { value in
      XCTAssertEqual(value as? [String], ["one", "two"]); complete.fulfill()
    }
    await fulfillment(of: [complete], timeout: 1)
    store.receipts = []
    let empty = expectation(description: "empty")
    bridge.handle(FlutterMethodCall(methodName: "currentEntitlements", arguments: nil)) { value in
      XCTAssertEqual(value as? [String], []); empty.fulfill()
    }
    await fulfillment(of: [empty], timeout: 1)
  }
  func testErrorsAreNotEmptySnapshots() async {
    let store = FakeAppleTransactions(); store.error = true
    let bridge = AppleTransactionsBridge(store: store)
    let done = expectation(description: "error")
    bridge.handle(FlutterMethodCall(methodName: "currentEntitlements", arguments: nil)) { value in
      XCTAssertNotNil(value as? FlutterError); done.fulfill()
    }
    await fulfillment(of: [done], timeout: 1)
  }
  func testExactFinishHistoryAndMissing() async {
    let store = FakeAppleTransactions()
    store.unfinished = [AppleNativeTransaction(id: "other", finish: {})]
    var finished = 0
    store.history = [AppleNativeTransaction(id: "exact", finish: { finished += 1 })]
    let bridge = AppleTransactionsBridge(store: store)
    let done = expectation(description: "history")
    bridge.handle(FlutterMethodCall(methodName: "finish", arguments: ["transactionId": "exact"])) { value in
      XCTAssertEqual(value as? String, "already_finished"); done.fulfill()
    }
    await fulfillment(of: [done], timeout: 1)
    XCTAssertEqual(finished, 1)
    let missing = expectation(description: "missing")
    bridge.handle(FlutterMethodCall(methodName: "finish", arguments: ["transactionId": "missing"])) { value in
      XCTAssertEqual(value as? String, "not_present"); missing.fulfill()
    }
    await fulfillment(of: [missing], timeout: 1)
  }
  func testFinishErrorAndMalformedArgumentsComplete() async {
    let store = FakeAppleTransactions()
    store.unfinished = [AppleNativeTransaction(id: "exact", finish: { throw FakeError.failed })]
    let bridge = AppleTransactionsBridge(store: store)
    let failed = expectation(description: "finish error")
    bridge.handle(FlutterMethodCall(methodName: "finish", arguments: ["transactionId": "exact"])) { value in
      XCTAssertNotNil(value as? FlutterError); failed.fulfill()
    }
    let malformed = expectation(description: "malformed")
    bridge.handle(FlutterMethodCall(methodName: "finish", arguments: [:])) { value in
      XCTAssertNotNil(value as? FlutterError); malformed.fulfill()
    }
    await fulfillment(of: [failed, malformed], timeout: 1)
  }
  func testExactUnfinishedTransactionFinishesWithoutHistoryLookup() async {
    let store = FakeAppleTransactions()
    var finished = 0
    store.unfinished = [AppleNativeTransaction(id: "exact", finish: { finished += 1 })]
    let bridge = AppleTransactionsBridge(store: store)
    let done = expectation(description: "unfinished")
    bridge.handle(FlutterMethodCall(methodName: "finish", arguments: ["transactionId": "exact"])) { value in
      XCTAssertEqual(value as? String, "finished"); done.fulfill()
    }
    await fulfillment(of: [done], timeout: 1)
    XCTAssertEqual(finished, 1)
    XCTAssertEqual(store.historyLookups, 0)
  }
  func testLookupErrorCompletesWithErrorNotMissing() async {
    let store = FakeAppleTransactions(); store.error = true
    let bridge = AppleTransactionsBridge(store: store)
    let done = expectation(description: "lookup error")
    bridge.handle(FlutterMethodCall(methodName: "finish", arguments: ["transactionId": "exact"])) { value in
      XCTAssertNotNil(value as? FlutterError); done.fulfill()
    }
    await fulfillment(of: [done], timeout: 1)
  }
  func testIndependentTimeoutAndLateCompletionCallExactlyOnce() async {
    let store = FakeAppleTransactions(); store.delay = 100_000_000
    let bridge = AppleTransactionsBridge(store: store, timeout: 0.01)
    var calls = 0
    let timedOut = expectation(description: "timeout")
    bridge.handle(FlutterMethodCall(methodName: "currentEntitlements", arguments: nil)) { value in
      calls += 1; XCTAssertNotNil(value as? FlutterError); timedOut.fulfill()
    }
    await fulfillment(of: [timedOut], timeout: 1)
    try? await Task.sleep(nanoseconds: 200_000_000)
    XCTAssertEqual(calls, 1)
  }
}
private enum FakeError: Error { case failed }
@available(iOS 15.0, *)
@MainActor
private final class FakeAppleTransactions: AppleTransactionsStore {
  var receipts: [String] = []
  var unfinished: [AppleNativeTransaction] = []
  var history: [AppleNativeTransaction] = []
  var historyLookups = 0
  var error = false
  var delay: UInt64 = 0
  func currentEntitlements() async throws -> [String] {
    if delay > 0 { try? await Task.sleep(nanoseconds: delay) }
    if error { throw FakeError.failed }
    return receipts
  }
  func unfinishedTransactions() async throws -> [AppleNativeTransaction] { if error { throw FakeError.failed }; return unfinished }
  func historicalTransaction(id: String) async throws -> AppleNativeTransaction? { historyLookups += 1; if error { throw FakeError.failed }; return history.first { $0.id == id } }
}
