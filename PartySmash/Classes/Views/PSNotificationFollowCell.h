//
// Created by Makar Stetsenko on 22.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSAttributedDrawer;
@class PFTableViewCell;

@protocol PSCellDelegate;

static int tapForFollow = 0;
static int tapForUser = 1;

@interface PSNotificationFollowCell : PFTableViewCell

@property (nonatomic) UILabel *body;
@property (nonatomic) PSImageView *userPic;
@property (nonatomic) UIButton *followButton;

@property (weak, nonatomic) id<PSCellDelegate> delegate;
@property (nonatomic) NSIndexPath *indexPath;

@end