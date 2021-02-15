// Comlink Communicator SDK
// Copyright 2019 Comlink Inc. All rights reserved.

/// \file
///
/// \addtogroup c-api The C API
/// @{
/// \addtogroup c-contacts Contact Management
/// @{
///

#ifndef CDBCAPI_H_
#define CDBCAPI_H_

#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
#define EXPORT extern "C"
#else
#define EXPORT
#endif

/// \brief Used internally - do not modify.
typedef struct CDBPRIVATE {
  void* reserved;  ///< Used internally. Do not modify.
} CDBPRIVATE;

///
/// \brief Operation status codes.
///
typedef enum CDB_STATUS {
  CDB_SUCCESS,              ///< Operation succeeded
  CDB_FAILURE,              ///< Operation failed
  CDB_INVALID_PARAMETER,    ///< Invalid parameter provided
  CDB_COMMUNICATION_ERROR,  ///< Network/communication errorr occurred
  CDB_OBJECT_DELETED,       ///< AN attempt was made to modify a deleted object
  CDB_LOCAL_UPDATES_SUCCEEDED,  ///< Local updates succeeded (remote failed)
  CDB_GENERIC_FAILURE,          ///< Catch-all
  CDB_UNIMPLEMENTED,            ///< Function/method unimplemented
  CDB_BAD_REFERENCE,            ///< Bad object reference
} CDB_STATUS;

///
/// \brief Boolean type.
///
typedef enum CDB_BOOL { CDB_FALSE = 0, CDB_TRUE = 1 } CDB_BOOL;

///
/// \brief Supported avatar image types.
///
typedef enum CDBIMAGETYPE {
  CDB_GIF, CDB_JPEG, CDB_NONE
} CDBIMAGETYPE;

///
/// \brief Contact's avatar.
///
typedef struct CDBAVATAR {
  CDBPRIVATE reserved;
  const char* uid;          ///< Unique identifier.
  CDBIMAGETYPE image_type;  ///< Avatar image type.
  size_t width;             ///< Avatar image width.
  size_t height;            ///< Avatar image height.
  const void* image_data;   ///< Avatar image data.
  size_t image_data_size;   ///< Avatar image data size.
} CDBAVATAR;

///
/// \brief Contact's phone number.
///
typedef struct CDBPHONENUMBER {
  CDBPRIVATE reserved;
  struct CDBPHONENUMBER* next;  ///< Next phone number in the list.
  const char* uid;              ///< Unique identifier.
  double time_created;          ///< Record creation time.
  double time_updated;          ///< Record update time.
  const char* number;           ///< Phone number value.
  const char* type;             ///< Phone number type.
  const char* note;             ///< Phone number note.
} CDBPHONENUMBER;

///
/// \brief Contact's email address.
///
typedef struct CDBEMAILADDRESS {
  CDBPRIVATE reserved;
  struct CDBEMAILADDRESS* next;  ///< Next email address in the list.
  const char* uid;               ///< Unique identifier.
  double time_created;           ///< Record creation time.
  double time_updated;           ///< Record update time.
  const char* address;           ///< Email address value.
  const char* note;              ///< Email address note.
} CDBEMAILADDRESS;

///
/// \brief Basic contact information.
///
typedef struct CDBCONTACT {
  CDBPRIVATE reserved;
  const char* uid;                   ///< Unique identifier.
  double time_created;               ///< Record creation time.
  double time_updated;               ///< Record update time.
  const char* first_name;            ///< Contact's first name.
  const char* middle_name;           ///< Contact's middle name.
  const char* last_name;             ///< Contact's last name.
  const char* company_name;          ///< Contact's company name.
  CDBAVATAR* avatar;                 ///< Contact's avatar.
  CDBPHONENUMBER* phone_numbers;     ///< Linked list of phone numbers.
  CDBEMAILADDRESS* email_addresses;  ///< Linked list of email addresses.
} CDBCONTACT;

///
/// \brief Enumerate query result item.
///
typedef struct CDBENUMERATEQUERYITEM {
  const char* uid;           ///< Contact unique identifier.
  const char* first_name;    ///< Contact's first name.
  const char* middle_name;   ///< Contact's middle name.
  const char* last_name;     ///< Contact's last name.
  const char* company;       ///< Contact's company name.
  const char* phone_number;  ///< Contact's phone number.
  const char* email;         ///< Contact's email.
} CDBENUMERATEQUERYITEM;

///
/// \brief Enumarete query.
///
typedef struct CDBENUMERATECONTACTSQUERY {
  const char* first_name;    ///< First name filter or NULL for all
  const char* middle_name;   ///< Middle name filter or NULL for all
  const char* last_name;     ///< Last name filter or NULL for all
  const char* email;         ///< Email filter or NULL for all
  const char* phone_number;  ///< phone number filter or NULL for all
} CDBENUMERATECONTACTSQUERY;

///
/// \brief Enumerate callback.
///
typedef CDB_BOOL (*CDBENUMERATECONTACTSCALLBACK)(CDBENUMERATEQUERYITEM* item,
                                                 void* user_data);

///
/// \brief Initializes the contact databasae maneger.
///
/// \param url Optional remote contact store.
/// \param local_directory Directory where the database files will be placed.
/// \param local_database_only Boolean value indicating whether changes to the
/// local database should be pushed to the remote server.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbInitialize(const char* url, const char* local_directory,
                                CDB_BOOL local_database_only);

///
/// \brief Shuts down the contact database manager.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbShutdown();

///
/// \brief Updates the given phone number's number property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param number CDBPHONENUMBER to update.
/// \param value New number value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbPhoneNumberUpdateNumber(CDBPHONENUMBER* number,
                                             const char* value);

///
/// \brief Updates the given phone number's type property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param number CDBPHONENUMBER to update.
/// \param value New type value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbPhoneNumberUpdateType(CDBPHONENUMBER* number,
                                           const char* value);

///
/// \brief Updates the given phone number's note property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param number CDBPHONENUMBER to update.
/// \param value New note value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbPhoneNumberUpdateNote(CDBPHONENUMBER* number,
                                           const char* value);

///
/// \brief Sets the avatar for th given contact.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact CDBCONTACT to update.
/// \param image_type Image type.
/// \param width Image width in pixels.
/// \param height Image height in pixels.
/// \param image_data Pointer to the block of memory containing image data.
/// \param image_data_size Image data size in bytes.
///
EXPORT CDB_STATUS CdbContactSetAvatar(CDBCONTACT* contact,
                                      CDBIMAGETYPE image_type, size_t width,
                                      size_t height, const void* image_data,
                                      size_t image_data_size);

///
/// \brief Updates the given contact's first name property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact CDBCONTACT to update.
/// \param value New first name value.
///
/// \return Operations status code.
///
EXPORT CDB_STATUS CdbContactUpdateFirstName(CDBCONTACT* contact,
                                            const char* value);

///
/// \brief Updates the given contact's middle name property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact CDBCONTACT to update.
/// \param value New middle name value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbContactUpdateMiddleName(CDBCONTACT* contact,
                                             const char* value);

///
/// \brief Updates the given contact's last name property.
///
/// \param contact CDBCONTACT to update.
/// \param value New last name value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbContactUpdateLastName(CDBCONTACT* contact,
                                           const char* value);

///
/// \brief Updates the given contact's company name property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact CDBCONTACT to update.
/// \param value New company name value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbContactUpdateCompanyName(CDBCONTACT* contact,
                                              const char* value);

///
/// \brief Updates the given email address' address property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param address CDBEMAILADDRESS to update.
/// \param value New address value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbEmailAddressUpdateAddress(CDBEMAILADDRESS* address,
                                               const char* value);

///
/// \brief Updates the given email address' note property.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param address CDBEMAILADDRESS to update.
/// \param value New note value.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbEmailAddressUpdateNote(CDBEMAILADDRESS* address,
                                            const char* value);

///
/// \brief Creates a new CDBEMAILADDRESS, initializes it, and appends it to the
/// list of email addresses of the given contact.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact Parent contact object.
/// \param email_address Address into which the pointer to the newly created
/// CDBEMAILADDRESS will be stored.
///
/// \return Operstion status code.
///
EXPORT CDB_STATUS CdbContactAppendEmailAddress(CDBCONTACT* contact,
                                               CDBEMAILADDRESS** email_address);

///
/// \brief Deletes the given email address from the list of email addresses for
/// the given contact.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact Parent contact object.
/// \param email_address Email object to delete.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbContactDeleteEmailAddress(CDBCONTACT* contact,
                                               CDBEMAILADDRESS* email_address);

///
/// \brief Creates a new CDBPHONENUMBER, initializes it, and appends it to the
/// list of phone number addresses of the given contact.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact Parent contact object.
/// \param phone_number Address into which the pointer to the newly created
/// CDBPHONENUMBER will be stored.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbContactAppendPhoneNumber(CDBCONTACT* contact,
                                              CDBPHONENUMBER** phone_number);

///
/// \brief Deletes the given phone number from th elist of phone numbers for the
/// given contact.
///
/// The parent contact must be saved in order for the change to become
/// permanent.
///
/// \param contact Parent contact object.
/// \param phone_number Phone number object to delete.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbContactDeletePhoneNumber(CDBCONTACT* contact,
                                              CDBPHONENUMBER* phone_number);

///
/// \brief Creates a new CDBCONTACT instance and initializes it.
///
/// \param contact Address into which the pointer to the newly created
/// CDBCONTACT will be stored.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbCreateContact(CDBCONTACT** contact);

///
/// \brief Deletes the given CDBCONTACT.
///
/// \param contact CDBCONTACT instance to delete.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbDeleteContact(CDBCONTACT* contact);

///
/// \brief Releases any resources associated with the given CDBCONTACT instance.
///
/// If this function completes successfully no attempts should be made to
/// reference the released object as that will most likely result in a crash.
///
/// \param contact CDBCONTACT instance to release.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbReleaseContact(CDBCONTACT* contact);

///
/// \brief Saves the given contact.
///
/// Any changes made to the contact information, including any changes made to
/// the email addresses or phone numbers are saved into the contact database.
/// This is the only way to update the underlying database.
///
/// \param contact CDBCONTACT instance to save.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbSaveContact(CDBCONTACT* contact);

///
/// \brief Enumerates contacts that match the given query.
///
/// The results are provided via the given callback. The callback is passed a
/// pointer to a CDBENUMERATEQUERYITEM that describes the match. Note that the
/// same contact reference may be returned multiple times, once for each
/// subobject (email or phone number) match.
///
/// \param user_data Optoinal user-supplied pointer that will be passed to the
/// enumeration callback.
/// \param query Pointer to CDBENUMERATECONTACTSQUERY structure containing the
/// query values.
/// \param callback Callback that is invoked for each match.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbEnumerateContacts(void* user_data,
                                       const CDBENUMERATECONTACTSQUERY* query,
                                       CDBENUMERATECONTACTSCALLBACK callback);

///
/// \brief Retrieves a contact from the contact database.
///
/// \param uid Contact unique identifier.
/// \param result Address into which the the pointer to a CDBCONTACT instance
/// will be stored.
///
/// \return Operation status code.
///
EXPORT CDB_STATUS CdbGetContact(const char* uid, CDBCONTACT** result);

#endif  // CDBCAPI_H_

///
/// @}
/// @}
///
