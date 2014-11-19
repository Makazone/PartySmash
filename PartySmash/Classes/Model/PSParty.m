//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSParty.h"
#import "Parse/PFObject+Subclass.h";
#import "PSUser.h"
#import "PSInvitation.h"

static NSDateFormatter *_dateFormatter;

@interface PSParty () {

}

@property (nonatomic) NSAttributedString *body;

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
@synthesize body;

+ (void)initialize {
    NSLocale *locale = [NSLocale currentLocale];
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.locale = locale;
    _dateFormatter.dateFormat = @"d MMMM";
}

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
                                               @"pushText": [NSString stringWithFormat:@"%@ хочет пойти на вашу вечеринку", [[PSUser currentUser] username]]
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
//                                               @"pushText": [NSString stringWithFormat:@"%@ просит приглашение", [[PSUser currentUser] username]]
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

- (NSString *)getDateStr {
    NSDate *today = [NSDate new];
    NSString *str;

    if ([self.date timeIntervalSinceDate:today] < 24 * 60 * 60) {
        [_dateFormatter setDateFormat:@"HH:mm"];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:-1];

        int todayDate = [calendar components:(NSDayCalendarUnit) fromDate:today].day;
        int partiesDate = [calendar components:NSDayCalendarUnit fromDate:self.date].day;

        if (todayDate == partiesDate) {
            str = [NSString stringWithFormat:@"Сегодня в %@", [_dateFormatter stringFromDate:self.date]];
        } else if (todayDate - partiesDate == 1) {
            str = [NSString stringWithFormat:@"Вчера в %@", [_dateFormatter stringFromDate:self.date]];
        } else { // TODO don't forget to delete
            str = [NSString stringWithFormat:@"Хуйню запрогал в %@", [_dateFormatter stringFromDate:today]];
        }

        [_dateFormatter setDateFormat:@"d MMMM"];
    } else str = [_dateFormatter stringFromDate:self.date];

    return str;
}

- (NSAttributedString *)getBodyWithKilo:(double)kilo {
    if (self.body) { return self.body; }

    NSString *pure, *dateStr = [self getDateStr];
    if (kilo < 0) {
        pure = [NSString stringWithFormat:@"%@\n%@", self.name, dateStr];
    } else if (kilo < 1) {
        int meters = kilo * 1000;
        pure = [NSString stringWithFormat:@"%@\n%@ в %dм", self.name, dateStr, meters];
    } else {
        int kilometers = kilo;
        pure = [NSString stringWithFormat:@"%@\n%@ в %dкм", self.name, dateStr, kilometers];
        NSLog(@"pure = %@", pure);
    }

    NSMutableAttributedString *body = [[NSMutableAttributedString alloc] initWithString:pure attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:16]
    }];

    NSRange r = [pure rangeOfString:self.name];
    NSLog(@"r = %d,%d", r.location, r.length);
    NSLog(@"self.name.length = %u", self.name.length);
    NSLog(@"pure.length = %u", pure.length);
    NSRange r2 = NSMakeRange(self.name.length, pure.length-self.name.length);
    NSLog(@"r2 = %d,%d", r2.location, r2.length);

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineHeightMultiple:1.5];
    [body addAttribute:NSParagraphStyleAttributeName
                 value:style
                 range:r2];

    [body addAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : [UIColor lightGrayColor],
    } range:r2];

    return self.body = body;
}

@end