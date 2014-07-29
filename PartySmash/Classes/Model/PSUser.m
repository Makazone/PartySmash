//
// Created by Makar Stetsenko on 17.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <VK-ios-sdk/VKRequest.h>
#import <VK-ios-sdk/VKApi.h>
#import <Parse/Parse.h>
#import "PSUser.h"

@interface PSUser ()

@end

@implementation PSUser {

}

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
    for (PFUser *user in users) {
        [followRelation addObject:user];
    }
    [self saveInBackground];
}

- (void)followUser:(PFUser *)user {
    PFRelation *followRelation = [self relationforKey:FOLLOW_RELATION_KEY];
    [followRelation addObject:user];
    [self saveInBackground];
}

@end