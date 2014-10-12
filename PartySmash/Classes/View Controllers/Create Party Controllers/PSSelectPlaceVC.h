//
// Created by Makar Stetsenko on 06.08.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "PSCreatePartyVC.h"

@class PSCreatePartyVC;

@interface PSSelectPlaceVC : UIViewController <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UITextFieldDelegate, GMSMapViewDelegate>

@property id<PartyPlaceChooserDelegate> delegate;

//@property MKPlacemark *currentLocation;
//@property PSCreatePartyVC *partyCreateVC;

//@property NSNumber *latitude;
//@property NSNumber *longitude;

//@property NSString *city;
//@property NSString *street;
//@property NSString *houseNumber;
//@property NSString *flatNumber;

@end
