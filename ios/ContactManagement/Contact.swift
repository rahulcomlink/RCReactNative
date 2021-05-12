//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

class Contact {
  
  private static let _logger = Logger(componentName: "Contact")
  
  let _nativePtr: UnsafeMutablePointer<CDBCONTACT>
  
  var phoneNumbers: [PhoneNumber]
  var emailAddresses: [EmailAddress]
  
  init(_ nativePtr: UnsafeMutablePointer<CDBCONTACT>) {
    _nativePtr = nativePtr
    phoneNumbers = PhoneNumber.fromList(nativePtr.pointee.phone_numbers)
    emailAddresses = EmailAddress.fromList(nativePtr.pointee.email_addresses)
  }
  
  deinit {
    //Contact._logger.write("releasing contact: uid=[%@]", type: .debug, uid)
    CdbReleaseContact(_nativePtr)
  }
  
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

  /// Contact's first (given) name.
  var firstName: String {
    get { return String(cString: _nativePtr.pointee.first_name) }
    set {
      let x = CString(from: newValue)
      CdbContactUpdateFirstName(_nativePtr, x.value)
    }
  }
  
  /// Contact's middle name.
  var middleName: String {
    get { return String(cString: _nativePtr.pointee.middle_name) }
    set {
      let x = CString(from: newValue)
      CdbContactUpdateMiddleName(_nativePtr, x.value)
    }
  }
  
  /// Contact's last (family) name.
  var lastName: String {
    get { return String(cString: _nativePtr.pointee.last_name) }
    set {
      let x = CString(from: newValue)
      CdbContactUpdateLastName(_nativePtr, x.value)
    }
  }
  
  /// Contact's company name.
  var companyName: String {
    get { return String(cString: _nativePtr.pointee.company_name) }
    set {
      let x = CString(from: newValue)
      CdbContactUpdateCompanyName(_nativePtr, x.value)
    }
  }
  
  /// Creates a new, empty PhoneNumber instance and appends it to the list of phone
  /// numbers for the contact. The contact must be saved in order for the phone number
  /// entry to become permanent.
  ///
  /// - Returns: new `PhoneNumber` instance on success, or `nil` on failure.
  ///
  func createPhoneNumber() -> PhoneNumber? {
    var nativePtr: UnsafeMutablePointer<CDBPHONENUMBER>?
    
    let status = CdbContactAppendPhoneNumber(_nativePtr, &nativePtr)
    if status != CDB_SUCCESS {
      Contact._logger.write("failed to create phone number", type: .error)
      return nil
    }
    
    let phoneNumber = PhoneNumber(_nativePtr: nativePtr!)
    phoneNumbers.append(phoneNumber)
    
    return phoneNumber
  }
  
  /// Deletes the phone number at the given index.
  ///
  /// - Parameters:
  ///   - at: index of the phone number item that is to be deleted.
  ///
  func deletePhoneNumber(at index: Int) {
    let status = CdbContactDeletePhoneNumber(_nativePtr, phoneNumbers[index]._nativePtr)
    if status == CDB_SUCCESS {
      phoneNumbers.remove(at: index)
    }
  }
  
  /// Creates a new, empty EmailAddress instance and appends it to the list of email
  /// addresses for the contact. The contact must be saved in order for the email address
  /// entry to become permanent.
  ///
  /// - Returns: new `EmailAddress` instance on success, or `nil` on failure.
  ///
  func createEmailAddress() -> EmailAddress? {
    var nativePtr: UnsafeMutablePointer<CDBEMAILADDRESS>?
    
    let status = CdbContactAppendEmailAddress(_nativePtr, &nativePtr)
    if status != CDB_SUCCESS {
      Contact._logger.write("failed to create email address", type: .error)
      return nil
    }
    
    let email = EmailAddress(_nativePtr: nativePtr!)
    emailAddresses.append(email)
    
    return email
  }
  
  /// Deletes the email address add the given index.
  ///
  /// - Parameters:
  ///   - at: index of the email address item that is to be deleted.
  ///
  func deleteEmailAddress(at index: Int) {
    let status = CdbContactDeleteEmailAddress(_nativePtr, emailAddresses[index]._nativePtr)
    if status == CDB_SUCCESS {
      emailAddresses.remove(at: index)
    }
  }
  
  // ---=== Image testing: the following code is to be removed ===---
  
  private static let kImageNames = [ "pitt", "mickey", "bob", "starfish", "gary", "spiderman" ]
  
  static func getPlaceholderImage(for name: String) -> String {
    let index = abs(name.hashValue) % kImageNames.count
    return kImageNames[index]
  }
}
