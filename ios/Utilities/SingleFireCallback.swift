//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import os.log

struct SingleFireCallback<P> {
  typealias CallbackType = (P?) -> Void

  private var callback: CallbackType?
  private var lock: Lock = Lock()

  init(callback: @escaping CallbackType) {
    self.callback = callback
  }

  mutating func fire(with parameter: P? = nil) {
    lock.lock()
    print("Single FireBack >>> Line 21")
    defer { lock.unlock() }

    precondition(callback != nil, "SingleFireCallback already fired")

    callback!(parameter)
    callback = nil
  }
}

