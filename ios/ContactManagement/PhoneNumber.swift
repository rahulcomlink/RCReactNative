//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

struct PhoneNumber: Hashable {
  let _nativePtr: UnsafeMutablePointer<CDBPHONENUMBER>
  
  /// Unique identifier of the phone number record.
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
  
  /// Unformatted phone number.
  var number: String {
    get { return String(cString: _nativePtr.pointee.number) }
    set {
      let x = CString(from: newValue)
      CdbPhoneNumberUpdateNumber(_nativePtr, x.value)
    }
  }
  
  /// Optional phone number type. This value can be anything.
  var type: String {
    get { return String(cString: _nativePtr.pointee.type) }
    set {
      let x = CString(from: newValue)
      CdbPhoneNumberUpdateType(_nativePtr, x.value)
    }
  }
  
  /// Optional note attached to the phone number. This value can be anything.
  var note: String {
    get { return String(cString: _nativePtr.pointee.note) }
    set {
      let x = CString(from: newValue)
      CdbPhoneNumberUpdateNote(_nativePtr, x.value)
    }
  }
  
  /// Builds an array of `PhoneNumber` elements.
  ///
  /// - Parameters:
  ///   - array: `CDBARRAY` instance containing `CDBPHONENUMBER` elements.
  ///
  static func fromList(_ list: UnsafeMutablePointer<CDBPHONENUMBER>?) -> [PhoneNumber] {
    var result: [PhoneNumber] = []
    var iterator = list
    
    while iterator != nil {
      result.append(PhoneNumber(_nativePtr: iterator!))
      iterator = iterator!.pointee.next
    }
    
    return result
  }
  
  /// Creates a new PhoneNumber instance that is attached to the given Client
  /// instance.
  ///
  /// - Parameters:
  ///   - for: contact to which the phone number will be attached.
  ///
  static func create(for contact: Contact) -> PhoneNumber? {
    var nativePtr: UnsafeMutablePointer<CDBPHONENUMBER>?
    let status = CdbContactAppendPhoneNumber(contact._nativePtr, &nativePtr)
    return status == CDB_SUCCESS ? PhoneNumber(_nativePtr: nativePtr!) : nil
  }
}

