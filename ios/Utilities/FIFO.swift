//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct FIFO<T> where T: Equatable {
  private var _lock = Lock()
  private var _items: [T] = []
  
  mutating func push(_ item: T) {
    _lock.runWthLockheld { _items.append(item) }
  }
  
  mutating func pop() -> T? {
    _lock.runWthLockheld { _items.isEmpty ? nil : _items.removeFirst() }
  }
  
  mutating func remove(_ item: T) -> Bool {
    _lock.runWthLockheld {
      guard let n = _items.firstIndex(of: item) else { return false }
      _items.remove(at: n)
      return true
    }
  }
}
