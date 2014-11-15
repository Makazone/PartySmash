//
// Created by Makar Stetsenko on 08.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "PSCellDelegate.h"

@class PSUser;
@class PSParty;

@interface PSTableUsersVC : PFQueryTableViewController <PSCellDelegate, UIScrollViewDelegate>

@property (nonatomic) PFQuery *userQueryToDisplay;
@property (nonatomic) BOOL needsFollow;
@property (nonatomic) BOOL sendsInvites;

@property (nonatomic) int placesLeft;

@property (nonatomic) PSParty *party;
@property (nonatomic) NSString *screenTitle;

@end