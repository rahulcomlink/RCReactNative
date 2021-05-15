//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation

final class Dialer {
  // The one and only instance of Dialer
  static let shared = Dialer()

  typealias InboundCallHandler = (UUID) -> Void
  typealias CallStartedHandler = (UUID) -> Void
  typealias CallAnsweredHandler = (UUID) -> Void
  typealias CallEndedHandler = (UUID) -> Void

  /// If set, this callback will be invoked immediately after a call is answered.
  var callAnsweredHandler: CallAnsweredHandler?

  /// If set, this callback will be invoked immediately after a call is torn down.
  var callEndedHandler: CallEndedHandler?

  // If set, this callback will be invoked whenever a new incoming call arrives.
  var inboundCallHandler: InboundCallHandler?

  private let _logger = Logger(componentName: "Dialer")
  private var _callMap = Isomorphism<UUID, CMCALLHANDLE>()
  private var _pendingCallUUIDQueue: FIFO<UUID> = FIFO()
  private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"

  private init() {
  }

  func getCallInfo(uuid: UUID) -> CallInfo {
    return CallInfo(handle: _callMap[uuid]!)
  }

  func start(with pushToken: String) throws {
    
    let config = Configuration.shared

    // SIP parameters
    let sipServerHost = CString(from: config.sipServerHost)
    let sipUsername = CString(from: config.sipUsername)
    let sipPassword = CString(from: config.sipPassword)
    let sipRealm = CString(from: config.sipRealm)

    defer { CString.release(sipUsername, sipPassword, sipRealm) }

    // Set up SIP transport
    let sipTransport: CMSIPTRANSPORT = try {
      switch config.sipTransport {
      case Configuration.kTransportTCP: return CM_TCP
      case Configuration.kTransportTLS: return CM_TLS
      case Configuration.kTransportUDP: return CM_UDP
      default:
        throw DialerInvalidParameterError(
          details: DialerErrorDetails(CM_INVALID_PARAMETER, "Invalid transport"))
      }
    }()

    // STUN parameters
    let stunHost = CString(from: config.stunHost)

    // TURN parameters
    let turnHost = CString(from: config.turnHost)
    let turnUsername = CString(from: config.turnUsername)
    let turnPassword = CString(from: config.turnPassword)
    let turnRealm = CString(from: config.turnRealm)

    // Get the absolute path to the ringback file
    let ringbackPath = Bundle.main.path(forResource: "ring", ofType: "wav")
    let ringbackAudioFile = CString(from: ringbackPath!)
    
    // Device ID
    //let deviceId = CString(from: pushToken)

    defer {
      CString.release(
        stunHost, turnHost, turnUsername, turnPassword, turnRealm,
        ringbackAudioFile)
    }

    var cmConfig = CMCONFIGURATION()
    CmInitializeConfiguration(&cmConfig)
    cmConfig.sip_server_host = sipServerHost.value
    cmConfig.sip_local_port = UInt16(config.sipLocalPort)
    cmConfig.sip_server_port = UInt16(config.sipServerPort)
    cmConfig.sip_username = sipUsername.value
    cmConfig.sip_password = sipPassword.value
    cmConfig.sip_transport = sipTransport
    cmConfig.sip_realm = sipRealm.value
    cmConfig.stun_host = stunHost.value
    cmConfig.turn_host = turnHost.value
    cmConfig.turn_username = turnUsername.value
    cmConfig.turn_password = turnPassword.value
    cmConfig.turn_realm = turnRealm.value
    cmConfig.ringback_audio_file = ringbackAudioFile.value
    cmConfig.answer_timeout = Int32(config.answerTimeout)
   // cmConfig.device_id = deviceId.value
    cmConfig.enable_ice = config.iceEnabled ? CM_TRUE : CM_FALSE
    cmConfig.enable_srtp = config.srtpEnabled ? CM_TRUE : CM_FALSE

    if CmInitialize(&cmConfig) != CM_SUCCESS {
      throw DialerSubsystemFailure(
        details: DialerErrorDetails(CM_SUBSYSTEM_FAILURE, "Initialization failure"))
    }

    // Set up callbacks
    CmSetInboundCallHandler({ handle in Dialer.shared.onInboundCall(handle: handle) })
    CmSetCallStateChangeHandler({ handle in Dialer.shared.onCallStateChanged(handle: handle) })

    // Construct the SIP URI template
    let transportName =
      Configuration.kTransportNames[Configuration.shared.sipTransport].lowercased()
    _sipUriTemplate =
      "sip:%@@\(config.sipServerHost):\(config.sipServerPort);transport=\(transportName)"
  }

  func stop() throws {
    if CmShutdown() != CM_SUCCESS {
      throw DialerSubsystemFailure(
        details: DialerErrorDetails(CM_SUBSYSTEM_FAILURE, "Uninitialization failure"))
    }
  }
  
  func isValidCall(_ uuid: UUID) -> Bool {
    return _callMap[uuid] != nil
  }
  
  func sendDTMFTone(with uuid: UUID, tone: String) throws {
    _logger.write("uuid=[%@], tone=[%@]", uuid.uuidString, tone)
    
    let status = CmCallSendDTMFTone(_callMap[uuid]!, Int8(tone.utf8.first!))
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(
        details: DialerErrorDetails(status, "Failed to send DTMF digit"))
    }
  }

  func makeCall(outpulse: String, uuid: UUID) throws {
    _logger.write("outpulse=[%@], uuid=[%@]", type: .debug, outpulse, uuid.uuidString)
    
    try register()

    var handle: CMCALLHANDLE?
    let uri = String(format: _sipUriTemplate, arguments: [outpulse])
    
    let status = CmMakeCall(uri, &handle)
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to make call"))
    }

    _callMap[uuid] = handle!
  }
  
  func register() throws {
    _logger.write("registering", type: .debug)
    
    let status = CmRegister()
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to register"))
    }
  }
  
  func unregister() throws {
    _logger.write("unregistering", type: .debug)
    
    let status = CmUnregister()
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to unregister"))
    }
  }
  
  func waitForCall(with uuid: UUID) throws {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    _pendingCallUUIDQueue.push(uuid)
    
    try register()
  }

  func answerCall(uuid: UUID) throws {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    let status = CmCallAnswer(_callMap[uuid]!)
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to answer"))
    }
  }

  func dropCall(uuid: UUID) {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)

    // If this is a pending call then we don't yet have a handle for it. Therefore,
    // we just bail here.
   
    var status: CMSTATUS
    if let handle = _callMap[uuid] {
    _callMap[uuid] = nil
    
    status = CmCallHangup(handle)
    
    if status != CM_SUCCESS {
      _logger.write("uuid=[%@], call hangup failure", type: .error, uuid.uuidString)
    }
    }
    status = CmUnregister()

    if status != CM_SUCCESS {
      _logger.write("uuid=[%@], failed to unregister", type: .error, uuid.uuidString)
    }
    
    if _pendingCallUUIDQueue.remove(uuid) {
      return
    }
   
  }

  func holdCall(uuid: UUID) throws {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    let groupId = CmCallGetGroupIdentifier(_callMap[uuid]!)
    
    if groupId == CmGetCurrentGroupIdentifier() && CmHoldCurrentGroup() != CM_SUCCESS {
      throw DialerSubsystemFailure(
        details: DialerErrorDetails(CM_SUBSYSTEM_FAILURE, "Failure to hold"))
    }
  }

  func resumeCall(uuid: UUID) throws {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    let groupId = CmCallGetGroupIdentifier(_callMap[uuid]!)
    
    let status = CmResumeGroup(groupId)
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to resume group"))
    }
  }

  func isOnHold(uuid: UUID) -> Bool {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    return CmCallIsOnHold(_callMap[uuid]!) == CM_TRUE
  }

  func muteMicrophone(uuid: UUID) throws {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    let status = CmCallMuteMicrophone(_callMap[uuid]!)
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to mute microphone"))
    }
  }

  func isMicrophoneMuted(uuid: UUID) -> Bool {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    return CmCallIsMicrophoneMuted(_callMap[uuid]!) == CM_TRUE
  }

  func unmuteMicrophone(uuid: UUID) throws {
    _logger.write("uuid=[%@]", type: .debug, uuid.uuidString)
    
    let status = CmCallUnmuteMicrophone(_callMap[uuid]!)
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to unmute microphoe"))
    }
  }

  private func onInboundCall(handle: CMCALLHANDLE?) -> CMBOOL {
    let info = CallInfo(handle: handle!)
    
    guard let uuid = _pendingCallUUIDQueue.pop() else {
      _logger.write("handle not in map for Call-ID=[%@]", type: .error, info.callId!)
      return CM_FALSE
    }

    _logger.write("[%@] <-> [%@]", type: .debug, uuid.uuidString, info.callId!)
    
    _callMap[uuid] = handle!
    
    inboundCallHandler?(uuid)
    
    return CM_TRUE
  }

  private func onCallStateChanged(handle: CMCALLHANDLE?) {
    // Attempt to get the call status.  The following call shoukld not fail.
    // In fact, it is only expected to fail if we pass in an invalid handle.
    // We should probably assert here, but we'll silently ignore this condition
    // for now.
    var status: CMCALLSTATUS = CMCS_NONE
    if CmCallGetStatus(handle, &status) != CM_SUCCESS {
      return
    }

    guard let uuid = _callMap[handle!]  else {
      return
    }
    
    switch status {
    case CMCS_ANSWERED:
      callAnsweredHandler?(uuid)
      ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "ANSWERED"])
    case CMCS_DECLINED:
      // Call declined by the remote end.
      callEndedHandler?(uuid)
      ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "DECLINED"])
    case CMCS_TERMINATED:
      // Call terminated by the remote end.
      callEndedHandler?(uuid)
      ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "TERMINATED"])
    case CMCS_RINGING:
      ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "RINGING"])
    default:
      // FIXME: we may want to handle CMCS_TRYING, CMCS_RINGING, and so on in
      // order to provide feedback to the user. However, this is most likely
      // not necessary.
      _logger.write("Ignoring call status change (trying/ringing)", type: .debug)
    }
  }
}
