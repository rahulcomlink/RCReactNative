//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

enum BlockingBarrierError: Error {
  case timeout
  case unexpectedValue
}

struct BlockingBarrier<T> where T: Equatable {
  private var condition: NSCondition = NSCondition()

  private var value: T

  ///
  /// Initializes the blocking barrier.
  ///
  /// - Parameters:
  ///     - value: Value to initalize the barrier with.
  ///
  init(withInitalValue value: T) {
    self.value = value
  }

  func isEqualTo(_ value: T) -> Bool {
    return self.value == value
  }

  /// Assigns a value to the barrier and wakes any threads that may be waiting
  /// for the condition to change. Note that the threads will be awakened even
  /// if the new value is the same as the current value.
  ///
  /// - Parameters:
  ///   - newValue: New value to assign to the barrier.
  mutating func setAndNotify(newValue: T) {
    condition.lock()
    defer { condition.unlock() }

    value = newValue
    
    condition.broadcast()
  }

  /// Assigns a value to the barrier and wakes any threads that may be waiting
  /// for the condition to change. The value will be assigned only if the current
  /// value of the barrier matches the expected value.
  ///
  /// - Parameters:
  ///   - expectedValue:  the expected value
  ///   - newValue:       new value to assign to the barrier
  ///
  /// - Returns: true if the value was successfully assigned or false otherwise.
  mutating func setAndNotify(expectedValue: T, newValue: T) -> Bool {
    condition.lock()
    defer { condition.unlock() }

    if value != expectedValue {
      return false
    }

    value = newValue
    
    condition.broadcast()

    return true
  }

  /// Waits until the blocking barrier's value is changed to the expected value.
  ///
  /// - Parameters:
  ///   - untilEqualTo: the expected value
  ///   - for:          how long to wait before giving up
  ///
  /// - Returns: true if the current barrier value is equal to the expected value
  ///            or false in case of timeout.
  mutating func wait(untilEqualTo expectedValue: T, timeout: TimeInterval) -> Bool {
    condition.lock()
    defer { condition.unlock() }

    let timepoint = Date() + timeout

    while value != expectedValue {
      if !condition.wait(until: timepoint) {
        return false
      }
    }

    return true
  }

  /// Waits until the blocking barrier's value is changed to the expected value.
  /// This function, unlike the `wait`variant will throw on timeout.
  ///
  /// - Parameters:
  ///   - untilEqualTo: the expected value
  ///   - for: how long to wait before giving up
  ///
  ///  - Throws: `BlockingBarrierError.timeout` on timeout
  mutating func waitAndThrowOnTimeout(untilEqualTo expectedValue: T, timeout: TimeInterval) throws {
    if !wait(untilEqualTo: expectedValue, timeout: timeout) {
      throw BlockingBarrierError.timeout
    }
  }

  ///
  /// Waits until the blocking barrier's value is changed to the expected value.
  ///
  /// - Parameters:
  ///     - untilEqualTo: the expected value
  ///
  mutating func wait(untilEqualTo expectedValue: T) {
    condition.lock()
    defer { condition.unlock() }

    while value != expectedValue {
      condition.wait()
    }
  }
}
