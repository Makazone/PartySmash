//
// Created by Makar Stetsenko on 08.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol PSCellDelegate;

@interface PSUserCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNic;
@property (weak, nonatomic) IBOutlet PFImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *itsYouLabel;
@property (weak, nonatomic) IBOutlet UIButton *userActionButton;

@property (weak, nonatomic) id<PSCellDelegate> delegate;
@property (nonatomic) NSIndexPath *cellIndexPath;

@end