//
//  SIPSDKBridge.m
//  RocketChatRN
//
//  Created by Arti Mane on 09/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(SIPSDKBridge, NSObject)

RCT_EXTERN_METHOD(sipRegistration)
RCT_EXTERN_METHOD(makeCall:(NSString *)phoneNumber)
RCT_EXTERN_METHOD(endCall)
RCT_EXTERN_METHOD(setSpeakerOn:(BOOL *)on)
RCT_EXTERN_METHOD(setMuteOn:(BOOL *)on)
RCT_EXTERN_METHOD(keyPressed:(NSString *)key)

@end
