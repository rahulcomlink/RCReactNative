//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

///
/// # CallInfo
///
/// Provides information about a call.
///
struct CallInfo {
  let handle: CMCALLHANDLE

  /// SIP Call-ID header value, if available.
  var callId: String? {
    var p: UnsafePointer<Int8>? = nil
    return CmCallGetCallIdentifier(handle, &p) == CM_SUCCESS ? String(cString: p!) : nil
  }

  /// Remote party SIP URI, if available.
  var remoteParty: String? {
    var p: UnsafePointer<Int8>? = nil
    return CmCallGetRemoteParty(handle, &p) == CM_SUCCESS ? String(cString: p!) : nil
  }

  /// Remote contact SIP Contact header value, if available.
  var remoteContact: String? {
    var p: UnsafePointer<Int8>? = nil
    return CmCallGetContact(handle, &p) == CM_SUCCESS ? String(cString: p!) : nil
  }
  
  /// Remote party CLID, if available. In SIP terms, the CLID is the user portion of the SIP URI.
  var remoteClid: String? {
    var p: UnsafePointer<Int8>? = nil
    return CmCallGetRemotePartyCLID(handle, &p) == CM_SUCCESS ? String(cString: p!) : nil
  }

  /// Number of seconds since the epoch representing the time when the call
  /// started, if available. If unavalable this property will be equal to 0.
  var timeStarted: UInt64 {
    var t: UInt64 = 0
    return CmCallGetTimes(handle, &t, nil, nil) == CM_SUCCESS ? t : 0
  }

  /// Number of seconds since the epoch representing the time when the call
  /// ended, if available. If unavailable this porperty will be equal to 0.
  var timeEnded: UInt64 {
    var t: UInt64 = 0
    return CmCallGetTimes(handle, nil, &t, nil) == CM_SUCCESS ? t : 0
  }

  /// Number of seconds since the epoch representing the time when the call
  /// was answered, if available. If unavailable this porperty will be equal
  /// to 0.
  var timeAnswered: UInt64 {
    var t: UInt64 = 0
    return CmCallGetTimes(handle, nil, nil, &t) == CM_SUCCESS ? t : 0
  }

  /// Retrieves call status.
  var status: CMCALLSTATUS {
    var t: CMCALLSTATUS = CMCS_NONE
    return CmCallGetStatus(handle, &t) == CM_SUCCESS ? t : CMCS_NONE
  }
  
  var isAnswered: Bool {
    var t: CMCALLSTATUS = CMCS_NONE
    return CmCallGetStatus(handle, &t) == CM_SUCCESS && t == CMCS_ANSWERED
  }

  ///
  /// Creates an instance of CallInfo and binds it too the given CMCALLHANDLE.
  ///
  /// - Parameters:
  ///   - handle: raw SDK handle.
  ///
  init(handle: CMCALLHANDLE) {
    self.handle = handle
  }
}
