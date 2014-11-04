//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSParty.h"
#import "Parse/PFObject+Subclass.h";
#import "PSUser.h"

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

@end