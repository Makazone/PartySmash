//
//  PSPartyCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 06.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface PSPartyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *headerText;
@property (weak, nonatomic) IBOutlet PFImageView *creatorImg;
@property (weak, nonatomic) IBOutlet UILabel *partyDate;
@property (weak, nonatomic) IBOutlet UITextView *address;
@property (weak, nonatomic) IBOutlet UITextView *price;
@property (weak, nonatomic) IBOutlet UITextView *placesLeft;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *creatorNic;

@end
