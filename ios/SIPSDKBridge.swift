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

@objc(SIPSDKBridge)
class SIPSDKBridge : NSObject{
  
  static let shared = SIPSDKBridge()
  private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"
  
  @objc func callbackMethod(_ callback: RCTResponseSenderBlock) -> Void {
    
    if let voiptoken = UserDefaults.standard.value(forKey: "voipToken") as? String {
      let resultsDict = [
       "voiptoken" : voiptoken
       ];
      callback([NSNull() ,resultsDict])
    }
  }
  
  @objc func sipRegistration(_ username: String,  password: String,  sipServer: String,  sipRealm: String,  stunHost: String, turnHost : String,  turnUsername: String,  turnPassword: String,  turnRealm: String,  iceEnabled: String,  localPort: String,  serverPort: String, transport: String, turnPort: String, stunPort: String) -> Void{
    
    UserDefaults.standard.setValue(username, forKey: "username")
    UserDefaults.standard.setValue(password, forKey: "password")
    UserDefaults.standard.setValue(sipServer, forKey: "sipServer")
    UserDefaults.standard.setValue(stunHost, forKey: "stunHost")
    UserDefaults.standard.setValue(turnHost, forKey: "turnHost")
    UserDefaults.standard.setValue(turnUsername, forKey: "turnUsername")
    UserDefaults.standard.setValue(turnPassword, forKey: "turnPassword")
    UserDefaults.standard.setValue(iceEnabled, forKey: "iceEnabled")
    UserDefaults.standard.setValue(localPort, forKey: "localPort")
    UserDefaults.standard.setValue(serverPort, forKey: "serverPort")
    UserDefaults.standard.setValue(transport, forKey: "transport")
   
    SipCallManager.shared.start(username: username, password: password, sipServer: sipServer, sipRealm: sipRealm, stunHost: stunHost, turnHost: turnHost, turnUsername: turnUsername, turnPassword: turnPassword, turnRealm: turnRealm, iceEnabled: iceEnabled, localPort: localPort, serverPort: serverPort, transport: transport, turnPort: turnPort, stunPort: stunPort)
  }
  
  @objc func sipStop() -> Void{
    NSLog("sipStop")
    SipCallManager.shared.stop()
  }
 
  @objc func makeCall(_ phoneNumber: String, sipServer: String, sipPort: String, sipTransport: String) -> Void{
    SipCallManager.shared.makeCall(outpulse: phoneNumber, sipServer: sipServer, sipPort: sipPort, sipTransport: sipTransport)
  }
 
  @objc func endCall()  -> Void{
    SipCallManager.shared.DropAllCalls()
   }
  
  @objc func setSpeakerOn(_ on: Bool) -> Void{
    SipCallManager.shared.toggleSpeakerOnOff(on: on)
  }
  
  @objc func setMuteOn(_ on: Bool) -> Void{
    SipCallManager.shared.toggleMicrophone(on: on)
  }
  
  @objc func keyPressed(_ key: String) -> Void{
    SipCallManager.shared.sendDTMFTone(tone: key)
  }
  
  @objc func sendVoIPPhoneNumber(payload : PKPushPayload){
    Logger.attachSDKLogger()
    SipCallManager.shared.getPayload(payload: payload)
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
    SipCallManager.shared.acceptCallAfterAppLaunch()
  }
 
}

