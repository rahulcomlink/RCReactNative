//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import PushKit

/*
enum PayloadError: Error {
  case requiredFieldsMissing
}

protocol InboundCallDescriptor {
  /// Calling line identifier.
  var clid: String { get }
  
  /// Caller's localized display name.
  var localizedDisplayName: String { get }
  
  /// Set to true if video is possible.
  var hasVideo: Bool { get }
}

struct SimpleCallDescriptor: InboundCallDescriptor {
  /// Calling line identifier. This field is mandatory.
  let clid: String

  /// Caller's localized name. Presence of this field in the payload is optional.
  /// If not present it will be set to the same value as the CLID.
  let localizedDisplayName: String

  /// Set to true if video is expected. Presence of this field in the payload is
  /// optional. If not present it will be set to false.
  let hasVideo: Bool

  /// Creates an instance of `SimpleCallDescriptor` from the given push payload.
  ///
  /// - Parameters:
  ///   - payload: PushKit payload
  ///
  /// - Throws: `PayloadError` on failure.
  ///
  init(_ payload: PKPushPayload) throws {
    let dictionary = payload.dictionaryPayload
    print("Dictinary Payload = \(dictionary)")
    if let v = dictionary["ctsisvcid"] {
      clid = v as! String
    } else {
      throw PayloadError.requiredFieldsMissing
    }
    
    if let v = dictionary["name"] {
      localizedDisplayName = v as! String
    } else {
      localizedDisplayName = clid
    }
    
    if let v = dictionary["hasVideo"] {
      hasVideo = v as! Bool
    } else {
      hasVideo = false
    }
  }
}
*/
