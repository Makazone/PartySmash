//
// Created by Makar Stetsenko on 08.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PSCellDelegate.h"
#import "PSQueryTableViewController.h"

@class PSUser;
@class PSParty;

@interface PSTableUsersVC : PSQueryTableViewController <PSCellDelegate, UIScrollViewDelegate>

@property (nonatomic) PFQuery *userQueryToDisplay;
@property (nonatomic) BOOL needsFollow;
@property (nonatomic) BOOL sendsInvites;
@property (nonatomic) BOOL fromParty;

@property (nonatomic) int placesLeft;

@property (nonatomic) PSParty *party;
@property (nonatomic) NSString *screenTitle;
@property (nonatomic) NSString *gaScreenName;

@end