//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct CString {
  let value: UnsafePointer<Int8>

  /// Creates a new instance of CString with the same contents as the given string.
  /// - Parameters:
  //      - from: String whose contents will be used to create the CString.
  init(from: String) {
    value = UnsafePointer(strdup(from))
  }

  /// Releases the memory used to store the C string.
  func release() {
    free(UnsafeMutablePointer(mutating: value))
  }

  /// Utility function that releases several CString instances.
  /// - Parameters:
  ///     - cstsrs: References to CString instances to release.
  static func release(_ cstrs: CString...) {
    for cstr in cstrs {
      cstr.release()
    }
  }
}

