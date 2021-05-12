//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import Contacts

class ContactManager {
  private let _logger = Logger(componentName: "ContactManager")
  
  /// The one and only instance of ContactManager
  static let shared = ContactManager()
  
  /// Published list of contacts (filtered)
  var filteredContacts: [ContactReference] = []
  
  /// Published current contact filter expression
  var filterExpression: String = ""
  
//  private var _dispatchQueue = DispatchQueue(label: "ContactManager-DispatchQueue")
  
  /// Initializes and starts the one and only `ContactManager` instance.
  func start() throws {
    let urls = FileManager.default.urls(for: .allLibrariesDirectory, in: .userDomainMask)
    
    let path = CString(from: urls.first!.path)
    defer { path.release() }
    
    let status = CdbInitialize(nil, path.value, CDB_TRUE)
    if status != CDB_SUCCESS {
      throw ContactSubsystemFailure(details: ContactErrorDetails(status, "Initialization failure"))
    }

    filter()
  }
  
  func shutdown() {
    CdbShutdown()
  }
  
  /// Applies the given filter to the entire contacts collection and updates
  /// the published `filteredContacts` field.
  ///
  /// - Parameters:
  ///   - expression: filter expression.
  ///
  func filter(_ expression: String = "*") {
    _logger.write("expression=[%@]", type: .debug, expression)
    
    filteredContacts = search(firstName:    expression,
                              middleName:   expression,
                              lastName:     expression,
                              email:        expression,
                              phoneNumber:  expression)
    
   
    filterExpression = expression
    sortFilter(fc: filteredContacts)
  }
    
    func sortFilter(fc : [ContactReference]){
        filteredContacts = fc.sorted(by: { (firstContact, secondContact) -> Bool in
            return firstContact.firstName.lowercased() < secondContact.firstName.lowercased()
        })
    }
  
    
  
  
  /// Searches the address book for contacts that match the given parameters. Wildcards are accepted
  /// for all parameters.
  ///
  /// - Parameters:
  ///   - firstName:    First name expression.
  ///   - middleName:   Middle name expression.
  ///   - lastName:     Last name expression.
  ///   - email:        Email expression.
  ///   - phoneNumber:  Phone number expression.
  ///
  /// - Returns: Array of `ContactReference` items matching the search parameters.
  ///
  func search(firstName: String = "", middleName: String = "", lastName: String = "",
              email: String = "", phoneNumber: String = "") -> [ContactReference] {
    let contactMap = ContactMap()
    
    let firstNameExpr   = CString(from: firstName)
    let middleNameExpr  = CString(from: middleName)
    let lastNameExpr    = CString(from: lastName)
    let emailExpr       = CString(from: email)
    let phoneNumberExpr = CString(from: phoneNumber)
    
    defer {
      CString.release(firstNameExpr, middleNameExpr, lastNameExpr, emailExpr, phoneNumberExpr)
    }
    
    var enumerateQuery = CDBENUMERATECONTACTSQUERY(
      first_name:     firstNameExpr.value,
      middle_name:    middleNameExpr.value,
      last_name:      lastNameExpr.value,
      email:          emailExpr.value,
      phone_number:   phoneNumberExpr.value
    )
    
    CdbEnumerateContacts(Unmanaged.passUnretained(contactMap).toOpaque(), &enumerateQuery) { item, userData in
      if let item = item {
        let contactMap = Unmanaged<ContactMap>.fromOpaque(userData!).takeUnretainedValue()
        contactMap.put(queryItem: item.pointee)
      }
      return CDB_TRUE
    }

    return contactMap.asDictionary().map { _, v in v }.sorted { $0 < $1 }
  }
  
  /// Fetches a contact.
  ///
  /// - Parameters:
  ///   - uid: Unique identifier of the contact to fetch.
  ///
  /// - Returns: instance of `Contact`.
  ///
  func get(uid: String) throws -> Contact {
    _logger.write("uid=[%@]", type: .debug, uid)
    
    var nativeUid = CString(from: uid)
    defer { nativeUid.release() }

    var nativePtr: UnsafeMutablePointer<CDBCONTACT>?
    
    let status = CdbGetContact(nativeUid.value, &nativePtr)
    if status != CDB_SUCCESS {
      throw ContactSubsystemFailure(details: ContactErrorDetails(status, "Contact fetch failure"))
    }
    
    return Contact(nativePtr!)
  }
  
  /// Creates a new contact. This is only an in-memory representation of the contact.
  /// To save this new contact into a database use `ContactManager.save`.
  ///
  /// - Returns: instance of `Contact`.
  ///
  func create() throws -> Contact {
    _logger.write("new-contact", type: .debug)
    
   var nativePtr: UnsafeMutablePointer<CDBCONTACT>?
    
    let status = CdbCreateContact(&nativePtr)
    if status  != CDB_SUCCESS {
      throw ContactSubsystemFailure(details: ContactErrorDetails(status, "Contact creation failure"))
    }
    
    return  Contact(nativePtr!)
  }
  
  /// Saves a new or modified contact. This is an asynchronous operation. The save
  /// operation will be initiated and the call will immediately return. Once the operation
  /// has been completed, successfully or otherwise, the callback (if one is given) will
  /// be invoked.
  ///
  /// - Parameters:
  ///   - contact:    Contact instance to save.
  ///   - completion: Optional callback  that is invoked upon action completion.
  ///
  func save(_ contact: Contact, completion: @escaping (Error?) -> Void = { _ in }) {
    _logger.write("uid=[%@]", type: .debug, contact.uid)
    //print("contact to be save = \(contact)")
    DispatchQueue.main.async {
      let status = CdbSaveContact(contact._nativePtr)
      if status == CDB_SUCCESS {
        // Refresh the list. This may or may not be necessary, but might as well do it.
        // We always want to do this before we invoke the completion.
        DispatchQueue.main.async {
          self.filter(self.filterExpression)
        }
        
        completion(nil)
        
      } else {
        completion(ContactSubsystemFailure(
          details: ContactErrorDetails(status, "Failed to save")))
      }
    }
  }
  
  /// Deletes the given contact. This operation cannot be undone.
  ///
  /// - Parameters:
  ///   - contact: Contact instance to delete.
  ///
  func delete(_ contact: Contact) {
    _logger.write("uid=[%@]", type: .debug, contact.uid)
    
    if CdbDeleteContact(contact._nativePtr) != CDB_SUCCESS {
      _logger.write("uid=[%@]: failed to delete", type: .error, contact.uid)
    }
  }
  
  /// Native contact import.
  ///
  func importNativeContacts() {
    _logger.write("importing native contacts", type: .debug)
    
    let store = CNContactStore()
//    let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
//    let request = CNContactFetchRequest(keysToFetch: keys)
    
    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey, CNContactMiddleNameKey, CNContactDepartmentNameKey, CNContactEmailAddressesKey, CNContactImageDataKey]
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
    
    do {
      try store.enumerateContacts(with: request) { (contact, stop) in
        // Create the "shadow" contact
        
        if contact.phoneNumbers.count > 0 {
        
        let shadowContact: Contact = {
          do {
            return try self.create()
          } catch {
            // Failure to create a contact is a fatal error. We'll abort immediately.
            fatalError()
          }
        }()
        
        shadowContact.firstName   = contact.givenName
        shadowContact.middleName  = contact.middleName
        shadowContact.lastName    = contact.familyName
        shadowContact.companyName = contact.departmentName
        
        // Create the "shadow" email addresses
        for email in contact.emailAddresses {
          guard var shadowEmail = shadowContact.createEmailAddress() else {
            self._logger.write("failed to create email address instance.", type: .error)
            return
          }
          
          shadowEmail.email = email.value as String
        }
        var toSave = true
        // Create the "shadow" phone numbers
        for phoneNumber in contact.phoneNumbers {
          guard var shadowPhoneNumber = shadowContact.createPhoneNumber() else {
            self._logger.write("failed to create phone number instance.", type: .error)
            return
          }
            var phoneNo = phoneNumber.value.stringValue as String
            phoneNo = phoneNo.replacingOccurrences(of: " ", with: "")
            phoneNo = phoneNo.replacingOccurrences(of: "-", with: "")
            phoneNo = phoneNo.replacingOccurrences(of: "(", with: "")
            phoneNo = phoneNo.replacingOccurrences(of: ")", with: "")
            phoneNo = phoneNo.replacingOccurrences(of: "+", with: "")
            
           // shadowPhoneNumber.number = phoneNumber.value.stringValue as String
            shadowPhoneNumber.number = phoneNo
           //let contactreference =  self.search(firstName: "", middleName: "", lastName: "", email: "", phoneNumber: phoneNumber.value.stringValue as String)
            let contactreference =  self.search(firstName: "", middleName: "", lastName: "", email: "", phoneNumber: phoneNo as String)
            //print("contactreference = \(contactreference)")
            if contactreference.count > 0 {
               toSave = false
            }
        }
        if toSave == true {
            self.save(shadowContact)
        }
        else {
            
        }
        }
      }
      
    } catch {
      _logger.write(
        "contact import failure: [%s]", type: .error, error.localizedDescription)
    }
  }
}

private final class ContactMap {
  private var _map: [String: ContactReference] = [:]
  
  func asDictionary() -> [String: ContactReference] {
    return _map
  }
  
  /// Adds the given reference to the contact map.
  ///
  /// -  Parameters:
  ///   - reference: Instance of ContactReference to add to the map.
  ///
  func put(reference: ContactReference) {
    _map[reference.uid] = reference
  }
  
  /// Retrieves a ContactReference with the given UID.
  ///
  /// - Parameters:
  ///   - uid: UID of the ContactReference.
  ///
  /// - Returns: Instance of `ContactReference` on success, or `nil` on failure.
  ///
  func get(_ uid: String) -> ContactReference? {
    return _map[uid]
  }
  
  /// Creates an instance of `ContactReference` from the given query item and  adds it
  /// to the map.
  ///
  /// - Parameters:
  ///   - queryItem: Instance of `CDBENUMERATEQUERYITEM`.
  ///
  func put(queryItem: CDBENUMERATEQUERYITEM) {
    let uid = String(cString: queryItem.uid!)
        
    var reference: ContactReference? = get(uid)
    
    // If the reference doesn't exist in our map we'll create it here. Clearly, the first
    // instance that we encounter dictates what values the "core" fields will have (first,
    // middle, and last names).
    if reference == nil {
      reference = ContactReference(
        uid:          uid,
        firstName:    String(cString: queryItem.first_name),
        middleName:   String(cString: queryItem.middle_name),
        lastName:     String(cString: queryItem.last_name),
        emails:       [],
        phoneNumbers: []
      )

      put(reference: reference!)
    }
    
    if queryItem.email != nil {
      reference!.append(email: String(cString: queryItem.email))
    }
    
    if queryItem.phone_number != nil {
      reference!.append(phoneNumber: String(cString: queryItem.phone_number))
    }
  }
}

/// `ContactReference` is a simple, short description of a contact. To get the full
/// contact inormation tree fetch a `Contact` object using the `uid` given in this
/// structure.
///
final class ContactReference: Hashable {
  private(set) var uid: String
  private(set) var firstName: String
  private(set) var middleName: String
  private(set) var lastName: String
  private(set) var emails: [String]
  private(set) var phoneNumbers: [String]
  
  /// Creates a new instance of `ContactReferece`.
  ///
  /// - Parameters:
  ///   - firstName:      contact's first name
  ///   - middleName:     contact's middle nam
  ///   - lastName:       contact's last name
  ///   - emails:         list of email addresses
  ///   - phoneNumbers:   list of phone numbers
  ///
  init(uid: String, firstName: String, middleName: String, lastName: String,
       emails: [String], phoneNumbers: [String]) {
    self.uid          = uid
    self.firstName    = firstName
    self.middleName   = middleName
    self.lastName     = lastName
    self.emails       = emails
    self.phoneNumbers = phoneNumbers
  }
  
  // Internal. Used only at construction time (see CallManager).
  fileprivate func append(email: String) {
    emails.append(email)
  }
  
  // Internal. Used only at construction time (see CallManager).
  fileprivate func append(phoneNumber: String) {
    phoneNumbers.append(phoneNumber)
  }
  
  /// Compares two contact references. This is a lexicographical comparison based on
  /// the given contacts' first ane last names.
  ///
  /// - Parameters:
  ///   - lhs: Instance of `ContactReference`
  ///   - rhs: Instance of `ContactReference`
  ///
  /// - Returns: true if `lhs` is "smaller" than `rhs`; false otherwise.
  ///
  static func < (lhs: ContactReference, rhs: ContactReference) -> Bool {
    if lhs.lastName < rhs.lastName {
      return true
    }
    if lhs.lastName > rhs.lastName {
      return false
    }
    return lhs.firstName < rhs.firstName
  }
  
  /// Compares two contact references. This is a `uid` comparison. If the `uid`s
  /// match then the two references are deemed equal.
  ///
  /// - Parameters:
  ///   - lhs: Comparison left hand side
  ///   - rhs: Comparison right hand side
  ///
  /// - Returns: `true` if the references are deemed equal, and `false` otherwise.
  ///
  static func == (lhs: ContactReference, rhs: ContactReference) -> Bool {
    return lhs.uid == rhs.uid
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(uid)
  }
}
