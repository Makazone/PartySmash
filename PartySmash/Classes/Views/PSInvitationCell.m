//
//  PSInvitationCell.m
//  PartySmash
//
//  Created by Makar Stetsenko on 04.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSInvitationCell.h"

@interface PSInvitationCell () {
    
}
@end

@implementation PSInvitationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)declineButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnCellAtIndexPath:withData:)]) {
        [_delegate didClickOnCellAtIndexPath:_cellIndexPath withData:@[self, @1]];
    }
}

- (IBAction)acceptClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnCellAtIndexPath:withData:)]) {
        [_delegate didClickOnCellAtIndexPath:_cellIndexPath withData:@[self, @2]];
    }
}

- (IBAction)okClicked:(id)sender {
    NSLog(@"%s", sel_getName(_cmd));
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnCellAtIndexPath:withData:)]) {
        [_delegate didClickOnCellAtIndexPath:_cellIndexPath withData:@[self, @3]];
    }
}


@end
