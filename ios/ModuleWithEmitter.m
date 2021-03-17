//
//  ModuleWithEmitter.m
//  RocketChatRN
//
//  Created by Arti Mane on 12/02/21.
//  Copyright © 2021 Facebook. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>


@interface RCT_EXTERN_MODULE(ModuleWithEmitter, RCTEventEmitter)
  RCT_EXTERN_METHOD(supportedEvents)
@end
