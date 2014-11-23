//
// Created by Makar Stetsenko on 22.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ParseUI/PFTableViewCell.h"

@class PSAttributedDrawer;
@class PFTableViewCell;
@protocol PSCellDelegate;

static int tapForFollow = 0;
static int tapForUser = 0;

@interface PSNotificationFollowCell : PFTableViewCell

@property (nonatomic) PSAttributedDrawer *body;
@property (nonatomic) UIButton *followButton;

@property (weak, nonatomic) id<PSCellDelegate> delegate;
@property (nonatomic) NSIndexPath *indexPath;

@end