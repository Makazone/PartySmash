//
//  PSNotificationCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 04.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSCellDelegate;
@class PSAttributedDrawer;

@interface PSNotificationCell : PFTableViewCell

@property (nonatomic) PSAttributedDrawer *body;

@property (weak, nonatomic) id<PSCellDelegate> delegate;
@property (nonatomic) NSIndexPath *cellIndexPath;

@end
