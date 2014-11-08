//
// Created by Makar Stetsenko on 04.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSParty;
@class PSUser;

static int SEND_INVITATION_TYPE = 0;
static int ACCEPT_INVITATION_TYPE = 1;
static int DECLINE_INVITATION_TYPE = 2;
static int SEND_REQUEST_TYPE = 3;
static int ACCEPT_REQUEST_TYPE = 4;
static int DECLINE_REQUEST_TYPE = 5;
static int SEND_RECOMMENDATION_TYPE = 6;

@interface PSInvitation : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property int type;
@property (retain) PSParty *party;
@property (retain) PSUser *sender;
@property (retain) PSUser *recipient;

- (void)acceptInvitationWithCompletion:(void (^)(NSError *))completion;
- (void)declineInvitationWithCompletion:(void (^)(NSError *))completion;

- (void)acceptRequestWithCompletion:(void (^)(NSError *))completion;
- (void)declineRequestWithCompletion:(void (^)(NSError *))completion;

// Convinience methods
- (void)acceptWithCompletion:(void (^)(NSError *))completion;
- (void)declineWithCompletion:(void (^)(NSError *))completion;

- (NSAttributedString *)getBody;

- (void)removePartyFromDefaults;

+ (void)loadInvitationsInBackgroundWithCompletion:(void (^)(NSArray *, NSError *))completion;

@end