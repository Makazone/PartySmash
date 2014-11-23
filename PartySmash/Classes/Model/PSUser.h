//
// Created by Makar Stetsenko on 17.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

static NSString *const VKID_FIELD = @"vkId";
static NSString *const FOLLOW_RELATION_KEY = @"following";

@interface PSUser : PFUser<PFSubclassing>

// Method required by Parse
+ (NSString *)parseClassName;

- (void)getFriendsToFollowWithBlock:(void (^)(NSError *, NSArray *))completion;

- (void)getProfileInformation:(void (^)(NSError *, int numberOfFollowers, int numberOfFollowing, int numberOfVisisted, int numberOfCreated, BOOL isFollowed))completion;

- (void)followUser:(PFUser *)user;
- (void)followUsers:(NSArray *)users;

- (void)unfollowUser:(PSUser *)user withCompletion:(void (^)(NSError *))completion;
- (void)followUser:(PSUser *)user withCompletion:(void (^)(NSError *))completion;
- (void)clearFollow;

- (PFRelation *)getFollowingRelation;

- (void)addPartyToWaitDefaults:(NSString *)partyId;
- (void)removePartyFromWaitDefaults:(NSString *)partyId;
- (BOOL)checkIfRequestedInviteForParty:(NSString *)partyId;

- (BOOL)isFollowingUser:(NSString *)userId;
- (void)checkFollowDefaults;


@property (retain) PFFile *photo100;
@property (retain) PFFile *photo200;
@property (retain) NSNumber *vkId;

// Does current user follows this user
@property BOOL isFollowing;

@end