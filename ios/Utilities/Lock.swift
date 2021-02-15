//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct Lock {
  private var mutex = pthread_mutex_t()
  private var attrs = pthread_mutexattr_t()

  init() {
    pthread_mutexattr_init(&attrs)
    pthread_mutexattr_settype(&attrs, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(&mutex, &attrs)
  }

  mutating func lock() {
    pthread_mutex_lock(&mutex)
  }

  mutating func unlock() {
    pthread_mutex_unlock(&mutex)
  }
  
  mutating func runWthLockheld<T>(_ block: () -> T) -> T {
    lock()
    defer { unlock() }
    return block()
  }
}
