//
// Created by Makar Stetsenko on 04.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSNotification.h"
#import "PSParty.h"
#import "PSUser.h"
#import "PSAppDelegate.h"


static NSDateFormatter *dateFormatter;

@implementation PSNotification {

    NSAttributedString *_body;
}

@dynamic type;
@dynamic recipient;
@dynamic sender;
@dynamic party;
@dynamic didRespond;
@dynamic timePassed;

@synthesize invalidateBody;

+ (void)initialize
{
    NSLocale *locale = [NSLocale currentLocale];
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = @"d MMMM";
}

+ (NSString *)parseClassName {
    return @"Invitation";
}

- (void)declineRequestWithCompletion:(void (^)(NSError *))completion {
    [PFCloud callFunctionInBackground:@"declineRequest"
                       withParameters:@{
                                           @"partyId": self.party.objectId,
                                           @"recipientId": self.sender.objectId,
                                           @"invitationId": self.objectId,
                                           @"pushText": [NSString stringWithFormat:@"%@ отклонил(-a) ваш запрос", [[PSUser currentUser] username]]
                                       }
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                                                          action:@"button_pressed"
                                                                                                                           label:@"decline_request"
                                                                                                                           value:nil];
                                        completion(nil);
                                    } else completion(error);
                                }];
}

- (void)acceptRequestWithCompletion:(void (^)(NSError *))completion {
    [PFCloud callFunctionInBackground:@"acceptRequest"
                       withParameters:@{
                                           @"partyId": self.party.objectId,
                                           @"recipientId": self.sender.objectId,
                                           @"invitationId": self.objectId,
                                           @"pushText": [NSString stringWithFormat:@"%@ одобрил(-a) ваш запрос", [[PSUser currentUser] username]]
                                       }
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                                                          action:@"button_pressed"
                                                                                                                           label:@"accept_request"
                                                                                                                           value:nil];
                                        completion(nil);
                                    } else completion(error);
                                }];
}

- (void)declineInvitationWithCompletion:(void (^)(NSError *))completion {
    [PFCloud callFunctionInBackground:@"declineInvitation"
                       withParameters:@{
                                           @"partyId": self.party.objectId,
                                           @"recipientId": self.sender.objectId,
                                           @"invitationId": self.objectId,
                                           @"pushText": [NSString stringWithFormat:@"%@ отклонил(а) ваше приглашение", [[PSUser currentUser] username]]
                                       }
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                                                          action:@"button_pressed"
                                                                                                                           label:@"decline_invitation"
                                                                                                                           value:nil];
                                        completion(nil);
                                    } else completion(error);
                                }];

}

- (void)acceptInvitationWithCompletion:(void (^)(NSError *))completion {
    [PFCloud callFunctionInBackground:@"acceptInvitation"
                       withParameters:@{
                                           @"partyId": self.party.objectId,
                                           @"recipientId": self.sender.objectId,
                                           @"invitationId": self.objectId,
                                           @"pushText": [NSString stringWithFormat:@"%@ принял(а) ваше приглашение", [[PSUser currentUser] username]]
                                       }
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                                                          action:@"button_pressed"
                                                                                                                           label:@"accept_invitation"
                                                                                                                           value:nil];
                                        completion(nil);
                                    } else completion(error);
                                }];
}

- (void)declineWithCompletion:(void (^)(NSError *))completion {
    if (self.type == SEND_INVITATION_TYPE) {
        [self declineInvitationWithCompletion:completion];
    } else [self declineRequestWithCompletion:completion];
}

- (void)acceptWithCompletion:(void (^)(NSError *))completion {
    if (self.type == SEND_INVITATION_TYPE) {
        [self acceptInvitationWithCompletion:completion];
    } else [self acceptRequestWithCompletion:completion];
}


+ (void)loadInvitationsInBackgroundWithCompletion:(void (^)(NSArray *, NSError *))completion {
    PFQuery *generalQuery = [PFQuery queryWithClassName:[PSNotification parseClassName]];
    [generalQuery whereKey:@"recipient" equalTo:[PSUser currentUser]];

    // Invitaion to display that user is waiting for an approval
    PFQuery *userRequestedQuery = [PFQuery queryWithClassName:[PSNotification parseClassName]];
    [userRequestedQuery whereKey:@"sender" equalTo:[PSUser currentUser]];
    [userRequestedQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:SEND_REQUEST_TYPE]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[generalQuery, userRequestedQuery]];
    [query includeKey:@"sender"];
    [query includeKey:@"party"];
    [query includeKey:@"party.creator"];
    [query includeKey:@"recipient"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"SUCCESS");
            completion(objects, nil);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completion(nil, error);
        }
    }];
}

+ (void)sendInviteTo:(PSUser *)recipient forParty:(PSParty *)party {
    [PFCloud callFunctionInBackground:@"sendInvite"
                       withParameters:@{
                               @"recipientId": recipient.objectId,
                               @"partyId": party.objectId,
                               @"pushText": [NSString stringWithFormat:@"%@ приглашает вас на свою вечеринку", [[PSUser currentUser] username]]
                       }
                                block:^(id result, NSError *error) {
                                        if (!error) {
                                            [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                                                              action:@"button_pressed"
                                                                                                                               label:@"send_invitation"
                                                                                                                               value:nil];
                                        }

                                }];
}

+ (void)sendRecommendationTo:(PSUser *)recipient forParty:(PSParty *)party {
    [PFCloud callFunctionInBackground:@"sendRecommendation"
                       withParameters:@{
                               @"recipientId": recipient.objectId,
                               @"partyId": party.objectId,
                               @"pushText": [NSString stringWithFormat:@"%@ рекомендует вам вечеринку", [[PSUser currentUser] username]]
                       }
                                block:^(id result, NSError *error) {
                                        if (!error) {
                                            [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                                                              action:@"button_pressed"
                                                                                                                               label:@"send_recommendation"
                                                                                                                               value:nil];
                                        }

                                }];
}


- (NSAttributedString *)getBody {
    if (_body && !invalidateBody) { return _body; }

    NSString *pure;
    NSMutableAttributedString *body;

    if (self.type == SEND_INVITATION_TYPE) {
        pure = [NSString stringWithFormat:@"%@ приглашает вас на вечеринку \"%@\"", self.sender.username, self.party.name];
    } else if (self.type == ACCEPT_INVITATION_TYPE) {
        pure = [NSString stringWithFormat:@"%@ принял(a) приглашение на вечеринку \"%@\"", self.sender.username, self.party.name];
    } else if (self.type == DECLINE_INVITATION_TYPE) {
        pure = [NSString stringWithFormat:@"%@ отклонил(a) приглашение на вечеринку \"%@\"", self.sender.username, self.party.name];
    } else if (self.type == SEND_REQUEST_TYPE) {
        if ([self.recipient.objectId isEqualToString:[[PSUser currentUser] objectId]]) {
            pure = [NSString stringWithFormat:@"%@ просит приглашение на вечеринку \"%@\"", self.sender.username, self.party.name];
        } else {
            pure = [NSString stringWithFormat:@"Вы попросили приглашение на вечеринку \"%@\"", self.party.name];

            body = [[NSMutableAttributedString alloc] initWithString:pure attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
//            [body addAttributes:@{
//                    NSForegroundColorAttributeName : [UIColor orangeColor],
//                    NSFontAttributeName : [UIFont systemFontOfSize:14]
//            }             range:[pure rangeOfString:@"приглашение запрошено"]];

//            return _body = body;
        }
    } else if (self.type == ACCEPT_REQUEST_TYPE) {
        pure = [NSString stringWithFormat:@"Вы приглашены на вечеринку \"%@\"", self.party.name];
    } else if (self.type == DECLINE_REQUEST_TYPE) {
        pure = [NSString stringWithFormat:@"%@ отклонил(a) ваш запрос на вечеринку \"%@\"", self.sender.username, self.party.name];
    } else if (self.type == SEND_RECOMMENDATION_TYPE) {
        pure = [NSString stringWithFormat:@"%@ предлагает сходить на вечеринку \"%@\"", self.sender.username, self.party.name];
    } else if (self.type == STARTED_FOLLOWING) {
        pure = [NSString stringWithFormat:@"%@ подписан(а) на вас.", self.sender.username];
    }

    NSString *timePassed = self.getTimePassed;

    NSString *pure2, *waitsResponse = @"(ожидает вашего ответа)";
    if ((self.type == SEND_INVITATION_TYPE || self.type == SEND_REQUEST_TYPE) && !self.didRespond && ![self.sender.objectId isEqualToString:[PSUser currentUser].objectId]) {
        pure2 = [NSString stringWithFormat:@"%@ %@\n%@", pure, timePassed, waitsResponse];
    } else pure2 = [NSString stringWithFormat:@"%@ %@", pure, timePassed];

    body = [[NSMutableAttributedString alloc] initWithString:pure2 attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    NSRange r = [pure rangeOfString:self.sender.username];
    if (r.length > 0) {
        [body addAttributes:@{
                NSForegroundColorAttributeName : [UIColor colorWithRed:129 / 255.0 green:28 / 255.0 blue:64 / 255.0 alpha:1.0]
        }             range:r];
    }

    r = [pure2 rangeOfString:waitsResponse];
    if (r.length > 0) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineHeightMultiple:1.5];
        [body addAttribute:NSParagraphStyleAttributeName
                     value:style
                     range:r];

        [body addAttributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:14],
                NSForegroundColorAttributeName : [UIColor colorWithRed:129 / 255.0 green:28 / 255.0 blue:64 / 255.0 alpha:1.0]
        }             range:r];
    }

    [body addAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : [UIColor lightGrayColor]
    }             range:[pure2 rangeOfString:timePassed]];

    invalidateBody = NO;
    return _body = body;
}

- (void)removePartyFromDefaults {
    if (self.type == ACCEPT_REQUEST_TYPE || self.type == DECLINE_REQUEST_TYPE) {
        [[PSUser currentUser] removePartyFromWaitDefaults:self.party.objectId];
    }
}

- (NSString *)getTimePassed {
    NSTimeInterval timePassed = abs([self.createdAt timeIntervalSinceNow]);

    if (timePassed > 60 * 60 * 24) {
        return [dateFormatter stringFromDate:self.createdAt];
    } else if (timePassed > 60 * 60) {
        int hours = (int) timePassed / 3600;
        return [NSString stringWithFormat:@"%dч", hours];
    } else {
        int minutes = (int) timePassed / 60;
        return [NSString stringWithFormat:@"%dм", minutes];
    }
}


@end