//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSUserFeedVC.h"
#import "GoogleMaps/GMSMapView.h"

@class GMSMapView;
//@protocol CreatePartyDelegate;
//@protocol MKMapViewDelegate;

@interface PSCreatePartyVC : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource,  GMSMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (readonly) GMSMapView *map;

@property (weak, nonatomic) id<CreatePartyDelegate> delegate;

@end


