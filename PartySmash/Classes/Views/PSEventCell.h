//
//  PSEventCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 31.10.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/PFTableViewCell.h>

@class PSAttributedDrawer;
@class PSImageView;

//@interface PSEventCell : UITableViewCell
@interface PSEventCell : PFTableViewCell

@property (nonatomic) UILabel *body;
@property (nonatomic) PSImageView *userPic;

@end
