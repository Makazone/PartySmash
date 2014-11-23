//
// Created by Makar Stetsenko on 13.10.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSUserFeedVC.h"

@class PSParty;

@interface PSPriceDescriptionVC : UIViewController <UITextViewDelegate>

@property (nonatomic) PSParty *party;
@property (weak, nonatomic) id<CreatePartyDelegate> delegate;

@end