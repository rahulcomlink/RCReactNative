//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct Isomorphism<A, B> where A: Hashable, B: Hashable {
  private var _lock = Lock()
  private var _a2bMap: [A: B] = [:]
  private var _b2aMap: [B: A] = [:]
  
  subscript(_ b: B) -> A? {
    /// Retrieves the A value that maps to the given B value.
    mutating get {
    //  return _lock.runWthLockheld { _b2aMap[b]! }
        return _lock.runWthLockheld { _b2aMap[b] }
    }
    
    /// Maps the given B value to the given A value. Both values must
    /// be unique.
    set(a) {
      if let a = a {
        insert(a, b)
      } else {
        _lock.runWthLockheld {
          let a = _b2aMap[b]!
          _a2bMap.removeValue(forKey: a)
          _b2aMap.removeValue(forKey: b)
        }
      }
    }
  }
  
  subscript(_ a: A) -> B? {
    /// Retrieves the B value that maps to the given A value.
    mutating get {
      return _lock.runWthLockheld { _a2bMap[a] }
    }
    
    /// Maps the given A value to the given B value. Both values must
    /// be unique.
    set(b) {
      if let b = b {
        insert(a, b)
      } else {
        _lock.runWthLockheld {
          let b = _a2bMap[a]!
          _a2bMap.removeValue(forKey: a)
          _b2aMap.removeValue(forKey: b)
        }
      }
    }
  }
  
  mutating private func insert(_ a: A, _ b: B) {
    _lock.runWthLockheld {
      precondition(_a2bMap[a] == nil, "Values must be unique (A)")
      precondition(_b2aMap[b] == nil, "Values must be unique (B)")
      _a2bMap[a] = b
      _b2aMap[b] = a
    }
  }
}
