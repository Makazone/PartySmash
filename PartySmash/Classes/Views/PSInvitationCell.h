//
//  PSInvitationCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 04.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellDelegate <NSObject>

- (void)didClickOnCellAtIndexPath:(NSIndexPath *)cellIndex withData:(id)data;

@end

@interface PSInvitationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *userPic;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (weak, nonatomic) id<CellDelegate> delegate;
@property (nonatomic) NSIndexPath *cellIndexPath;

@end
