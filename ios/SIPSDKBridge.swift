//
//  SIPSDKBridge.swift
//  RocketChatRN
//
//  Created by Arti Mane on 09/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
import PushKit

@objc(SIPSDKBridge)
class SIPSDKBridge : NSObject{
  
  static let shared = SIPSDKBridge()
  private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"
  
  @objc func sipRegistration(_ username: String,  password: String,  sipServer: String,  sipRealm: String,  stunHost: String, turnHost : String,  turnUsername: String,  turnPassword: String,  turnRealm: String,  iceEnabled: String,  localPort: String,  serverPort: String, transport: String, turnPort: String, stunPort: String,VoIPToken: String) -> Void{
    SipCallManager.shared.start(username: username, password: password, sipServer: sipServer, sipRealm: sipRealm, stunHost: stunHost, turnHost: turnHost, turnUsername: turnUsername, turnPassword: turnPassword, turnRealm: turnRealm, iceEnabled: iceEnabled, localPort: localPort, serverPort: serverPort, transport: transport, turnPort: turnPort, stunPort: stunPort,VoIPToken: VoIPToken)
  }
  
  @objc func sipStop() -> Void{
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
    //SipCallManager.shared.toggleMicrophone(on: on)
  }
  
  @objc func keyPressed(_ key: String) -> Void{
    SipCallManager.shared.sendDTMFTone(tone: key)
  }
  
  @objc func sendVoIPPhoneNumber(payload : PKPushPayload){
    ModuleWithEmitter.emitter.sendEvent(withName: "testCall", body: ["phoneNumber" :"self.phoneNumber"])
    SipCallManager.shared.getPayload(payload: payload)
  }
  
  @objc func getVOIPToken(voipToken : PKPushCredentials){
    
    let voippToken = voipToken.token.reduce("") {
        return $0 + String(format: "%02x", $1)
    }
    print("voippToken = \(voippToken)")
  }
 
}

