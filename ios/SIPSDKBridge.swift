//
//  SIPSDKBridge.swift
//  RocketChatRN
//
//  Created by Arti Mane on 09/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation
@objc(SIPSDKBridge)
class SIPSDKBridge : NSObject{
  
  static let shared = SIPSDKBridge()
  private var _sipUriTemplate: String = "sip:%%s@%s:8993;transport=tcp"
  
  @objc func sipRegistration(_ username: String, _ password: String, _ sipServer: String, _ sipRealm: String, _ stunHost: String, turnHost : String, _ turnUsername: String, _ turnPassword: String, _ turnRealm: String, _ iceEnabled: String, _ localPort: String, _ serverPort: String,_ transport: String,_ turnPort: String,_ stunPort: String) -> Void{
    SipCallManager.shared.start(username: username, password: password, sipServer: sipServer, sipRealm: sipRealm, stunHost: stunHost, turnHost: turnHost, turnUsername: turnUsername, turnPassword: turnPassword, turnRealm: turnRealm, iceEnabled: iceEnabled, localPort: localPort, serverPort: serverPort, transport: transport, turnPort: turnPort, stunPort: stunPort)
  }
  
  @objc func sipStop() -> Void{
    SipCallManager.shared.stop()
  }
 
  @objc func makeCall(_ phoneNumber: String,_ sipServer: String,_ sipPort: String,_ sipTransport: String) -> Void{
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
 
}
