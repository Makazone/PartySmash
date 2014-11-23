//
//  PSUserFeedVC.h
//  PartySmash
//
//  Created by Makar Stetsenko on 16.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//



#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PSQueryTableViewController.h"

@class PSParty;

@protocol CreatePartyDelegate

- (void)didCreateParty:(PSParty *)party;

@end

//@interface PSUserFeedVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@interface PSUserFeedVC : PSQueryTableViewController <UIScrollViewDelegate, CreatePartyDelegate>

@end
