//
//  SipCallManager.swift
//  Enterprise VOIP
//
//  Created by Apple on 20/08/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import CallKit
import AVKit
import AVFoundation
import PushKit

class SipCallManager {
  
    static let shared = SipCallManager()
    private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"
    var callHandle: CMCALLHANDLE?
    
    typealias updateCallStatus = (CMCALLSTATUS) -> Void
    var sipCallStatus : updateCallStatus?
    
    private let _controller = CXCallController()
    private let _provider: CXProvider
    
    var _currentCallUuid: UUID = UUID(uuid: UUID_NULL)
    private var _pendingCallUUIDQueue: FIFO<UUID> = FIFO()
  
  // Pending call info
    private var _inboundCallDescriptor: InboundCallDescriptor?
    private var _callMap = Isomorphism<UUID, CMCALLHANDLE>()
  
    private static let kNullUUID = UUID(uuid: UUID_NULL)
    
    var onHold =  false
    var isMuted = false
    var isSpeakerOn = false
    var inCall = false
    var isConnecting = false
    var callDuration = 0
    private var _callTimer: Timer?
    var callStatus: CMCALLSTATUS = CMCS_NONE
    var _activeAudioSession: AVAudioSession? = AVAudioSession.sharedInstance()
    var phoneNumber = ""
    var remotePartyName = ""
    var remotePartyClid = ""
    
    typealias ActionCompletion = (Error?) -> Void
    private var _actionCompletion: SingleFireCallback<Error>?
    private var _suppressPublishedPropertyReset = false
    private let _dispatchQueue = DispatchQueue(label: "SipCallManagerDispatchQueue")
    private var _waitingForInboundCall = BlockingBarrier<Bool>(withInitalValue: false)
    private var _makeCallInProgress = BlockingBarrier<Bool>(withInitalValue: false)
    private var _audioSessionReady = BlockingBarrier<Bool>(withInitalValue: false)
    
    private init() {
      let localizedName = NSLocalizedString("Pigeon", comment: "Pigeon")
      let configuration = CXProviderConfiguration(localizedName: localizedName)

      configuration.supportsVideo = false
      configuration.maximumCallGroups = 1
      configuration.maximumCallsPerCallGroup = 1
      configuration.supportedHandleTypes = [.phoneNumber]
      configuration.ringtoneSound = "ring.wav"

      _provider = CXProvider(configuration: configuration)
      _provider.setDelegate(ProviderDelegateTrampoline.instance, queue: DispatchQueue.main)
    }
    
  func start(username : String, password : String, sipServer : String, sipRealm : String, stunHost : String, turnHost : String, turnUsername : String, turnPassword : String, turnRealm : String, iceEnabled : String, localPort : String, serverPort : String , transport : String, turnPort : String, stunPort : String) {
      
        print("turn port = \(turnPort)")
        print("stun port = \(stunPort)")
    print("username = \(username)")
    print("password = \(password)")
    print("sipServer = \(sipServer)")
    print("sipRealm = \(sipRealm)")
    print("stunHost = \(stunHost)")
    print("turnHost = \(turnHost)")
    print("turnUsername = \(turnUsername)")
    print("turnPassword = \(turnPassword)")
    print("turnRealm = \(turnRealm)")
    
    print("iceEnabled = \(iceEnabled)")
    print("localPort = \(localPort)")
    print("serverPort = \(serverPort)")
    print("transport = \(transport)")
    print("turnPort = \(turnPort)")
    //print("VoIPToken = \(VoIPToken)")
   
    
          let userName = username
          let password = password
          let sipServer = sipServer
          let siprealm = sipRealm
               
              let sipServerHost = CString(from: sipServer as! String)
              let sipUsername = CString(from: userName as! String)
              let sipPassword = CString(from: password as! String)
              let sipRealm = CString(from: siprealm as! String)

                 
                 defer { CString.release(sipUsername, sipPassword, sipRealm) }
                 
                 var sipTransport: CMSIPTRANSPORT = CM_UDP
                 
                     if transport == "tcp" || transport == "TCP" {
                         sipTransport = CM_TCP
                     }else if transport == "udp" || transport == "UDP" {
                         sipTransport = CM_UDP
                     }else if transport == "tls" || transport == "TLS" {
                         sipTransport = CM_TLS
                     }
                  let stunhostt = stunHost + (stunPort == "0" ? "" : (":" + stunPort))
                 var stunHost1 = CString(from: "")
      if stunHost == "-" {}
      else {
        stunHost1 = CString(from: stunhostt)
      }
      
      
      var turnHost1 = CString(from: turnHost)
      var turnUsername1 = CString(from: turnUsername)
      var turnPassword1 = CString(from: turnPassword)
      var turnRealm1 = CString(from: turnRealm)
                
      if turnHost == "-"{
        
      }
      else {
                  let turnhostt = turnHost + (turnPort == "0" ? "" : (":" + turnPort))
                  turnHost1 = CString(from: turnhostt)
                  turnUsername1 = CString(from: turnUsername)
                  turnPassword1 = CString(from: turnPassword)
                  turnRealm1 = CString(from: turnRealm)
      }
      
     
   
                
                   // Get the absolute path to the ringback file
                 let ringbackPath = Bundle.main.path(forResource: "ring", ofType: "wav")
                 let ringbackAudioFile = CString(from: ringbackPath!)

                   defer {
                     CString.release(
                       stunHost1, turnHost1, turnUsername1, turnPassword1, turnRealm1,
                       ringbackAudioFile)
                   }
                 
               var cmConfig = CMCONFIGURATION()
                         
                           CmInitializeConfiguration(&cmConfig)
                         
                           cmConfig.sip_server_host = sipServerHost.value
                            cmConfig.sip_local_port =   UInt16(Int(localPort) ?? 0)
                            cmConfig.sip_server_port =  UInt16(Int(serverPort) ?? 0)
                           cmConfig.sip_username = sipUsername.value
                           cmConfig.sip_password = sipPassword.value
                           cmConfig.sip_transport = sipTransport
                           cmConfig.sip_realm = sipRealm.value
                           cmConfig.stun_host = stunHost1.value
                           cmConfig.turn_host = turnHost1.value
                           cmConfig.turn_username = turnUsername1.value
                           cmConfig.turn_password = turnPassword1.value
                           cmConfig.turn_realm = turnRealm1.value
                           cmConfig.ringback_audio_file = ringbackAudioFile.value
                           cmConfig.answer_timeout = Int32(60)
//                           cmConfig.device_id = CString(from: "98ef9dff186b1fb5cc122549dd3be7606514a7850673b4ae8780ce171d8b13ff").value

                 let array: [String?] = ["G729/8000/1", "opus/48000/2", "opus/24000/2","PCMU/8000/1","PCMA/8000/1", nil]
                 var cargs = array.map { $0.flatMap { UnsafePointer<Int8>(strdup($0)) } }
                 command(&cargs)
                 cmConfig.desired_codecs = UnsafeMutablePointer(mutating: cargs)
                  cmConfig.enable_ice = iceEnabled == "true" ? CM_TRUE : CM_FALSE
                        
                if CmInitialize(&cmConfig) != CM_SUCCESS {
                   
                   DialerSubsystemFailure(
                     details: DialerErrorDetails(CM_SUBSYSTEM_FAILURE, "Initialization failure"))
                 }else{
                   
                 }
             // Set up callbacks
             CmSetInboundCallHandler({ handle in SipCallManager.shared.onInboundCall(handle: handle) })
              CmSetCallStateChangeHandler({ handle in
                SipCallManager.shared.onCallStateChanged(handle: handle)
              })
              _sipUriTemplate  = "sip:%s@\(sipServerHost):\(serverPort);transport=\(transport)"
           
    }
    
    func command(_ args: UnsafeMutablePointer<UnsafePointer<Int8>?>!){}
    
    func stop(){
        CmShutdown()
    }
    
    /*
    func restart(){
        stop()
        start()
    }
    */
    
    func register(){
      print("register called")
        let status = CmRegister()
        
        if status != CM_SUCCESS {
         
        }
    }
    
    func reset(){
        endCallKitCall()
        onHold = false
        isMuted = false
        isSpeakerOn = false
        inCall = false
        isConnecting = false
        _callTimer?.invalidate()
        _callTimer = nil
        phoneNumber = ""
        callStatus = CMCS_NONE
        callHandle = nil
        remotePartyClid = ""
    }
    
  
    
    func unregister(){
    
    reset()
    let status = CmUnregister()
      
      if status != CM_SUCCESS {
        
      }
    }
    
    func makeCall(outpulse: String, sipServer:String, sipPort:String, sipTransport:String){
        _currentCallUuid = UUID()
        let handle = CXHandle(type: .phoneNumber, value: outpulse)
        let action = CXStartCallAction(call: _currentCallUuid, handle: handle)
        action.isVideo = false
        action.contactIdentifier = outpulse

        _controller.requestTransaction(with: action) { error in
          if let error = error {
            self._provider.reportCall(with: self._currentCallUuid, endedAt: nil, reason: .failed)
          }else {
            self._provider.reportOutgoingCall(with: self._currentCallUuid, startedConnectingAt: Date())

            self.phoneNumber = outpulse
             
            self.register()
             
//            let uri = String(format: self._sipUriTemplate, arguments: [self.phoneNumber])
          
             let uri = "sip:\(outpulse)@\(sipServer):\(sipPort);transport=\(sipTransport)"
            
            print("uri of make call = \(uri)")
             
            let status = CmMakeCall(uri, &self.callHandle)
             
                    if status != CM_SUCCESS {
                    }
            self.inCall = true
            }
          
        }
    }
    
    private func startCallTimer() {
      DispatchQueue.main.async {
        self.callDuration = 0
        self._callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
          self.callDuration += 1
        }
      }
    }
    
    func muteMicrophone(){
      if callHandle != nil {
      let status = CmCallMuteMicrophone(callHandle)
      if status != CM_SUCCESS {
       
      }
      }
    }

    func isMicrophoneMuted() -> Bool {
      return CmCallIsMicrophoneMuted(callHandle) == CM_TRUE
    }

    func unmuteMicrophone(){
      if callHandle != nil {
        let status = CmCallUnmuteMicrophone(callHandle)
        if status != CM_SUCCESS {
          
        }
      }
     
    }
    
    func checkMicrophoneMuted(){
      muteCall()
    }
    
    func muteCall(){
            let holdValue = isMicrophoneMuted()
        
            if holdValue {
                unmuteMicrophone()
                isMuted = false
            }else {
                muteMicrophone()
                isMuted = true
            }
    }
    
    func holdCall(){
        if callHandle != nil {
            let groupId = CmCallGetGroupIdentifier(callHandle)
            CmHoldCurrentGroup()
        }
    }

    func resumeCall() {
        if callHandle != nil {
            let groupId = CmCallGetGroupIdentifier(callHandle)
            let status = CmResumeGroup(groupId)
            if status != CM_SUCCESS {}
        }
    }
    
    func checkHoldCall(){
        let holdValue = isOnHold()
        
        if holdValue {
            onHold = false
            resumeCall()
        }else {
           onHold = true
           holdCall()
        }
    }
    
    func holdAllCalls(){
        checkHoldCall()
        holdCallKit()
    }

    func isOnHold() -> Bool {
        if callHandle != nil {
            return CmCallIsOnHold(callHandle) == CM_TRUE
        }else {
            return false
        }
    }
    
    func configureAudioSession(_ audioSession: AVAudioSession) {
      
      do {
        try audioSession.setCategory(.playAndRecord)
        try audioSession.setMode(.voiceChat)
        try audioSession.setActive(true)
      } catch {
        
      }
    }
    
    func onAudioSessionActivated(_ audioSession: AVAudioSession) {
      configureAudioSession(audioSession)
      _activeAudioSession = audioSession
    }
    
     func onAudioSessionDeactivated(_ audioSession: AVAudioSession) {

      if (audioSession == _activeAudioSession) {
        _activeAudioSession = nil
      } else {
      }
    }
    
   
    func toggleSpeakerOnOff(on : Bool){
      let audioSession = AVAudioSession.sharedInstance()
      if on {
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                isSpeakerOn = true
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
      }else {
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            isSpeakerOn = false
            
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
      }
    }
    
    func toggleMicrophone(on: Bool){
      /*
      if on{
        self.muteMicrophone()
      }else{
        self.unmuteMicrophone()
      }
      */
    }
    func sendDTMFTone(tone: String){
       let status = CmCallSendDTMFTone(callHandle, Int8(tone.utf8.first!))
       if status != CM_SUCCESS {
        
       }
     }
    
    func DropAllCalls(){
        dropCall()
    }
    func dropCall() {
      
        DispatchQueue.main.async {
            var status: CMSTATUS
            if self.callHandle != nil {
                status = CmCallHangup(self.callHandle)
            }
            status = CmUnregister()
            if status != CM_SUCCESS {
              
            }
              
            self.callHandle = nil
            self.reset()
        }
    }
    
    
    func dropCallFromCallkit(){
        DispatchQueue.main.async {
            var status: CMSTATUS

            if self.callHandle != nil {
                status = CmCallHangup(self.callHandle)
                  
                if status != CM_SUCCESS {
                  
                }
            }
        
            status = CmUnregister()
            if status != CM_SUCCESS {
              
            }
              
            self.callHandle = nil
            self.reset()
            self.sipCallStatus?(CMCS_TERMINATED)
        }
    }
   
    
    func onCallStateChanged(handle: CMCALLHANDLE?) {
     
      var status: CMCALLSTATUS = CMCS_NONE
      if CmCallGetStatus(handle, &status) != CM_SUCCESS {
        return
      }
      print("status of call = \(status)")
      switch status {
      case CMCS_ANSWERED:
        isConnecting = true
        startCallTimer()
        ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "ANSWERED"])
      case CMCS_DECLINED:
        // Call declined by the remote end.
       print("CMCS_DECLINED")
        ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "DECLINED"])
        unregister()
      case CMCS_TERMINATED:
        // Call terminated by the remote end.
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "CallTermionated"), object: nil, userInfo: nil)
        
        ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "TERMINATED"])
        unregister()
      case CMCS_RINGING:
          print("Ringing")
        ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "RINGING"])
      default:
         print("default")
        
      }
      callStatus = status
      sipCallStatus?(status)
    }
    
    private func onInboundCall(handle: CMCALLHANDLE?) -> CMBOOL {
      let info = CallInfo(handle: handle!)
      
      guard let uuid = _pendingCallUUIDQueue.pop() else {
        return CM_FALSE
      }
      _callMap[uuid] = handle!
      
      onInboundCallArrived(uuid: uuid)
      
      return CM_TRUE
    }
  
  /// Invoked by the dialer whenever a new call arrives.
    fileprivate func onInboundCallArrived(uuid: UUID)  {
   
    // At this point we know more about the call. Tell CallKit about it so that it can
    // update the CallKit call screen if it is being shown.
    let info = self.getCallInfo(uuid: uuid)
    let remoteClid = info.remoteClid ?? "Unavailable"
    let remoteName = "Unknown"
    
    let update = CXCallUpdate()
    update.localizedCallerName = remoteClid
    _provider.reportCall(with: uuid, updated: update)
    
    // Update our published properties
    DispatchQueue.main.async {
//      self.remotePartyName = remoteName
      self.remotePartyClid = self.phoneNumber
    }

    _waitingForInboundCall.setAndNotify(newValue: false)
  }
  
  func getCallInfo(uuid: UUID) -> CallInfo {
    return CallInfo(handle: _callMap[uuid]!)
  }
  
  func getPayload(payload: PKPushPayload){
    processPayload(payload: payload, userInfo: payload.dictionaryPayload as NSDictionary)
  }
  
  func processPayload(payload: PKPushPayload, userInfo : NSDictionary){
    if let url : String = userInfo.value(forKey: "url") as? String{
        let substring = url.replacingOccurrences(of: "xone://incomingcall/", with: "")
        
        if let phoneNo : String = substring.replacingOccurrences(of: "?proxy=newxonesip.mvoipctsi.com&sound=ring.wav", with: "") as? String{
           print("phoneNo = \(phoneNo)")
          onPushArrived(payload: payload, phoneNumber: phoneNo)
        }
    }
  }
    
  func onPushArrived(payload: PKPushPayload, phoneNumber : String) {
      
      do {
        // Try to build an inbound call descriptor from the payload. If that is not
        // possible the InboundCallDescriptor constructor will throw.
        let descriptor = try InboundCallDescriptor(payload)
        // Save this information for later
        _inboundCallDescriptor = descriptor
        
        // If we're currently in the middle of a call setup then we abort the call that is
        // currently being set up. The inbound call taks priority. Of course, if we have an
        // establieshed current call then we'll proceed and let the user interact with
        // CallKit and decide how to proceed.
        if _makeCallInProgress.isEqualTo(true) {
          dropCurrentCall()
        }

        // Suppress published property reset. See the comment attached to the definition
        // of this field above. This is necessary here because, in those cases when the user
        // is already on a call when a push arrives and they decide to drop the current
        // call and accept the inbound one, CallKit will issue EndCall, followed by an
        // AnswerCall. If EndCall clears the inCall property and one of its observers
        // causes a call drop it may and probably will end up dropping the call that gets
        // established via AnswerCall.
        _suppressPublishedPropertyReset = true
        self.phoneNumber = phoneNumber
        let uuid = UUID()
       
        
        let update = CXCallUpdate()
        update.localizedCallerName = descriptor.localizedDisplayName
        update.hasVideo = descriptor.hasVideo
        update.remoteHandle = CXHandle(type: .phoneNumber, value: phoneNumber)
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = false
      
        _provider.reportNewIncomingCall(with: uuid, update: update) { error in
          if let error = error {
            
          } else {
            self._dispatchQueue.async {
              do {
                // Start waiting for a call here. Note that the following call doesn't block.
                // Once the call arrives, the underlying layers will invoke onInboundCallArrived
                // which will trip the blocking barrier.
                self._waitingForInboundCall.setAndNotify(newValue: true)
                try self.waitForCall(with: uuid)
              } catch {
               
              }
            }
          }
        }
      } catch {
        // Silently ignore invalid payloads.
      }
    }
    
    func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
        let count = str.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        str.withCString { (baseAddress) in
            result.initialize(from: baseAddress, count: count)
        }
        return result
    }
  
  /// Drops the current call.
  ///
  /// - Parameters:
  ///   - completion  Code to execute on action completion.
  func dropCurrentCall(completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
   

    // This is a no-op if we don't have a current call.
    // FIXME: should this be a precondition?
    if _currentCallUuid == SipCallManager.kNullUUID {
      return
    }

    // If there is a make call action in progress then we already have an action
    // callback in place. Therefore, we'll silently ignore the one provided by
    // the caller.
    if _makeCallInProgress.isEqualTo(false) {
      doUserActionStartup(completion)
    } else {
      // Unblock the task that is blocking on the make-call-in-progress flag.
      // It is up to the task to determine that the call did not get established.
      _makeCallInProgress.setAndNotify(newValue: false)
    }
  
    let action = CXEndCallAction(call: _currentCallUuid)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
      }
      self.doUserActionCleanup(error: error)
    }
  }
  
  private func doUserActionStartup(_ handler: @escaping ActionCompletion = { _ in /* Empty */}) {
    precondition(_actionCompletion == nil, "Another action already in progress")
    _actionCompletion = SingleFireCallback<Error>(callback: handler)
  }
  
  private func doUserActionCleanup(error: Error? = nil) {
    if var completion = _actionCompletion {
      DispatchQueue.main.async {
        completion.fire(with: error)
      }
      
      _actionCompletion = nil
    }
  }
  
  func waitForCall(with uuid: UUID) throws {
    _pendingCallUUIDQueue.push(uuid)
    print("wait for call called")
    register()
  }
  
  /// Handles the answer-call action. Invoked via the provider delegate trampoline.
  fileprivate func handleAnswerCallAction(_ action: CXAnswerCallAction) {
    print("handleAnswerCallAction called")
   // precondition(_currentCallUuid == SipCallManager.kNullUUID)
    
    
    self.inCall = true
    self.isConnecting = true
    self.callDuration = 0
    self._callTimer?.invalidate()
    
    // We no longer need this notification
    _inboundCallDescriptor = nil
    
    // This becomes our current call.
    _currentCallUuid = action.callUUID
    
    _dispatchQueue.async {
      self._handleAnswerCallActionAsync(action)
    }
  }
  
  fileprivate func _handleAnswerCallActionAsync(_ action: CXAnswerCallAction) {
    // Enable published property reset
      print("_handleAnswerCallActionAsync called")
    _suppressPublishedPropertyReset = false

    // The call may not be available just yet. Therefore, we'll wait for it to
    // arrive before we try to answer it.
//    if !_waitingForInboundCall.wait(untilEqualTo: false,
//                                    timeout: 60) {
//      action.fail()
//      return
//    }
    
    // Kludge alert! This is possibly related to: http://www.openradar.appspot.com/28774388.
    // The problem is that CallKit does not activate the audio session and we time out
    // below. The solution seems to be to configure the audio session ourselvees.
    configureAudioSession(AVAudioSession.sharedInstance())
    
    // Fulfill this action now. This is when CallKit will start initializing
    // the audio session. Note that this happens despite our sassion already having been
    // configured in the above step. Consequently, we end up configuring the session
    // twice.
    action.fulfill()
    
    // Now wait for the session to finish initializing. If we proceed and CallKit has not
    // finished initializing the audio session and answer the call, the call will end up
    // without audio.
    //
    // FIXME: for now, in case of timeout, we'll simply not answer the call. If we try
    // to drop the call at this point we may crash. This needs to be investigated.
//    if (!_audioSessionReady.wait(untilEqualTo: true, timeout: 0.5)) {
//      return
//    }
//
//
    
    do {
      // At this point we know we have a call that we can answer.
      try self.answerCall(uuid: action.callUUID)
      
      DispatchQueue.main.async {
        // Let everyone know that we're no longer connecting (we're connected).
        self.isConnecting = false;
      }
      
     
      startCallTimer()
      
    } catch {
      dropCurrentCall()
    }
    
  }
  
  func answerCall(uuid: UUID) throws {
    print("answer call")
    let status = CmCallAnswer(_callMap[uuid]!)
    
    if status != CM_SUCCESS {
      throw DialerSubsystemFailure(details: DialerErrorDetails(status, "Failed to answer"))
    }else {
      
    }
  }
  
  /// Processes an end-call action. Invoked via the provider delegate trampoline.
  fileprivate func handleEndCallAction(_ action: CXEndCallAction) {
  print("handleEndCallAction called")
    // If the call being dropped is the current call then we reset our current
    // call state and all of the published properties.
  
    if _currentCallUuid == action.callUUID {
      print("handleEndCallAction called 1")
      reset()
    }
  
    _dispatchQueue.async {
      print("handleEndCallAction called 2")
      self.dropCall(uuid: action.callUUID)
      action.fulfill()
    }
    
    doUserActionCleanup()
    
  }
  
  func dropCall(uuid: UUID) {
    // If this is a pending call then we don't yet have a handle for it. Therefore,
    // we just bail here.
    print("handleEndCallAction called 3")
    if _pendingCallUUIDQueue.remove(uuid) {
      return
    }
    
    if let handle = _callMap[uuid] {
    _callMap[uuid] = nil
    
      if handle != nil {
        CmCallHangup(handle)
        CmUnregister()
      }
    }
  }
}

extension SipCallManager {
    func startCallKitCall(phoneNumber : String){
        _currentCallUuid = UUID()
        let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
        let startCallAction = CXStartCallAction(call: _currentCallUuid, handle: handle)
        startCallAction.isVideo = false
        let transaction = CXTransaction(action: startCallAction)
        _controller.request(transaction) { (error) in
            print("error = \(String(describing: error))")
            if error != nil {
                self._provider.reportCall(with: self._currentCallUuid, endedAt: nil, reason: .failed)
            }else {
                
            }
          
        }
    }
    
    func startCallAction(_ action: CXStartCallAction){
        self._provider.reportOutgoingCall(with: self._currentCallUuid, connectedAt: nil)
                register()
         
               let uri = String(format: _sipUriTemplate, arguments: [phoneNumber])
         
               let status = CmMakeCall(uri, &callHandle)
         
               if status != CM_SUCCESS {
                action.fail()
               }else {
                action.fulfill()
            }
               inCall = true

    }
    
    func endCallKitCall(){
      if _currentCallUuid != SipCallManager.kNullUUID {
        let action = CXEndCallAction(call: _currentCallUuid)
        _controller.requestTransaction(with: action) { (error) in
            print("error = \(String(describing: error))")
        }
      }
    }
  
  // Invoked by the dialer whenever a call is terminated by the remote end.
  private func onRemoteCallTerminated(uuid: UUID) {
    // If a make-call action is currently in progress we'll terminate it here.
    // Whatever is waiting for this value to change will have to handle the dropped
    // call. Otherwise, the call is already in progress and we'll have to tear it down.
    if uuid == _currentCallUuid && _makeCallInProgress.isEqualTo(true) {
      _makeCallInProgress.setAndNotify(newValue: false)
      return
    }
    
    // Otherwise, attempt to tear down the call via CallKit.
    let action = CXEndCallAction(call: uuid)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
      }
    }
  }
  
    
    func handleAction(){
        self.dropCall()
    }
    
    func muteCallKit() {
    let action = CXSetMutedCallAction(call: _currentCallUuid, muted: isMuted)

       _controller.requestTransaction(with: action) { error in
         if let error = error {
           
         }
       }
    }
    
    func holdCallKit(){
        let action = CXSetHeldCallAction(call: _currentCallUuid, onHold: onHold)

        _controller.requestTransaction(with: action) { error in
          if let error = error {
           
            }
        }
    }
 
}

///
/// CXProvider delegate implementation.
///
internal class ProviderDelegateTrampoline: NSObject, CXProviderDelegate {
  static let instance = ProviderDelegateTrampoline()

  private override init() {
    super.init()
  }

  func providerDidReset(_ provider: CXProvider) {
   // SipCallManager.shared.dropCurrentCall { _ in /* Ignored */ }
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    SipCallManager.shared.onAudioSessionActivated(audioSession)
  }
  
  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
  
  }

  func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
   
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    SipCallManager.shared.handleAnswerCallAction(action)
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    //action.fulfill()
   SipCallManager.shared.handleEndCallAction(action)
  }

  func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
    SipCallManager.shared.checkHoldCall()
  }

  func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
    SipCallManager.shared.muteCall()
  }
}






