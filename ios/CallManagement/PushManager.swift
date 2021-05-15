//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import PushKit
import os.log
import UIKit
///
/// Push management.
///
class PushManager {
  // The one and only instance of PushManager
  static let shared = PushManager()
  
  private let _logger = Logger(componentName: "PKPushManager")
  private let _registry = PKPushRegistry(queue: DispatchQueue.main)
  private let _delegate = PKPushRegistryDelegateImpl()
  private var _isPushTokenAvailable =  BlockingBarrier<Bool>(withInitalValue: false)
  
  private(set) var pushToken: String?

  private init() {
  }
  
  /// Retrieves the value of the push token, if available. If the token is unavailable
  /// The current thread will block until the token becomes available.
  func fetchPushToken() -> String {
    _isPushTokenAvailable.wait(untilEqualTo: true)
    return pushToken!
  }
  
  fileprivate func onPushTokenInvalidated() {
    // The push token is no longer valid. Reset the barrier and the token.
    _isPushTokenAvailable.setAndNotify(newValue: false)
    
    pushToken = nil
    
    _logger.write("token invalidated", type: .debug)
  }
  
  fileprivate func onPushTokenUpdated(_ pushCredentials: PKPushCredentials) {
    // Convert the token into a readable format (hex)
    pushToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    
    // Let everyone know that the push token is available
    _isPushTokenAvailable.setAndNotify(newValue: true)
    
    _logger.write("token=[%@]", type: .debug, pushToken!)
  }
  
  func onPushArrived(_ payload: PKPushPayload) {
    _logger.write("push received", type: .debug)
    NSLog("payload localized %@", payload.dictionaryPayload)
    do {
      // Try to build an inbound call descriptor from the payload. If that is not
      // possible the InboundCallDescriptor constructor will throw.
      let descriptor = try InboundCallDescriptor(payload)
      CallManager.shared.onPushArrived(descriptor: descriptor)
      
      _logger.write("push received", type: .debug)
    } catch {
      // Silently ignore invalid payloads.
    }
  }

  ///
  /// Starts the Push manager
  ///
  func start() {
    _registry.delegate = _delegate
    _registry.desiredPushTypes = [.voIP]
  }
}

///
/// PKPushRegistryDelegate implementation.
///
private class PKPushRegistryDelegateImpl: NSObject, PKPushRegistryDelegate {
  
  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    if type == .voIP {
      PushManager.shared.onPushTokenInvalidated()
    }
  }

  func pushRegistry(
    _ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    if type == .voIP {
      PushManager.shared.onPushTokenUpdated(pushCredentials)
    }
  }

  func pushRegistry(
    _ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType, completion: @escaping () -> Void
  ) {
    
    if type == .voIP {
      PushManager.shared.onPushArrived(payload)
      completion()
    }
  }
}
