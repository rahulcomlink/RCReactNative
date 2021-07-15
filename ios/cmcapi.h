// Comlink Communicator SDK
// Copyright 2019 Comlink Inc. All rights reserved.

/// \file
///
/// \addtogroup c-api The C API
/// @{
/// \addtogroup c-callmanager Call Management
/// @{
///

#ifndef CMCAPI_H_
#define CMCAPI_H_

#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
#define EXPORT extern "C"
#else
#define EXPORT
#endif

///
/// \brief Boolean type.
///
typedef enum CMBOOL { CM_FALSE = 0, CM_TRUE = 1 } CMBOOL;

///
/// \brief Operation status codes.
///
typedef enum CMSTATUS {
  CM_SUCCESS,                 ///< Operation succeeded
  CM_INVALID_PARAMETER,       ///< Invalid parameters provided
  CM_SUBSYSTEM_FAILURE,       ///< Generic call engine failure
  CM_BAD_REFERENCE,           ///< Invalid reference
  CM_INVALID_STATE,           ///< Operation invalid in current state
  CM_PARTIAL_SUCCESS,         ///< Operation partially succeeded
  CM_TIMEOUT,                 ///< Operation timed out
  CM_DECLINED,                ///< Operation declined
  CM_SUBSYSTEM_UNINITIALIZED  ///< Subsystem not initialized
} CMSTATUS;

///
///< \brief Generic call rejection reasons.
///
typedef enum CMDECLINEREASON {
  CM_UNAVAILABLE,     ///< User unavailable
  CM_BUSY,            ///< User busy
  CM_GENERIC_FAILURE  ///< Generic/unspecified call processing failure
} CMDECLINEREASON;

///
/// \brief Call status indicators.
///
typedef enum CMCALLSTATUS {
  CMCS_NONE,
  CMCS_TRYING,    ///< An outbound call has been initiated
  CMCS_RINGING,   ///< The call, either inbound or outbound, is ringing/alerting
  CMCS_ANSWERED,  ///< The call, either inbound or outbound, has been answered
  CMCS_TERMINATED,  ///< The call, either inbound or outbound, has been
                    ///< terminated
  CMCS_DECLINED     ///< The call, either inbound or outbound, has been declined
} CMCALLSTATUS;

///
/// \brief SIP transport indicators.
///
typedef enum CMSIPTRANSPORT { CM_UDP, CM_TCP, CM_TLS } CMSIPTRANSPORT;

///
/// \brief Configuration settings.
///
typedef struct CMCONFIGURATION {
  const char* sip_server_host;     ///< SIP server host name or IP
  unsigned short sip_server_port;  ///< SIP server port
  unsigned short sip_local_port;   ///< SIP local port
  const char* sip_username;        ///< SIP user name
  const char* sip_password;        ///< SIP password
  const char* sip_realm;           ///< SIP realm
  CMSIPTRANSPORT sip_transport;    ///< SIP transport

  /// \brief Device identifier.
  ///
  /// Optional value that can be ussed to uniquely identifiy a device at SIP
  /// registration time.
  const char* device_id;

  /// \brief STUN host name or IP.
  ///
  /// If NULL or blank STUN will not be used.
  const char* stun_host;

  /// \brief TURN host name or IP.
  ///
  /// If NULL or blank TURN will not be used.
  const char* turn_host;
  const char* turn_username;  ///< TURN user name
  const char* turn_password;  ///< TURN password
  const char* turn_realm;     ///< TURN realm

  int answer_timeout;               ///< Call answer timeout
  CMBOOL enable_ice;                ///< ICE enabled flag
  CMBOOL enable_srtp;               ///< SRTP enabled flag
  const char* ringback_audio_file;  ///< Ringback audio file path

  /// \brief List of desired codecs.
  ///
  /// If left unspecified, the following codecs will be used: opus/48000/2,
  /// opus/24000/2, G729/8000/1, PCMU/8000/1, and PCMA/8000/1.
  const char** desired_codecs;
} CMCONFIGURATION;

///
/// \brief Opaque call handle.
///
typedef void* CMCALLHANDLE;

///
/// \brief Call state change handler/
///
typedef void (*CMSTATECHANGEHANDLER)(CMCALLHANDLE);

///
/// \brief Inbound call handler.
///
typedef CMBOOL (*CMINBOUNDCALLHANDLER)(CMCALLHANDLE);

///
/// \brief Initializes the CMCONFIGURATION structure with mostly invalid
/// settings.
///
EXPORT void CmInitializeConfiguration(CMCONFIGURATION* csi);

///
/// \brief Dialer configuration and initialization.
///
/// \param csi Configuration structure.
///
/// \return Operation status code.
///
EXPORT CMSTATUS CmInitialize(const CMCONFIGURATION* csi);

///
/// \brief Dialer shutdown.
///
/// \return Operation status code.
///
EXPORT CMSTATUS CmShutdown();

///
/// \brief Handles network address change.
///
/// In case of a transition between WiFi to mobile or vice versa, this function
/// must be invoked so that the underlying SIP stack may perform any necessary
/// adjustments to keep the registration and any currently active calls alive.
///
EXPORT CMSTATUS CmHandleNetworkAddressChange();

///
/// \brief Starts the SIP registration session with the SIP registrar server.
///
/// This SIP registration session will be maintained internally by the library,
/// and application doesn't need to do anything to maintain the registration
/// session. This function will wait until a response is received from the
/// registrar or until the attempt times out.
///
/// \return CM_SUCCESS if the registration attempt is accepted, CM_DECLINED if
/// declined, or CM_TIMEOUT in case of operation timeout.
///
EXPORT CMSTATUS CmRegister();

///
/// Stops the SIP registration session started via Register.
///
/// \return kSuccess on success or an error code on failure.
///
EXPORT CMSTATUS CmUnregister();

///
/// \brief Makes an outbound call.
///
/// There must be no currently active call when this function is invoked. If
/// there is a current call it must either be destroyed or put on hold (via
/// HoldCurrenGroup) prior to invoking this function. If this function succeeds
/// in creating a new call then that call becomes the currently active call.
///
/// \param remote_party Remote party's SIP URI.
/// \param call_handle Pointer to a memory location that will receive the new
/// call's CMCALLHANDLE in case of successful call setup initialization.
///
/// \return CM_SUCCESS on success or error code on failure.
///
EXPORT CMSTATUS CmMakeCall(const char* remote_party, CMCALLHANDLE* call_handle);

///
/// \brief Attempts to put the currently active call group on hold.
///
/// For each call in the group the remote end is notified that the call is being
/// put on hold. The call itself is detached from the hardware devices
/// (microphone and speaker) immediately.
///
/// \return CM_SUCCESS on success or an error code on failure. If there is no
/// currently active call group this function returns CM_SUCCESS.
///
EXPORT CMSTATUS CmHoldCurrentGroup();

///
/// \brief Attempts to resume the given call group from hold.
///
/// For each call in the group The remote end is notified that the call is being
/// resumed from hold. The call itself is immediately attached to the hardware
/// devices (microphone and speaker). There must be no currently active call
/// group when this function is invoked. If there is an active call group it
/// must either be destroyed or put on hold (via HoldCurrentGroup) prior to
/// invoking this function.
///
/// \param group_id ID of the group to resume.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmResumeGroup(int group_id);

///
/// \brief Attempts to move the call identified by CMCALLHANDLE into the call
/// group identified by group_id.
///
/// \param group_id Target group identifier.
/// \param call_handle call to move.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmMoveCallToGroup(int group_id, CMCALLHANDLE call_handle);

///
/// \brief Retrieves the currently active call group
///
/// \param array Memory address that will receive a pointer to the handle array.
/// \param size Memory address that will receive the size of the handle array.
///
/// \return ID of the currently active call group.
///
EXPORT int CmGetCurrentGroup(CMCALLHANDLE** array, int* size);

///
/// \brief Releases the resources used by a CMCALLHANDLE array.
///
/// \param array Pointer to the array
///
EXPORT void CmReleaseCallArray(CMCALLHANDLE* array);

///
/// \brief Retrieves the identifier of the currently active call group.
///
/// \return Integer value representing the current call group identifier.
///
EXPORT int CmGetCurrentGroupIdentifier();

///
/// \brief Releases the given call handle.
///
/// \param call_handle call handle to release.
///
EXPORT CMSTATUS CmCallReleaseHandle(CMCALLHANDLE call_handle);

///
/// \brief Checks if the given call handle is valid.
///
/// A valid handle represents a known call. The call does not need to be active
/// in order for its handle to be valid.
///
/// \return CM_TRUE if the call handle is valid, or CM_FALSE otherwise.
///
EXPORT CMBOOL CmCallIsHandleValid(CMCALLHANDLE call_handle);

///
/// \brief Sends a DTMF tone over the given call.
///
/// \param call_handle Call over which to send the DTMF tone.
/// \param tone The tone to send.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallSendDTMFTone(CMCALLHANDLE call_handle, char tone);

///
/// \brief Mutes the microphone for the current call.
///
/// Note that the microphone can only be muted or unmuted while the call is
/// answered.
///
/// \param call_handle Call for which to mute the microphone.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallMuteMicrophone(CMCALLHANDLE call_handle);

///
/// \brief Unmutes the microphone for the current call.
///
/// Note that the microphone can only be muted or unmuted while the call is
/// answered.
///
/// \param call_handle Call for which to unmute the microphone.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallUnmuteMicrophone(CMCALLHANDLE call_handle);

///
/// \brief Retrieves the SIP Call-ID value for the given call.
///
/// \param call_handle Call handle.
/// \param value Pointer to a memory location into which a pointer to a zero
/// terminated string representing the Call-ID is to be stored. This
/// pointer will remain valid as long as the call_handle remains valid.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetCallIdentifier(CMCALLHANDLE call_handle,
                                        const char** value);

///
/// \brief Retrieves the unique remote party SIP URI for the given call.
///
/// \param call_handle Call handle.
/// \param value Pointer to a memory location into which a pointer to a zero
/// terminated string representing the remote party URI is to be stored. This
/// pointer will remain valid as long as the call_handle remains valid.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetRemoteParty(CMCALLHANDLE call_handle,
                                     const char** value);

///
/// \brief Retrieves the remote party's CLID.
///
/// In SIP terms, the CLID can be thought of as the user portion of the SIP URI.
///
/// \param call_handle Call handle.
/// \param value Pointer to a memory location into which a pointer to a zero
/// terminated string represting the remote party CLID is to be stored. This
/// pointer will remain valid as long as the call_handle remains valid.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetRemotePartyCLID(CMCALLHANDLE call_handle,
                                         const char** value);

///
/// \brief Retrieves the remote party's full name.
///
/// \param call_handle Call handle.
/// \param value Pointer to a memory location into which a pointer to a zero
/// terminated string represting the remote party's full name is to be stored.
/// This pointer will remain valid as long as the call_handle remains valid.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetRemotePartyName(CMCALLHANDLE call_handle,
                                         const char** value);

///
/// \brief Retrieves the SIP Contact address value for the given call.
///
/// \param call_handle Call handle.
/// \param value Pointer to a memory location into which a pointer to a zero
/// terminated string representing the Contact address is to be stored. This
/// pointer will remain valid as long as the call_handle remains valid.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetContact(CMCALLHANDLE call_handle, const char** value);

///
/// \brief Retrieves the current status of the call.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetStatus(CMCALLHANDLE call_handle, CMCALLSTATUS* result);

///
/// \brief Retrieves the identifier of the group that the given call belongs to.
///
/// \return group identifier on success, or -1 on failure.
///
EXPORT int CmCallGetGroupIdentifier(CMCALLHANDLE call_handle);

///
/// \brief Use this function to check whether the given call is on hold or not.
///
/// \return true if the call is on hold, false otherwise.
///
EXPORT CMBOOL CmCallIsOnHold(CMCALLHANDLE call_handle);

///
/// \brief Use this function to check whether the microphone has been muted for
/// the given call or not.
///
/// \return true if the microphone has been muted, false otherwise.
///
EXPORT CMBOOL CmCallIsMicrophoneMuted(CMCALLHANDLE call_handle);

///
/// \brief Retrieves call start, end, and answer timestamps, if available.
///
/// \param call_handle Call handle.
/// \param time_start Pointer to a 64-bit unsigned int into which the time start
/// timestamp will be written.
/// \param time_end Pointer to a 64-bit unsigned int
/// into which the time end timestamp will be written.
/// \param time_answer Pointer to a 64-bit unsigned int into which the time
/// answer timestamp will be written. \return CM_SUCCESS on success or some
/// other status code on failure.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallGetTimes(CMCALLHANDLE call_handle, uint64_t* time_start,
                               uint64_t* time_end, uint64_t* time_answer);

///
/// \brief Answers the given call.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallAnswer(CMCALLHANDLE call_handle);

///
/// \brief Declines the given call.
///
/// \param call_handle Call handle.
/// \param reason Reason for call rejection.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallDecline(CMCALLHANDLE call_handle, CMDECLINEREASON reason);

///
/// \brief Hangs up the given call.
///
/// \return CM_SUCCESS on success or an error code on failure.
///
EXPORT CMSTATUS CmCallHangup(CMCALLHANDLE call_handle);

///
/// \brief Waits for call termination.
///
/// \param timeout_ms How long to wait for call termination.
///
/// \return true if the call terminated within the specified amount of time or
/// false if timeout occurred.
///
EXPORT CMSTATUS CmCallWaitForTermination(CMCALLHANDLE call_handle,
                                         unsigned long timeout_ms);

///
/// \brief Sets the inbound call handler.
///
/// There can only be one inbound call handler installed at any given point in
/// time. If there is an inbound call handler already installed it will simply
/// be replaced with the new one.
///
EXPORT void CmSetInboundCallHandler(CMINBOUNDCALLHANDLER handler);

///
/// \brief Sets the call state change handler.
///
/// There can only be one call state change handler installed at any given point
/// in time. If there is a call state handler already installed it will simply
/// be replaced with the new one.
///
EXPORT void CmSetCallStateChangeHandler(CMSTATECHANGEHANDLER handler);

#endif  // CMCAPI_H_

///
/// @}
/// @}
///
