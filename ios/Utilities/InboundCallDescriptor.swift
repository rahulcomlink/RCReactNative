//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import PushKit

enum PayloadError: Error {
  case requiredFieldsMissing
  case badPayload
}

struct InboundCallDescriptor {
  /// Calling line identifier. This field is mandatory.
  let clid: String

  /// Caller's localized name. Presence of this field in the payload is optional.
  /// If not present it will be set to the same value as the CLID.
  let localizedDisplayName: String

  /// Set to true if video is expected. Presence of this field in the payload is
  /// optional. If not present it will be set to false.
  let hasVideo: Bool = false

  /// Creates an instance of `SimpleCallDescriptor` from the given push payload.
  ///
  /// - Parameters:
  ///   - payload: PushKit payload
  ///
  /// - Throws: `PayloadError` on failure.
  ///
  init(_ payload: PKPushPayload) throws {
    let dictionary = payload.dictionaryPayload
  
    // "url" is the only key that we care about at this point.
    guard let urlVal = dictionary["url"] else {
      throw PayloadError.requiredFieldsMissing
    }
    
    guard let url = URL(string: urlVal as! String) else {
      throw PayloadError.badPayload
    }
   
    let substring = (urlVal as! String).replacingOccurrences(of: "pigeon://incomingcall/", with: "")
    if let phoneNo : String = substring.replacingOccurrences(of: "?proxy=testsipcc.mvoipctsi.com&sound=ring.wav", with: "") as? String{
           print("phoneNo = \(phoneNo)")
    clid = phoneNo
    localizedDisplayName = clid
    }else {
      clid = "Unknown"
      localizedDisplayName = clid
    }
   
   // clid = url.pathComponents[0]
    
    
  }
}

/*
#if LOCAL_TESTING

struct InboundCallDescriptor {
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
    if let v = dictionary["clid"] {
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

#elseif SESSION_MANAGER

/*
{
  "ctsisvcid":"TljdC4EQFQHO21w9zXl3-Osx4vz1vOIf",
  "aps":{
    "badge":1,
    "alert":{
      "body":"Incoming+Call",
      "title":"Incoming+Call"
    }
  },
  "vcardurl":"",
   "tag_line":"",
   "url":"xone://incomingcall/14162943254?proxy=newxonesip.mvoipctsi.com&sound=ring.wav",
   "ctsisvcurl":"https://sandbox.mvoipctsi.com:38443/ctsiSvcMgr/svcs/pushresp"}
 */
struct InboundCallDescriptor {
  /// Calling line identifier. This field is mandatory.
  let clid: String

  /// Caller's localized name. Presence of this field in the payload is optional.
  /// If not present it will be set to the same value as the CLID.
  let localizedDisplayName: String

  /// Set to true if video is expected. Presence of this field in the payload is
  /// optional. If not present it will be set to false.
  let hasVideo: Bool = false

  /// Creates an instance of `SimpleCallDescriptor` from the given push payload.
  ///
  /// - Parameters:
  ///   - payload: PushKit payload
  ///
  /// - Throws: `PayloadError` on failure.
  ///
  init(_ payload: PKPushPayload) throws {
    let dictionary = payload.dictionaryPayload
  
    // "url" is the only key that we care about at this point.
    guard let urlVal = dictionary["url"] else {
      throw PayloadError.requiredFieldsMissing
    }
    
    guard let url = URL(string: urlVal as! String) else {
      throw PayloadError.badPayload
    }
   
    clid = url.pathComponents[0]
    
    localizedDisplayName = clid
  }
}

#endif
*/
