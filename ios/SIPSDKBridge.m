//
//  SIPSDKBridge.m
//  RocketChatRN
//
//  Created by Arti Mane on 09/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"
#import <PushKit/PushKit.h>

@interface RCT_EXTERN_MODULE(SIPSDKBridge, NSObject)

RCT_EXTERN_METHOD(sipRegistration:(NSString *)username password:(NSString *)password sipServer:(NSString *)sipServer sipRealm:(NSString *)sipRealm stunHost:(NSString *)stunHost turnHost:(NSString *)turnHost turnUsername:(NSString *)turnUsername turnPassword:(NSString *)turnPassword turnRealm:(NSString *)turnRealm iceEnabled:(NSString *)iceEnabled localPort:(NSString *)localPort serverPort:(NSString *)serverPort transport:(NSString *)transport turnPort:(NSString *)turnPort stunPort:(NSString *)stunPort )
RCT_EXTERN_METHOD(sipStop)
RCT_EXTERN_METHOD(makeCall:(NSString *)phoneNumber sipServer:(NSString *)sipServer sipPort:(NSString *)sipPort sipTransport:(NSString *)sipTransport)
RCT_EXTERN_METHOD(endCall)
RCT_EXTERN_METHOD(setSpeakerOn:(BOOL *)on)
RCT_EXTERN_METHOD(setMuteOn:(BOOL *)on)
RCT_EXTERN_METHOD(keyPressed:(NSString *)key)
RCT_EXTERN_METHOD(sendVoIPPhoneNumber:(PKPushPayload *)payload)
RCT_EXTERN_METHOD(getVOIPToken:(PKPushCredentials *)voipToken)
@end
