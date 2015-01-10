//
//  PSAppDelegate.m
//  PartySmash
//
//  Created by Makar Stetsenko on 22.05.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSAppDelegate.h"
#import "VKSdk.h"
#import "PSUser.h"
#import "PSParty.h"
#import "PSEvent.h"
#import "PSNotification.h"
#import <Crashlytics/Crashlytics.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "PSAuthService.h"
#import "iRate.h"

#import <Instabug/Instabug.h>

//#define DEVELOPMENT

@implementation PSAppDelegate

+ (void)initialize {
    [[iRate sharedInstance] setApplicationBundleID:@"ru.partysmash.PartySmash"];
//    [iRate sharedInstance].previewMode = YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PSUser registerSubclass];
    [PSParty registerSubclass];
    [PSEvent registerSubclass];
    [PSNotification registerSubclass];

    #ifdef DEVELOPMENT
    [Parse setApplicationId:@"nda02vKLjBCCPmvsYVV7SacA1yb9c61vi1oGM7xW" clientKey:@"SrN93G9JUwJdpMfcINbdJ8tJXBYlwgGpH4sqYfRW"];
    [GAI sharedInstance].optOut = YES;
    #else
    [Parse setApplicationId:@"5jOeErzAv4j5BCWsLxNrjicpDvnhnH5cyyds6X4n" clientKey:@"gKJOrNRPpxW9i4lyWwaVog3apmaNsI3HR02sft4k"];
    #endif

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;

    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-52406320-3"];
    
    // Enable IDFA collection.
    [[GAI sharedInstance] defaultTracker].allowIDFACollection = YES;

    if ([PSAuthService isUserLoggedIn]) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

        // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
        // sent with all subsequent hits.
        [tracker set:@"&uid"
               value:[PSUser currentUser].objectId];

        [[Crashlytics sharedInstance] setUserIdentifier:[PSUser currentUser].objectId];
    }
    

    [GMSServices provideAPIKey:@"AIzaSyD9JW-4PuB06bNVSPQUGfu4wZP7-ErXUT8"]; // GoogleMapAPI

    [VKSdk initializeWithDelegate:nil andAppId:@"4444128"];

    [[Crashlytics sharedInstance] setDebugMode:NO];
    [Crashlytics startWithAPIKey:@"55c38003fe168a16c9624d18feed343b7867318d"];

    [Instabug startWithToken:@"126955ab42f0c95d9ae7b4a3d10c9301"captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BarBG"] forBarMetrics:UIBarMetricsDefault];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:97/255.0 green:36/255.0 blue:99/255.0 alpha:1.0]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:97/255.0 green:36/255.0 blue:99/255.0 alpha:1.0]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];


    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%s", sel_getName(_cmd));
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)registerForNotifications {
    // Register for Push Notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
            UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound);

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:userNotificationTypes];
    }
}

- (void)trackScreen:(NSString *)name {
    // May return nil if a tracker has not already been initialized with a property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];

    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:name];

    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    //May return nil if a tracker has not already been initialized with a property
    //ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label          // Event label
                                                           value:value] build]];    // Event value
}

- (BOOL)isUserRunningIOS8 {
    if ([[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."][0] intValue] >= 8) {
        return YES;
    } else return NO;
}


@end
