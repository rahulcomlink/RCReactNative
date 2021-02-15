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

RCT_EXTERN_METHOD(sipRegistration:(NSString *)username (NSString *)password (NSString *)sipServer (NSString *)sipRealm (NSString *)stunHost (NSString *)turnHost (NSString *)turnUsername (NSString *)turnPassword (NSString *)turnRealm (NSString *)iceEnabled (NSString *)localPort (NSString *)serverPort (NSString *)transport (NSString *)turnPort (NSString *)stunPort)
RCT_EXTERN_METHOD(sipStop)
RCT_EXTERN_METHOD(makeCall:(NSString *)phoneNumber (NSString *)sipServer (NSString *)sipPort (NSString *)sipTransport)
RCT_EXTERN_METHOD(endCall)
RCT_EXTERN_METHOD(setSpeakerOn:(BOOL *)on)
RCT_EXTERN_METHOD(setMuteOn:(BOOL *)on)
RCT_EXTERN_METHOD(keyPressed:(NSString *)key)

@end
