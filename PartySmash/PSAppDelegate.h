//
//  PSAppDelegate.h
//  PartySmash
//
//  Created by Makar Stetsenko on 22.05.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface PSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)registerForNotifications;

/**
* Google Analytics
*/

- (void)trackScreen:(NSString *)name;
- (void)trackEventWithCategory:(NSString *)category action:(NSString*)action label:(NSString *)label value:(NSNumber *)value;

- (BOOL)isUserRunningIOS8;

@end
