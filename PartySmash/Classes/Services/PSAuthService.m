//
// Created by Makar Stetsenko on 08.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSAuthService.h"

static NSString *const PS_VK_TOKEN_KEY = @"4444128";
static NSString *const VK_PASS   = @"password";

@implementation PSAuthService {

}

+ (BOOL)isUserLoggedIn {
    PFUser *currentUser = [PFUser currentUser];
    return currentUser != nil;
}

+ (void)signUpVKUser:(NSNumber *)vkId withNickname:(NSString *)nickname avatar100:(NSData *)avatar100 avatar200:(NSData *)avatar200
   completionHandler:(void  (^)(BOOL succeeded, NSError *error))completionBlock
{
    // check if nickname contains valid chars
    NSError *error = nil;
    NSString *pattern = @"\\w{5,}";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:0
                                                                                  error:&error];
    NSTextCheckingResult *result = [expression firstMatchInString:nickname
                                                          options:0
                                                            range:NSMakeRange(0, nickname.length)];
    if (!result) {
        NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey : NSLocalizedString(@"signup-error.descr.invalid nickname", nil),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"signup-error.reason.nickname should contain only alpha numeric symbols", nil),
                NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"signup-error.nickname should contain only alphanumeric symbols, please check yours", nil)
        };
        NSError *error = [NSError errorWithDomain:@"Parse"
                                             code:kPFErrorUsernameMissing
                                         userInfo:userInfo];
        completionBlock(NO, error);
        return;
    }

    // check if nickname is an empty string
    if ([nickname isEqualToString:@""] || !nickname) {
        NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey : NSLocalizedString(@"signup-error.descr.enter a nickname", nil),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"signup-error.reason.nickname can't be blank", nil),
                NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"signup-error.suggest", nil)
        };
        NSError *error = [NSError errorWithDomain:@"Parse"
                                             code:kPFErrorUsernameMissing
                                         userInfo:userInfo];
        completionBlock(NO, error);
        return;
    }

    // check if nickname is available
    if (![PSAuthService checkNicknameAvailability:nickname]) {
        NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey : NSLocalizedString(@"signup-error.descr.username taken", nil),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"signup-error.reason.username already taken", nil),
                NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"signup-error.suggest.please try a different one.", nil)
        };
        NSError *error = [NSError errorWithDomain:@"Parse"
                                             code:kPFErrorUsernameTaken
                                         userInfo:userInfo];
        completionBlock(NO, error);
        return;
    }

    // create new parse user

    PFUser *newUser = [PFUser user];
    newUser.username = nickname;
    newUser.password = VK_PASS;

    newUser[@"vkId"] = vkId;

    PFFile *avatar100File = [PFFile fileWithName:@"photo100.jpg" data:avatar100];
    PFFile *avatar200File = [PFFile fileWithName:@"photo200.jpg" data:avatar200];

    newUser[@"photo100"] = avatar100File;
    newUser[@"photo200"] = avatar200File;

    [newUser signUpInBackgroundWithBlock:completionBlock];
}

+ (BOOL)checkIfUserExists:(NSNumber *)vkId
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"vkId" equalTo:vkId];
    NSArray *users = [query findObjects];

    if ([users count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (void)loginVK:(id <VKSdkDelegate>)delegate block:(void (^)(PFUser *user, NSError *error))completionBlock
{
    if ([PFUser currentUser]) { completionBlock([PFUser currentUser], nil); return; }

    [VKSdk initializeWithDelegate:delegate andAppId:PS_VK_TOKEN_KEY];
    if (![VKSdk wakeUpSession]) {
        [VKSdk authorize:@[] revokeAccess:YES];
        if (![VKSdk isLoggedIn]) {
            return;
        }
    }

    PFQuery *query = [PFUser query];
    NSNumber *vkId = [NSNumber numberWithInteger:[[[VKSdk getAccessToken] userId] integerValue]];

    NSLog(@"vkId = %@", vkId);

    [query whereKey:@"vkId" equalTo:vkId];
    NSArray *users = [query findObjects];

    NSString *username = [(PFUser *) users.firstObject username];

    if (!username) {
//        NSDictionary *userInfo = @{
//                NSLocalizedDescriptionKey : NSLocalizedString(@"No such user", nil),
//                NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"No such user exists", nil),
//                NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please sign up", nil),
//                @"error" : @"Needs sign up"
//        };
//        NSError *error = [NSError errorWithDomain:@"Parse"
//                                             code:kPFErrorUserPasswordMissing
//                                         userInfo:userInfo];
        completionBlock(nil, nil);
        return;
    }

    [PFUser logInWithUsernameInBackground:username password:VK_PASS block:completionBlock];
}

+ (BOOL)checkNicknameAvailability:(NSString *)nickname
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:nickname];
    NSArray *users = [query findObjects];

    if ([users count] == 0)
        return YES;
    return NO;
}


@end