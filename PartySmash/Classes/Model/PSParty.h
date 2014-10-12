//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSUser;

@interface PSParty : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *address;
@property (retain) NSString *description;
@property (retain) NSString *name;
@property (retain) PSUser *creator;
@property (retain) NSDate *date;
@property int capacity;
@property int price;
@property BOOL isPrivate;

@end