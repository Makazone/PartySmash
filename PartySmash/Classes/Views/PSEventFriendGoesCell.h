//
//  PSEventFriendGoesCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 31.10.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/PFTableViewCell.h>

//@interface PSEventFriendGoesCell : UITableViewCell
@interface PSEventFriendGoesCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet PFImageView *userImg;

@end
