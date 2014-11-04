//
// Created by Makar Stetsenko on 01.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSEvent.h"
#import "PSParty.h"
#import "PSUser.h"


@implementation PSEvent {

}

static NSDateFormatter *dateFormatter;

@dynamic owner;
@dynamic party;
@dynamic type;

+ (void)initialize
{
    NSLocale *locale = [NSLocale currentLocale];
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = @"d MMMM";
}

+ (NSString *)parseClassName {
    return @"Event";
}

- (NSAttributedString *)getEventTextBody {
    NSString *pureBody;
    NSMutableAttributedString *body;

    if (self.type == 0) {
        pureBody = [NSString stringWithFormat:@"%@ создал(-а) вечеринкку %@", self.owner.username, self.party.name];
        body = [[NSMutableAttributedString alloc] initWithString:pureBody attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:16]
        }];

        NSRange r = [pureBody rangeOfString:self.owner.username];
        [body addAttributes:@{
                NSForegroundColorAttributeName : [UIColor colorWithRed:129/255.0 green:28/255.0 blue:64/255.0 alpha:1.0]
        } range:r];
    } else {
        pureBody = [NSString stringWithFormat:@"%@ идет на вечеринкку %@", self.owner.username, self.party.name];
        body = [[NSMutableAttributedString alloc] initWithString:pureBody attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:16]
        }];

        NSRange r = [pureBody rangeOfString:self.owner.username];
        [body addAttributes:@{
                NSForegroundColorAttributeName : [UIColor colorWithRed:129/255.0 green:28/255.0 blue:64/255.0 alpha:1.0]
        } range:r];
    }


    return body;
}

- (NSString *)getTimePassed {
    NSTimeInterval timePassed = abs([self.createdAt timeIntervalSinceNow]);

    NSLog(@"timePassed = %f", timePassed);

    if (timePassed > 60*60*24) {
        return [dateFormatter stringFromDate:self.createdAt];
    } else if (timePassed > 60*60) {
        int hours = (int)timePassed / 3600;
        NSString *russianHour;
        if (hours == 1) {
            russianHour = @"час";
        } else if (hours <= 4) russianHour = @"часа";
        else {
            russianHour = @"часов";
        }
        return [NSString stringWithFormat:@"%d %@ назад", hours, russianHour];
    } else {
        int minutes = (int)timePassed/60;
        NSString *russianMinute;
        if (minutes == 1) {
            russianMinute = @"минуту";
        } else if (minutes <= 4) {
            russianMinute = @"минуты";
        } else {
            russianMinute = @"минут";
        }
        return [NSString stringWithFormat:@"%d %@ назад", minutes, russianMinute];
    }
}


@end