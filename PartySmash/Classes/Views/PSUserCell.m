//
// Created by Makar Stetsenko on 08.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSUserCell.h"
#import "PSCellDelegate.h"


@implementation PSUserCell {

}

- (IBAction)followUser:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnCellAtIndexPath:withData:)]) {
        [_delegate didClickOnCellAtIndexPath:_cellIndexPath withData:nil];
    }
}

@end
