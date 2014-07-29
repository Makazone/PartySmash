//
// Created by Makar Stetsenko on 17.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const VKID_FIELD = @"vkId";
static NSString *const FOLLOW_RELATION_KEY = @"following";

@interface PSUser : PFUser<PFSubclassing>

// Method required by Parse
+ (NSString *)parseClassName;

- (void)getFriendsToFollowWithBlock:(void (^)(NSError *, NSArray *))completion;

- (void)followUser:(PFUser *)user;
- (void)followUsers:(NSArray *)users;

@end