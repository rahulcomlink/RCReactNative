//
//  SIPSDKBridge.swift
//  RocketChatRN
//
//  Created by Arti Mane on 09/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
import PushKit
import AVFoundation
import Contacts

@objc(SIPSDKBridge)
class SIPSDKBridge : NSObject{
  
  static let shared = SIPSDKBridge()
  private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"
  var callManager = CallManager.shared
  
  @objc func callbackMethod(_ callback: RCTResponseSenderBlock) -> Void {
    
    if let voiptoken = UserDefaults.standard.value(forKey: "voipToken") as? String {
      let resultsDict = [
       "voiptoken" : voiptoken
       ];
      callback([NSNull() ,resultsDict])
    }
  }
  
  @objc func sipRegistration(_ username: String,  password: String,  sipServer: String,  sipRealm: String,  stunHost: String, turnHost : String,  turnUsername: String,  turnPassword: String,  turnRealm: String,  iceEnabled: String,  localPort: String,  serverPort: String, transport: String, turnPort: String, stunPort: String) -> Void{
    
    
    let config = Configuration.shared
    config.sipServerHost = sipServer
    config.sipUsername = username
    config.sipPassword = password
    config.sipRealm = "*"
   
    if transport == "TCP" || transport == "tcp"{
      config.sipTransport = 0
    }else if transport == "TLS" || transport == "tls"{
      config.sipTransport = 1
    }else if transport == "UDP" || transport == "udp"{
      config.sipTransport = 2
    }
    
    config.sipLocalPort = localPort.isEmpty ? 0 : UInt16(localPort)!
    config.sipServerPort = serverPort.isEmpty ? 0 : UInt16(serverPort)!
    config.turnHost = turnHost
    config.turnUsername = turnUsername
    config.turnPassword = turnPassword
    config.turnRealm = ""
    config.stunHost = stunHost
    config.iceEnabled = iceEnabled  == "true" ? true : false
    config.srtpEnabled = false
    config.answerTimeout = Double(60)
    do {
      try config.doPostUpdateActions()
    } catch {
      // FIXME: exception handling
    }
  }
  
  @objc func sipStop() -> Void{
    NSLog("sipStop")
    SipCallManager.shared.stop()
  }
 
  @objc func makeCall(_ phoneNumber: String, sipServer: String, sipPort: String, sipTransport: String) -> Void{
    self.callManager.makeCall(outpulse: phoneNumber)
//    SipCallManager.shared.makeCall(outpulse: phoneNumber, sipServer: sipServer, sipPort: sipPort, sipTransport: sipTransport)
  }
 
  @objc func endCall()  -> Void{
    self.callManager.dropCurrentCall { error in
      print("error while disconnecting call from RN")
    }
    //SipCallManager.shared.DropAllCalls()
   }
  
  @objc func setSpeakerOn(_ on: Bool) -> Void{
    self.callManager.toggleSpeaker { error in
      print("error while enabling sound")
    }
    //SipCallManager.shared.toggleSpeakerOnOff(on: on)
  }
  
  @objc func setMuteOn(_ on: Bool) -> Void{
    self.callManager.muteOrUnmuteCall { error in
      print("error while enabling mute")
    }
   // SipCallManager.shared.toggleMicrophone(on: on)
  }
  
  @objc func keyPressed(_ key: String) -> Void{
    CallManager.shared.sendDtmf(digit: key) { _ in /* Ignored */ }
    //SipCallManager.shared.sendDTMFTone(tone: key)
  }
  
  @objc func sendVoIPPhoneNumber(payload : PKPushPayload){
    Logger.attachSDKLogger()
    PushManager.shared.onPushArrived(payload)
   // SipCallManager.shared.getPayload(payload: payload)
  }
  
  @objc func getVOIPToken(voipToken : PKPushCredentials){
    
    let voippToken = voipToken.token.reduce("") {
        return $0 + String(format: "%02x", $1)
    }
    print("voippToken = \(voippToken)")
    UserDefaults.standard.setValue(voippToken, forKey: "voipToken")
  }
  
  @objc func startSipSetting(){
    SipCallManager.shared.startSipSettings()
  }
  
  @objc func getMicrophonePermission(){
    var permissionCheck:Bool = false

    switch AVAudioSession.sharedInstance().recordPermission {

            case AVAudioSession.RecordPermission.granted:
                permissionCheck = true

            case AVAudioSession.RecordPermission.denied:
                permissionCheck = false
            case AVAudioSession.RecordPermission.undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if granted {
                        permissionCheck = true
                    } else {
                        permissionCheck = false
                    }
                })
            default:
                break
            }
    print("permissionCheck = \(permissionCheck)")
  }
  
  @objc func configureAudioSession1(){
    SipCallManager.shared.configureAudioSession1()
  }
  
  @objc func acceptCallAfterAppLaunch(){
    callManager.answerFromAppLaunch()
  }
  
  @objc func checkFlagValue() ->String {
    if MyVariables.shared.yourVariable == true {
      return "true"
    }else {
      return "false"
    }
  }
  
  @objc func checkVoIPIncomingcallbackMethod(_ callback: RCTResponseSenderBlock) -> Void {
      let resultsDict = [
        "isIncomingCall" : self.callManager.inCall == true ? "true" : "false",
        "phoneNumber" : self.callManager.remotePartyClid
       ];
      callback([NSNull() ,resultsDict])
  }
  
  @objc func setAppLaunchFlag(){
    MyVariables.shared.yourVariable = true
   // self.callManager.isAppLaunch = true
    UserDefaults.standard.setValue("true", forKey: "isAppLaunch")
    UserDefaults.standard.synchronize()
  }

  
  //Start From New
  
  @objc func startSipAndPushOnAppLaunch(){
   // PushManager.shared.start()
    CallManager.shared.start()
    
    // Fire up the contact manager
    try! ContactManager.shared.start()
    
    // Request contacts access for the one-time sync operation.
    let contactStore = CNContactStore()
    contactStore.requestAccess(for: CNEntityType.contacts) { (granted, error) in
      if granted && error == nil {
        ContactManager.shared.importNativeContacts()
      }
    }
  }
 
}

