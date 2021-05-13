//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct EmailAddress: Hashable {
  let _nativePtr: UnsafeMutablePointer<CDBEMAILADDRESS>
  
  /// Unique identifier of the email record.
  var uid: String {
    get { return String(cString: _nativePtr.pointee.uid) }
  }
  
  /// Creation timestamp.
  var timeCreated: Date {
    get { return Date(timeIntervalSince1970: _nativePtr.pointee.time_created) }
  }
  
  /// Last update timestamp.
  var timeUpdated: Date {
    get { return Date(timeIntervalSince1970: _nativePtr.pointee.time_updated) }
  }
  
  /// Unformatted email address.
  var email: String {
    get { return String(cString: _nativePtr.pointee.address) }
    set {
      let x = CString(from: newValue)
      CdbEmailAddressUpdateAddress(_nativePtr, x.value)
    }
  }
  
  /// Optional note attached to the email address.
  var note: String {
    get { return String(cString: _nativePtr.pointee.note) }
    set {
      let x = CString(from: newValue)
      CdbEmailAddressUpdateNote(_nativePtr, x.value)
    }
  }
  
  /// Builds an array of `EmailAddress` elements.
  ///
  /// - Parameters:
  ///   - array: `CDBARRAY` instance containing `CDBEMAILADDRESS` elements.
  ///
  static func fromList(_ list: UnsafeMutablePointer<CDBEMAILADDRESS>?) -> [EmailAddress] {
    var result: [EmailAddress] = []
    var iterator = list
    
    while iterator != nil {
      result.append(EmailAddress(_nativePtr: iterator!))
      iterator = iterator!.pointee.next
    }
    
    return result
  }

  /// Creates a new EmailAddress instance that is attached to the given Client
  /// instance.
  ///
  /// - Parameters:
  ///   - for: contact to which the email address will be attached.
  ///
  static func create(for contact: Contact) -> EmailAddress? {
    var nativePtr: UnsafeMutablePointer<CDBEMAILADDRESS>?
    
    let status = CdbContactAppendEmailAddress(contact._nativePtr, &nativePtr)
    if status != CDB_SUCCESS {
      return nil
    }
    
    return EmailAddress(_nativePtr: nativePtr!)
  }
}
