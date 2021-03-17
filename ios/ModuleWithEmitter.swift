//
//  ModuleWithEmitter.swift
//  RocketChatRN
//
//  Created by Arti Mane on 12/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
@objc(ModuleWithEmitter)
open class ModuleWithEmitter: RCTEventEmitter {

  public static var emitter: RCTEventEmitter!

  override init() {
    super.init()
    ModuleWithEmitter.emitter = self
  }
  
    var hasListener: Bool = false

  open override func startObserving() {
       hasListener = true
     }

  open override func stopObserving() {
       hasListener = false
     }
  
  @objc public override static func requiresMainQueueSetup() -> Bool {
      return true;
    }

  open override func supportedEvents() -> [String] {
    ["onSessionConnect", "onPending", "onFailure","getInboundCall","VoipCall","testCall"]
  }
}
