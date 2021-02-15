//
//  CallInterFace.swift
//  XONE
//
//  Created by Vinod Jat on 02/06/20.
//  Copyright © 2020 CONNECTION PORTAL INC. All rights reserved.
//

import UIKit

@objcMembers

class CallInterFace: NSObject {
    static let shareInstance = CallInterFace()
/*
    @objc func startCallManager(){
        try! CallManager.shared.start()
    }
    
    @objc func makeOutGoingCall(number : String){
        CallManager.shared.makeCall(outpulse: number)
    }
    
    @objc func startCallAfterBuddyAPI(){
        CallManager.shared.startCallAfterBuddyListAPICalled()
    }
    
   /* @objc func dropCurrentCall(incomingCallVC : IncomingCallScreen){
        CallManager.shared.dropCurrentCall { (error) in
            incomingCallVC.dismiss(animated: true, completion: nil)
        }
    }
    */
    @objc func dropCurrentCall(){
        CallManager.shared.dropCurrentCall { (error) in
            //incomingCallVC.dismiss(animated: true, completion: nil)
        }
    }
 */
}
