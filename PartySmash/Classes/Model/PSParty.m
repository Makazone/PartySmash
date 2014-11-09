//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSParty.h"
#import "Parse/PFObject+Subclass.h";
#import "PSUser.h"
#import "PSInvitation.h"

@interface PSParty () {

}

@end


@implementation PSParty {
}

@dynamic address;

@dynamic generalDescription;
@dynamic price;
@dynamic contactDescription;

@dynamic name;
@dynamic creator;
@dynamic capacity;
@dynamic isPrivate;
@dynamic date;

@dynamic geoPosition;

@synthesize isFree;

+ (NSString *)parseClassName {
    return @"Party";
}


- (void)getInfoAboutPeopleWhoGoWithCallback:(void (^)(NSDictionary *result, NSError *error))callback {
    [PFCloud callFunctionInBackground:@"getInvitedInfoForParty"
                       withParameters:@{@"partyId": self.objectId}
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        callback(result, nil);
                                    } else callback(nil, error);
                                }];

}

- (void)enrollWithCallback:(void (^)(NSError *))callback {
    if (self.isPrivate) {
        [[PSUser currentUser] addPartyToWaitDefaults:self.objectId];

        [PFCloud callFunctionInBackground:@"sendRequest"
                           withParameters:@{
                                               @"partyId": self.objectId,
                                               @"recipientId": self.creator.objectId,
                                           }
                                    block:^(id result, NSError *error) {
                                        if (!error) {
                                            callback(nil);
                                        } else callback(error);
                                    }];
    } else {
        [PFCloud callFunctionInBackground:@"helper_AddToInvitedList"
                           withParameters:@{
                                               @"userId": [[PSUser currentUser] objectId],
                                               @"partyId": self.objectId,
                                           }
                                    block:^(id result, NSError *error) {
                                        if (!error) {
                                            callback(nil);
                                        } else callback(error);
                                    }];
    }
}

- (void)removeUserFromInvited:(void (^)(NSError *))callback {
    PFRelation *invited = [self relationForKey:@"invited"];
    [invited removeObject:[PSUser currentUser]];
    [self saveInBackgroundWithBlock:^(BOOL s, NSError *error) {
        callback(error);
    }];
}

- (void)recommendToFriends:(NSArray *)friends {
    for (int i = 0; i < friends.count; i++) {
        [PSInvitation sendRecommendationTo:friends[i] forParty:self];
    }
}

- (void)inviteFriends:(NSArray *)friends {
    for (int i = 0; i < friends.count; i++) {
        [PSInvitation sendInviteTo:friends[i] forParty:self];
    }
}

@end