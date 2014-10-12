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
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"55c38003fe168a16c9624d18feed343b7867318d"];

    [GMSServices provideAPIKey:@"AIzaSyD9JW-4PuB06bNVSPQUGfu4wZP7-ErXUT8"];

    [PSUser registerSubclass];
    [PSParty registerSubclass];
    
    [Parse setApplicationId:@"5jOeErzAv4j5BCWsLxNrjicpDvnhnH5cyyds6X4n" clientKey:@"gKJOrNRPpxW9i4lyWwaVog3apmaNsI3HR02sft4k"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BarBG"] forBarMetrics:UIBarMetricsDefault];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:97/255.0 green:36/255.0 blue:99/255.0 alpha:1.0]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:97/255.0 green:36/255.0 blue:99/255.0 alpha:1.0]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

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

@end
