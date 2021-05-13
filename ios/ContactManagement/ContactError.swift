//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//


import Foundation

struct ContactErrorDetails {
  private(set) var status: CDB_STATUS
  private(set) var text: String

  init(_ status: CDB_STATUS, _ text: String) {
    self.status = status
    self.text = text
  }
}

struct ContactInvalidParameterError: Error {
  var details: ContactErrorDetails
  var localizedDescription = "Invalid parameter"
}

struct ContactInvalidStateError: Error {
  var details: ContactErrorDetails
  var localizedDescription = "Invalid state"
}

struct ContactInvalidReference: Error {
  var details: ContactErrorDetails
  var localizedDecription = "Invalid reference"
}

struct ContactSubsystemFailure: Error {
  var details: ContactErrorDetails
  var localizedDescription = "Subsystem failure"
}

