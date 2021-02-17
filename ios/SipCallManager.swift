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


  class SipCallManager{
  
    static let shared = SipCallManager()
    private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"
    var callHandle: CMCALLHANDLE?
    
    typealias updateCallStatus = (CMCALLSTATUS) -> Void
    var sipCallStatus : updateCallStatus?
    
    private let _controller = CXCallController()
    private let _provider: CXProvider
    
    var _currentCallUuid: UUID = UUID(uuid: UUID_NULL)
    
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
    
    func start(username : String, password : String, sipServer : String, sipRealm : String, stunHost : String, turnHost : String, turnUsername : String, turnPassword : String, turnRealm : String, iceEnabled : String, localPort : String, serverPort : String , transport : String, turnPort : String, stunPort : String ) {
  
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
      
      
      var turnHost1 = CString(from: "")
      var turnUsername1 = CString(from: "")
      var turnPassword1 = CString(from: "")
      var turnRealm1 = CString(from: "")
                
      if turnHost == "-"{
        
      }
      else {
                  let turnhostt = turnHost + (turnHost == "0" ? "" : (":" + turnPort))
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
//              CmSetInboundCallHandler({ handle in Dialer.shared.onInboundCall(handle: handle) })
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
      let status = CmCallMuteMicrophone(callHandle)
      if status != CM_SUCCESS {
       
      }
    }

    func isMicrophoneMuted() -> Bool {
      return CmCallIsMicrophoneMuted(callHandle) == CM_TRUE
    }

    func unmuteMicrophone(){
      let status = CmCallUnmuteMicrophone(callHandle)
      if status != CM_SUCCESS {
        
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
//      if on{
//        self.muteMicrophone()
//      }else{
//        self.unmuteMicrophone()
//      }
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
    
    func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
        let count = str.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
        str.withCString { (baseAddress) in
            result.initialize(from: baseAddress, count: count)
        }
        return result
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
        let action = CXEndCallAction(call: _currentCallUuid)
        _controller.requestTransaction(with: action) { (error) in
            print("error = \(String(describing: error))")
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
  
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
    SipCallManager.shared.checkHoldCall()
  }

  func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
    SipCallManager.shared.muteCall()
  }
}






