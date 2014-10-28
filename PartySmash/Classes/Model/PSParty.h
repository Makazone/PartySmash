//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class PSUser;
@class PFGeoPoint;

@interface PSParty : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) PSUser *creator;

@property (retain) NSString *address;

@property (retain) NSString *generalDescription;
@property (retain) NSString *price;
@property (retain) NSString *contactDescription;

@property (retain) NSString *name;
@property (retain) NSDate *date;
@property int capacity;

@property BOOL isPrivate;
@property BOOL isFree;

@property PFGeoPoint *geoPosition;

@end