//
//  PSEventNewPartyCell.h
//  PartySmash
//
//  Created by Makar Stetsenko on 29.10.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>

@interface PSEventNewPartyCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *creatorImage;
@property (weak, nonatomic) IBOutlet UITextView *body;

@property (weak, nonatomic) IBOutlet UILabel *timePassed;

@end
