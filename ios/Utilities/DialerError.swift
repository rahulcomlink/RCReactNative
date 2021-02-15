//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct DialerErrorDetails {
  private(set) var status: CMSTATUS
  private(set) var text: String

  init(_ status: CMSTATUS, _ text: String) {
    self.status = status
    self.text = text
  }
}

struct DialerInvalidParameterError: Error {
  var details: DialerErrorDetails
  var localizedDescription = "Invalid parameter"
}

struct DialerInvalidStateError: Error {
  var details: DialerErrorDetails
  var localizedDescription = "Invalid state"
}

struct DialerInvalidReference: Error {
  var details: DialerErrorDetails
  var localizedDecription = "Invalid reference"
}

struct DialerSubsystemFailure: Error {
  var details: DialerErrorDetails
  var localizedDescription = "Subsystem failure"
}

