//
//  PSPartyListCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 13.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface PSPartyListCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *partyCreatorPic;
@property (weak, nonatomic) IBOutlet UITextView *partyBody;

@end
