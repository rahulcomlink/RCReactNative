/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTLinkingManager.h>
#import "RNNotifications.h"
#import "RNBootSplash.h"
#import "Orientation.h"
#import <Firebase.h>
#import <UMCore/UMModuleRegistry.h>
#import <UMReactNativeAdapter/UMNativeModulesProxy.h>
#import <UMReactNativeAdapter/UMModuleRegistryAdapter.h>
#import <MMKV/MMKV.h>

#if DEBUG
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>
#import <Firebase.h>
#import <RocketChatRN-Swift.h>

#import <PushKit/PushKit.h>
//#import "RNVoipPushNotificationManager.h"


static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //[self redirectLogToDocuments];
  NSLog(@"launchoptions = %@",launchOptions);
  NSLog(@"didFinishLaunchingWithOptions");
    #if DEBUG
      InitializeFlipper(application);
    #endif

    self.moduleRegistryAdapter = [[UMModuleRegistryAdapter alloc] initWithModuleRegistryProvider:[[UMModuleRegistryProvider alloc] init]];
    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
    if(![FIRApp defaultApp]){
      [FIRApp configure];
    }
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                moduleName:@"RocketChatRN"
                                                initialProperties:nil];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view = rootView;
    [RNBootSplash initWithStoryboard:@"LaunchScreen" rootView:rootView];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    [RNNotifications startMonitorNotifications];
    [ReplyNotification configure];
  
  
  SIPSDKBridge * obj = [[SIPSDKBridge alloc]init];
//  [obj startSipSetting];
  [obj getMicrophonePermission];
    
    [self voipRegistration];
  
    // AppGroup MMKV
    NSString *groupDir = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppGroup"]].path;
    [MMKV initializeMMKV:nil groupDir:groupDir logLevel:MMKVLogNone];
  
    // Start the MMKV container
    MMKV *defaultMMKV = [MMKV mmkvWithID:@"migration" mode:MMKVMultiProcess];
    BOOL alreadyMigrated = [defaultMMKV getBoolForKey:@"alreadyMigrated"];

    if (!alreadyMigrated) {
      // MMKV Instance that will be used by JS
      MMKV *mmkv = [MMKV mmkvWithID:@"default" mode:MMKVMultiProcess];

      // NSUserDefaults -> MMKV (Migration)
      NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppGroup"]];
      [mmkv migrateFromUserDefaults:userDefaults];
      // Remove our own keys of NSUserDefaults
      for (NSString *key in [userDefaults dictionaryRepresentation].keyEnumerator) {
        [userDefaults removeObjectForKey:key];
      }

      // Mark migration complete
      [defaultMMKV setBool:YES forKey:@"alreadyMigrated"];
    }
  
  [[NSUserDefaults standardUserDefaults]setValue:@"true" forKey:@"isAppLaunch"];
  [[NSUserDefaults standardUserDefaults]synchronize];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
  NSLog(@"applicationDidBecomeActive");
  
  if([[[NSUserDefaults standardUserDefaults]valueForKey:@"isAppLaunch"] isEqualToString:@"true"] && [[[NSUserDefaults standardUserDefaults]valueForKey:@"isVoipCall"] isEqualToString:@"true"]){
    [[NSUserDefaults standardUserDefaults]setValue:@"false" forKey:@"isAppLaunch"];
    [[NSUserDefaults standardUserDefaults]setValue:@"false" forKey:@"isVoipCall"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self performSelector:@selector(callFuncAfterDelay) withObject:nil afterDelay:5.0];
  }
}

- (void)callFuncAfterDelay{
  SIPSDKBridge * obj = [[SIPSDKBridge alloc]init];
  NSLog(@"isVoipCall value true");
  [obj acceptCallAfterAppLaunch];
}


- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge
{
  NSArray<id<RCTBridgeModule>> *extraModules = [_moduleRegistryAdapter extraModulesForBridge:bridge];
  // You can inject any extra modules that you would like here, more information at:
  // https://facebook.github.io/react-native/docs/native-modules-ios.html#dependency-injection
  return extraModules;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [RNNotifications didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  [RNNotifications didFailToRegisterForRemoteNotificationsWithError:error];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [RCTLinkingManager application:application openURL:url
                      sourceApplication:sourceApplication annotation:annotation];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
  return [Orientation getOrientation];
}

// Only if your app is using [Universal Links](https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html).
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
  return [RCTLinkingManager application:application
                   continueUserActivity:userActivity
                     restorationHandler:restorationHandler];
}


- (void)applicationWillTerminate:(UIApplication *)application{
  [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isAppLaunch"];
  [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"isVoipCall"];
  [[NSUserDefaults standardUserDefaults]synchronize];
}



// Register for VoIP notifications
- (void) voipRegistration {
  dispatch_queue_t mainQueue = dispatch_get_main_queue();
  // Create a push registry object
  PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
  // Set the registry's delegate to self
  voipRegistry.delegate = self;
  // Set the push type to VoIP
  voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

// --- Handle updated push credentials
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type {
  // Register VoIP push token (a property of PKPushCredentials) with server
  NSLog(@"didUpdatePushCredentials");
  NSLog(@"voip token = %@",credentials.token);
    SIPSDKBridge * object = [[SIPSDKBridge alloc]init];
    [object getVOIPTokenWithVoipToken:credentials];
    
  

 // [RNVoipPushNotificationManager didUpdatePushCredentials:credentials forType:(NSString *)type];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
  // --- The system calls this method when a previously provided push token is no longer valid for use. No action is necessary on your part to reregister the push type. Instead, use this method to notify your server not to send push notifications using the matching push token.
}

// --- Handle incoming pushes
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
  NSLog(@"push payload comes %@",payload);
  
  [[NSUserDefaults standardUserDefaults]setValue:@"false" forKey:@"isAppLaunch"];
  [[NSUserDefaults standardUserDefaults]setValue:@"true" forKey:@"isVoipCall"];
  [[NSUserDefaults standardUserDefaults]synchronize];
  //[self redirectLogToDocuments];
  SIPSDKBridge * object = [[SIPSDKBridge alloc]init];
  [object sendVoIPPhoneNumberWithPayload:payload];

  completion();
}

-(void)redirectLogToDocuments
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:@"yourFile.txt"];
    
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a",stderr);
}
@end
