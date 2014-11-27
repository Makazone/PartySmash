//
// Created by Makar Stetsenko on 01.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSParty;
@class PSUser;


@interface PSEvent : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

- (NSAttributedString *)getEventTextBody;
- (NSString *)getTimePassed;

@property int type;

@property (retain) PSParty *party;
@property (retain) PSUser *owner;
@property (retain) NSString *timePassed;

@end