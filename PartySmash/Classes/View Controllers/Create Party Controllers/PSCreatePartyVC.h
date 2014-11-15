//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKMapView;

@interface PSCreatePartyVC : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GMSMapViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (readonly) MKMapView *map;
@property (nonatomic) MKPlacemark *partyLocation;
@property (nonatomic) NSString *partyAddressString;

@end


