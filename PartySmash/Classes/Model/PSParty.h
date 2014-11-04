//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class PSUser;
@class PFGeoPoint;

static NSString *PLACES_LEFT_INDX = @"places_left";
static NSString *FRIENDS_WHO_GO_INDX = @"friends";
static NSString *PEOPLE_WHO_ALSO_GO_INDX = @"also_go";

@interface PSParty : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

- (void)getInfoAboutPeopleWhoGoWithCallback:(void (^)(NSDictionary *result, NSError *error))callback;

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