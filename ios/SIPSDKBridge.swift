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
  
  @objc func sipRegistration()  -> Void{
    SipCallManager.shared.start()
  }
  
  @objc func makeCall(_ phoneNumber: String) -> Void{
    SipCallManager.shared.makeCall(outpulse: phoneNumber)
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
