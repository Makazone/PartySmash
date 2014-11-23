//
// Created by Makar Stetsenko on 10.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "PSFindPartyMapVC.h"
#import "PSParty.h"
#import "PSUser.h"
#import "PSPartyViewController.h"
#import "PSAppDelegate.h"

static NSString *GA_SCREEN_NAME = @"Find party map";
static NSDateFormatter *_dateFormatter;

@interface PSFindPartyMapVC () {

}

@property (weak, nonatomic) IBOutlet GMSMapView *gmsMapView;

@end

@implementation PSFindPartyMapVC {
    CLLocationManager *_locationManager;
    NSMutableSet *_markersDisplayed;
}

+ (void)initialize {
    NSLocale *locale = [NSLocale currentLocale];
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.locale = locale;
    _dateFormatter.dateFormat = @"d MMMM HH:mm";
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tabBarController.tabBar setHidden:YES];
    _markersDisplayed = [NSMutableSet new];

    [self setUpMap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [(PSAppDelegate *)[UIApplication sharedApplication].delegate trackScreen:GA_SCREEN_NAME];
}


- (void)setUpMap {
    self.gmsMapView.delegate = self;
    self.gmsMapView.settings.myLocationButton = YES;
    self.gmsMapView.settings.rotateGestures = NO;

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [[[UIAlertView alloc] initWithTitle:@"Геолокация запрещена =(" message:@"Перейдите в приложение Настройки, найдите там PartySmash и разрешите нам (и КГБ) следить за Вами. (приложение потом надо перезапустить)" delegate:nil cancelButtonTitle:@"Ух, КГБ, Я мигом." otherButtonTitles:nil] show];
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.gmsMapView.myLocationEnabled = YES;

            NSLog(@"geoPoint = %@", geoPoint);
            CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);

            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.latitude
                                                                    longitude:loc.longitude
                                                                         zoom:12];
            [self.gmsMapView setCamera:camera];

        } else {
            [[UIAlertView alloc] initWithTitle:@"Вас не найти =(" message:@"Скорее всего мы потеряли с Вами связь" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
    }];
}

- (void)loadPartiesNear:(PFGeoPoint *)location withCallback:(void (^)(NSArray *parties, NSError *error))callback {
    PFQuery *query = [PFQuery queryWithClassName:[PSParty parseClassName]];
    [query whereKey:@"geoPosition" nearGeoPoint:location withinKilometers:100];
    [query whereKey:@"date" greaterThanOrEqualTo:[[NSDate alloc] initWithTimeIntervalSinceNow:-86400]];
    [query includeKey:@"creator"];
// Limit what could be a lot of points.
//    query.limit = 10;
// Final list of objects
    [query findObjectsInBackgroundWithBlock:callback];
}

- (UIImage *)getMarkerImageWithData:(NSData *)data {
    UIImage *userPic = [UIImage imageWithData:data];

    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48, 48), NO, [UIScreen mainScreen].scale);

    // Add a clip before drawing anything, in the shape of an rounded rect
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 4, 40, 40)];

    [[UIColor colorWithRed:97/255.0 green:36/255.0 blue:99/255.0 alpha:1.0] setStroke];
    [p setLineWidth:3];
    [p stroke];

    [p addClip];


    // Draw your image
    [userPic drawInRect:CGRectMake(4, 4, 40, 40)];

    // Get the image, here setting the UIImageView image
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();

    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();

    return result;
}

- (void)displayParties:(NSArray *)parties {
    for (int i = 0; i < parties.count; i++) {
        PSParty *party = parties[i];

        NSLog(@"_markersDisplayed.count = %u", _markersDisplayed.count);

        if ([_markersDisplayed containsObject:party.objectId]) { continue; }
        else {
            [_markersDisplayed addObject:party.objectId];
        }

        NSLog(@"%s", sel_getName(_cmd));

        PFFile *f = party.creator.photo100;
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(party.geoPosition.latitude, party.geoPosition.longitude);
        [f getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                            GMSMarker *marker = [GMSMarker markerWithPosition:loc];
//                            // Add a custom 'arrow' marker pointing to Melbourne.
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = loc;
            marker.icon = [self getMarkerImageWithData:data];
            marker.userData = party;
            marker.map = self.gmsMapView;

            marker.title = party.name;
            marker.snippet = [_dateFormatter stringFromDate:party.date];
        }];
    }
}

- (void)loadParties {
    CLLocationCoordinate2D swCoordinate = self.gmsMapView.projection.visibleRegion.nearLeft;
    CLLocationCoordinate2D neCoordinate = self.gmsMapView.projection.visibleRegion.farRight;
    PFGeoPoint *sw = [PFGeoPoint geoPointWithLatitude:swCoordinate.latitude longitude:swCoordinate.longitude];
    PFGeoPoint *ne = [PFGeoPoint geoPointWithLatitude:neCoordinate.latitude longitude:neCoordinate.longitude];

    [PFCloud callFunctionInBackground:@"loadPartiesForMap"
                       withParameters:@{
                                           @"zoom": @(self.gmsMapView.camera.zoom),
                                           @"ne": ne,
                                           @"sw": sw,
                                       }
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [self displayParties:result];
                                    } else {

                                    }
                                }];
}

#pragma mark - GMSMapViewDelegate methods

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyViewController *partyVC = [sb instantiateViewControllerWithIdentifier:@"party_vc"];
    partyVC.party = marker.userData;

    [self.navigationController pushViewController:partyVC animated:YES];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
//    position.target.
    PFQuery *query = [PFQuery queryWithClassName:[PSParty parseClassName]];

    CLLocationCoordinate2D swCoordinate = mapView.projection.visibleRegion.nearLeft;
    CLLocationCoordinate2D neCoordinate = mapView.projection.visibleRegion.farRight;
    PFGeoPoint *sw = [PFGeoPoint geoPointWithLatitude:swCoordinate.latitude longitude:swCoordinate.longitude];
    PFGeoPoint *ne = [PFGeoPoint geoPointWithLatitude:neCoordinate.latitude longitude:neCoordinate.longitude];

    [query whereKey:@"geoPosition" withinGeoBoxFromSouthwest:sw toNortheast:ne];
    [query whereKey:@"date" greaterThanOrEqualTo:[[NSDate alloc] initWithTimeIntervalSinceNow:-86400]];
    [query includeKey:@"creator"];

// Limit what could be a lot of points.
//    query.limit = 10;
// Final list of objects

    [query findObjectsInBackgroundWithBlock:^(NSArray *data, NSError *error) {
        if (!error) {
            [self displayParties:data];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}


@end