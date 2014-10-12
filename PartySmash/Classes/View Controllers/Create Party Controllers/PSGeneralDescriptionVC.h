//
// Created by Makar Stetsenko on 13.10.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSParty;


@interface PSGeneralDescriptionVC : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) PSParty *party;

@end