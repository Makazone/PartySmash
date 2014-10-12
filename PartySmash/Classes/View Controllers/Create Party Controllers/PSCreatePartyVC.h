//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKMapView;

@protocol PartyPlaceChooserDelegate

- (void)updatePartyAddressWith:(NSString *)cityStreet
                         house:(NSString *)houseNumber
                          flat:(NSString *)flatNumber
                     longitude:(NSNumber *)longitude
                      latitude:(NSNumber *)latitude;

@end

@interface PSCreatePartyVC : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, PartyPlaceChooserDelegate>

@property (readonly) MKMapView *map;
@property (nonatomic) MKPlacemark *partyLocation;
@property (nonatomic) NSString *partyAddressString;

@end


