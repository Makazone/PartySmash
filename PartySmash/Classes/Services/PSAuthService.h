//
// Created by Makar Stetsenko on 08.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKSdk.h"
#import "Parse/PFUser.h"

@interface PSAuthService : NSObject

+ (void)signUpVKUser:(NSNumber *)vkId withNickname:(NSString *)nickname avatar100:(NSData *)avatar100 avatar200:(NSData *)avatar200
   completionHandler:(void  (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)loginVK:(id <VKSdkDelegate>)delegate block:(void (^)(PFUser *user, NSError *error))completionBlock;

+ (BOOL)checkIfUserExists:(NSNumber *)vkId;

+ (BOOL)isUserLoggedIn;

@end