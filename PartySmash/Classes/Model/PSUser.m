//
// Created by Makar Stetsenko on 17.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <VK-ios-sdk/VKRequest.h>
#import <VK-ios-sdk/VKApi.h>
#import <Parse/Parse.h>
#import "PSUser.h"

static NSString *FOLLOW_DEFAULTS_KEY = @"followingUsers";
static NSString *WAITS_PARY_DEFAULTS_KEY = @"waitsParty";

@interface PSUser ()

@end

@implementation PSUser {
    BOOL _isFollowLoaded;
}

@dynamic photo100;
@dynamic photo200;
@dynamic vkId;
@synthesize isFollowing;

- (void)getFriendsToFollowWithBlock:(void (^)(NSError *, NSArray *))completion {
    VKRequest *r = [[VKApi friends] get:@{VK_API_USER_ID : self[VKID_FIELD], VK_API_FIELDS : @"id"}];
    [r executeWithResultBlock:^(VKResponse *response) {
        NSMutableArray *vkIDs = [NSMutableArray new];

        for (VKUser *friend in response.parsedModel) {
            [vkIDs addObject:friend.id];
        }

        NSLog(@"vkIDs = %@", vkIDs);

        PFQuery *q = [PSUser query];
        [q whereKey:VKID_FIELD containedIn:vkIDs];
        NSArray *result = [q findObjects:nil];

        for (PSUser *user in result) {
            PFFile *photo = user[@"photo100"];
            if (!photo.isDataAvailable) [photo getData];
        }

        NSLog(@"result = %@", result);

        completion(nil, result);
    } errorBlock:^(NSError *error){
        completion(error, nil);
        NSLog(@"error = %@", error);
    }];
}

- (void)followUsers:(NSArray *)users {
    PFRelation *followRelation = [self relationforKey:FOLLOW_RELATION_KEY];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *newUsersToFollow = [[NSMutableArray alloc] initWithArray:[defaults stringArrayForKey:FOLLOW_DEFAULTS_KEY]];
    for (PFUser *user in users) {
        [newUsersToFollow addObject:user.objectId];
        [followRelation addObject:user];
    }

    [defaults setObject:newUsersToFollow forKey:FOLLOW_DEFAULTS_KEY];
    [defaults synchronize];

    [self saveInBackground];
}

- (void)followUser:(PFUser *)user {
    [self followUser:user withCompletion:nil];
}

- (PFRelation *)getFollowingRelation {
    return [self relationForKey:FOLLOW_RELATION_KEY];
}

- (void)getProfileInformation:(void (^)(NSError *, int numberOfFollowers, int numberOfFollowing, int numberOfVisisted, int numberOfCreated, BOOL isFollowed))completion {
    [PFCloud callFunctionInBackground:@"countProfileStats"
                       withParameters:@{@"userId": self.objectId}
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        completion(nil, [result[@"followers"] intValue], [result[@"following"] intValue], [result[@"visited"] intValue], [result[@"created"] intValue], [result[@"is_followed"] boolValue]);
                                    } else completion(error, -1, -1, -1, -1, NO);
                                }];
}

- (void)unfollowUser:(PSUser *)user withCompletion:(void (^)(NSError *))completion {
    PFRelation *followRelation = [self relationforKey:FOLLOW_RELATION_KEY];
    [followRelation removeObject:user];
    [self saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
        if (!error) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *newUsersToFollow = [[NSMutableArray alloc] initWithArray:[defaults stringArrayForKey:FOLLOW_DEFAULTS_KEY]];
            for (int i = 0; i < newUsersToFollow.count; i++) {
                if ([(NSString *)newUsersToFollow[i] isEqualToString:user.objectId]) {
                    [newUsersToFollow removeObjectAtIndex:i];
                }
            }
            [defaults setObject:newUsersToFollow forKey:FOLLOW_DEFAULTS_KEY];
            [defaults synchronize];
        }
        completion(error);
    }];
}

- (void)followUser:(PSUser *)user withCompletion:(void (^)(NSError *))completion {
    [PFCloud callFunctionInBackground:@"followUser"
                       withParameters:@{
                                           @"userId": user.objectId,
                                           @"pushText": [NSString stringWithFormat:@"%@ подписался на тебя", [[PSUser currentUser] username]]
                                       }
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [self addFollowedUserToDefaults:user];
                                    }
                                    completion(error);
                                }];
}

- (void)addPartyToWaitDefaults:(NSString *)partyId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *requestedParties = [[NSMutableArray alloc] initWithArray:[defaults stringArrayForKey:WAITS_PARY_DEFAULTS_KEY]];
    [requestedParties addObject:partyId];
    [defaults setObject:requestedParties forKey:WAITS_PARY_DEFAULTS_KEY];
    [defaults synchronize];
}

- (void)removePartyFromWaitDefaults:(NSString *)partyId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *requestedParties = [[NSMutableArray alloc] initWithArray:[defaults stringArrayForKey:WAITS_PARY_DEFAULTS_KEY]];
    for (int i = 0; i < requestedParties.count; i++) {
        if ([(NSString *)requestedParties[i] isEqualToString:partyId]) {
            [requestedParties removeObjectAtIndex:i];
        }
    }
    [defaults setObject:requestedParties forKey:WAITS_PARY_DEFAULTS_KEY];
    [defaults synchronize];
}

- (BOOL)checkIfRequestedInviteForParty:(NSString *)partyId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [defaults stringArrayForKey:WAITS_PARY_DEFAULTS_KEY];
    NSLog(@"arr.count = %u", arr.count);
    for (int i = 0; i < arr.count; i++) {
        NSLog(@"arr[i] = %@", arr[i]);
    }
    return [[defaults stringArrayForKey:WAITS_PARY_DEFAULTS_KEY] containsObject:partyId];
}

- (BOOL)isFollowingUser:(NSString *)userId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults stringArrayForKey:FOLLOW_DEFAULTS_KEY] containsObject:userId];
}

- (void)addFollowedUserToDefaults:(PSUser *)user {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *requestedParties = [[NSMutableArray alloc] initWithArray:[defaults stringArrayForKey:FOLLOW_DEFAULTS_KEY]];
    [requestedParties addObject:user.objectId];
    [defaults setObject:requestedParties forKey:FOLLOW_DEFAULTS_KEY];
    [defaults synchronize];
}

- (void)checkFollowDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [[self getFollowingRelation].query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *err){
        NSMutableArray *followingIds = [NSMutableArray new];
        for (int i = 0; i < result.count; i++) {
            [followingIds addObject:((PFObject *)result[i]).objectId];
        }
        [defaults setObject:followingIds forKey:FOLLOW_DEFAULTS_KEY];
        [defaults synchronize];
    }];
}

- (void)clearFollow {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@[] forKey:FOLLOW_DEFAULTS_KEY];
    [defaults synchronize];
}

- (BOOL)isFollowing {
    if (!_isFollowLoaded) {
        _isFollowLoaded = YES;
        self.isFollowing = [self isFollowingUser:self.objectId];
    }
    return isFollowing;
}

@end