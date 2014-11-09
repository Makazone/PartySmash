//
// Created by Makar Stetsenko on 08.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSCellDelegate <NSObject>

- (void)didClickOnCellAtIndexPath:(NSIndexPath *)cellIndex withData:(id)data;

@end
