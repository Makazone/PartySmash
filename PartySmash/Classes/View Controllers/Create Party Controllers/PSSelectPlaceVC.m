//
// Created by Makar Stetsenko on 06.08.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "PSSelectPlaceVC.h"
#import "PSCreatePartyVC.h"
#import "GCGeocodingService.h"
#import "PSParty.h"
#import "UIView+PSViewInProgress.h"

static NSTimeInterval const animatedTransitionDuration = 0.5f;

@interface PSSelectPlaceVC () {

}

@property (nonatomic) UIView *annotationView;

@property (weak, nonatomic) IBOutlet UITextField *streetField;

@property (weak, nonatomic) IBOutlet GMSMapView *gmsMapView;
@property (nonatomic) UIButton *dissmissMapButtion;

@end

@implementation PSSelectPlaceVC {
    BOOL _reverseTransition;
    CGRect _endMapBounds;
    UIView *_activeResponder;

    GCGeocodingService *_geocodingService;

    UIView *_infoWindow;

    NSOperationQueue *_geocodeQueue;

    BOOL _firstSearch;
}

//- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
//    id a = [super awakeAfterUsingCoder:aDecoder];
//    a.transitioningDelegate = self;
//    return a;
//}


- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"%s", sel_getName(_cmd));
        self.transitioningDelegate = self;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gmsMapView.delegate = self;

    _geocodingService = [[GCGeocodingService alloc] init];

    CLLocationCoordinate2D currentAddress = CLLocationCoordinate2DMake(self.party.geoPosition.latitude, self.party.geoPosition.longitude);
    NSString *address = self.party.address;
    [self updateGeoInfo:address location:currentAddress firstTime:YES];

    self.dissmissMapButtion = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dissmissMapButtion.frame = CGRectMake(self.gmsMapView.frame.size.width-70, self.gmsMapView.frame.size.height-50, 70, 50);
    self.dissmissMapButtion.backgroundColor = [UIColor redColor];
    [self.dissmissMapButtion setTitle:@"Close" forState:UIControlStateNormal];
    [self.dissmissMapButtion addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.gmsMapView addSubview:self.dissmissMapButtion];

    _geocodeQueue = [NSOperationQueue new];
    _geocodeQueue.name = @"Geocode queue";
}

#pragma mark - Google Map delegate methods

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_activeResponder) {
        [_activeResponder resignFirstResponder];
        _activeResponder = nil;
    }
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.gmsMapView showIndicatorWithCornerRadius:0];
    NSArray *subs = self.gmsMapView.subviews;

    [self.gmsMapView bringSubviewToFront:subs[2]];
    [_geocodeQueue addOperationWithBlock:^{
        [_geocodingService geocodeCoordinate:coordinate completion:^(NSError *error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.gmsMapView removeIndicator];
                if (error) {
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                            initWithTitle:@"Couldn't find your location." message:@"Try text search and check connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [errorAlert show];
                } else {
                    [self updateGeoInfo];
                }
            }];
        }];
    }];
}

- (void)updateGeoInfo:(NSString *)address location:(CLLocationCoordinate2D)loc firstTime:(BOOL)firstTime {
    [self.gmsMapView clear];

    if (!firstTime || self.party.address) {
        self.streetField.text = address;
        GMSMarker *marker = [GMSMarker markerWithPosition:loc];
        marker.map = self.gmsMapView;
        [self.gmsMapView setSelectedMarker:marker];
    }

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.latitude
                                                            longitude:loc.longitude
                                                                 zoom:16];
    [self.gmsMapView setCamera:camera];
}

/**
* Updates geo info based on geocoding service
*/
- (void)updateGeoInfo {
    NSString *city = [_geocodingService city];
    NSString *street = [_geocodingService street];
//    NSString *houseNumber = [_geocodingService house];

    CLLocationCoordinate2D newLocation = CLLocationCoordinate2DMake([_geocodingService.latitude doubleValue], [_geocodingService.longitude doubleValue]);
    NSString *addressRepresentation;
    if (_geocodingService.formatted_address) {
        addressRepresentation = _geocodingService.formatted_address;
    } else addressRepresentation = [NSString stringWithFormat:@"%@, %@", city, street];

    [self updateGeoInfo:addressRepresentation location:newLocation firstTime:NO];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"%s", sel_getName(_cmd));
    NSLog(@"try");
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    self.party.geoPosition.latitude = marker.position.latitude;
    self.party.geoPosition.longitude = marker.position.longitude;

    self.party.address = self.streetField.text;

//    _infoWindow.backgroundColor = [UIColor blueColor];
//    marker.infoWindowAnchor

    [self closeButtonPressed:mapView];

    NSLog(@"%s", sel_getName(_cmd));
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"selectPlaceInfoWindow" owner:nil options:nil];
    UIView *plainView = [nibContents lastObject];

    _infoWindow = plainView;

    return plainView;
}

- (void)infoWindowTaped:(id)sender {
    NSLog(@"%s", sel_getName(_cmd));
}


#pragma mark - Search address methods

- (IBAction)searchButtonPressed:(id)sender {
    if (_activeResponder) {
        [_activeResponder resignFirstResponder];
        _activeResponder = nil;
    }

    // TODO check exception without if
    if (![self checkSearchFields]) {
        return;
    }

    NSString *searchAddress = [NSString stringWithFormat:@"%@", self.streetField.text];

    NSLog(@"You search for %@", searchAddress);

    [self.gmsMapView showIndicatorWithCornerRadius:0];
    NSArray *subs = self.gmsMapView.subviews;

    [self.gmsMapView bringSubviewToFront:subs[2]];

//    UIButton *cancelTask= [UIButton buttonWithType:UIButtonTypeSystem];
//    cancelTask.frame = CGRectMake(self.gmsMapView.frame.size.width-70, self.gmsMapView.frame.size.height-50, 70, 50);
//    cancelTask.backgroundColor = [UIColor redColor];
//    [cancelTask setTitle:@"Close" forState:UIControlStateNormal];
//    [cancelTask addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [self.gmsMapView addSubview:cancelTask];

    NSOperationQueue *geocodeQueue = [NSOperationQueue new];
    [geocodeQueue addOperationWithBlock:^{
        [_geocodingService geocodeAddress:searchAddress completion:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.gmsMapView removeIndicator];
                if (error.code == 1) {
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                            initWithTitle:@"Check your connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [errorAlert show];
                } else if (error) {
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                            initWithTitle:@"No such place!" message:@"Try changing query." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [errorAlert show];
                }
                else {
                    [self updateGeoInfo];
                }
            }];
        }];
    }];
}

#pragma mark - Text Field delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"_activeResponder.tag = %i", _activeResponder.tag);
    if (_activeResponder) {
        [_activeResponder resignFirstResponder];
        [self searchButtonPressed:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _activeResponder = textField;
    return YES;
}


#pragma mark - Transitioning Delegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    _reverseTransition = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    _reverseTransition = YES;
    return self;
}

#pragma mark - Animated Transitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return animatedTransitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];

    CGRect endMapRect;

    if (_reverseTransition) {
        CGPoint p = [self.gmsMapView.projection pointForCoordinate:self.gmsMapView.camera.target];
        p.y -= 155;
        CLLocationCoordinate2D l = [self.gmsMapView.projection coordinateForPoint:p];

        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:l.latitude
                                                                longitude:l.longitude
                                                                     zoom:16];
        [self.gmsMapView setCamera:camera];

        [container insertSubview:toViewController.view belowSubview:fromViewController.view];
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    } else {
        MKMapView *map = [(PSCreatePartyVC *)[(UINavigationController *)fromViewController topViewController] map];
        CGRect converted = [map.superview convertRect:map.frame toView:nil];
        _endMapBounds = converted;

//        CGRect r = toViewController.view.frame;
//        NSLog(@"%@", NSStringFromCGRect(map.bounds));
//        NSLog(@"%@", NSStringFromCGRect(converted));
//        self.mapView.bounds = converted;
//        NSLog(@"(%f, %f) w=%f, h=%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
        NSLog(@"map init bounds %@", NSStringFromCGRect(map.bounds));
        NSLog(@"map init frame %@", NSStringFromCGRect(map.frame));
        NSLog(@"map init frame %@", NSStringFromCGRect(converted));

        [container addSubview:toViewController.view];
        toViewController.view.bounds = converted;
        NSLog(@"%@", NSStringFromCGRect(toViewController.view.frame));
        CGRect r = CGRectMake(0, 295, converted.size.width, converted.size.height);
//        toViewController.view.frame = r;
        toViewController.view.frame = converted;
        NSLog(@"map.center = %@", NSStringFromCGPoint(toViewController.view.center));
        NSLog(@"map.bound = %@", NSStringFromCGRect(toViewController.view.bounds));
        NSLog(@"map.frame = %@", NSStringFromCGRect(toViewController.view.frame));
        NSLog(@"fromViewController = %@", NSStringFromCGRect(fromViewController.view.frame));
    }

    [UIView animateWithDuration:animatedTransitionDuration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0f options:0 animations:^{
        if (_reverseTransition) {
//            fromViewController.view.bounds = CGRectMake(0, 295, 320, 217);
            NSLog(@"NSStringFromCGRect(endMapRect) = %@", NSStringFromCGRect(_endMapBounds));
            fromViewController.view.bounds = _endMapBounds;
            fromViewController.view.center = CGPointMake(CGRectGetMidX(_endMapBounds), CGRectGetMidY(_endMapBounds));
        } else {
            toViewController.view.bounds = CGRectMake(0, 0, 320, 568);
            toViewController.view.center = CGPointMake(160, 284);
//            toViewController.view.bounds = fromViewController.view.frame;
//            toViewController.view.bounds = CGRectMake(0, 295, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
//            self.mapView.bounds = fromViewController.view.frame;
//            toViewController.view.bounds =
        }
    } completion:^(BOOL finished) {
        NSLog(@"map frame after %@", NSStringFromCGRect(toViewController.view.frame));
        NSLog(@"map bound after %@", NSStringFromCGRect(toViewController.view.bounds));
        NSLog(@"new center after animating = %@", NSStringFromCGPoint(toViewController.view.center));
//        toViewController.view.bounds = CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        toViewController.view.bounds = CGRectMake(0, 0, 320, 568);
        toViewController.view.center = CGPointMake(160, 284);
        [transitionContext completeTransition:finished];
        if (!_reverseTransition) {
            [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
        }
    }];
}

- (MKMapView *)findMap:(UIView *)root {
    for (UIView *v in root.subviews) {
        if ([v isKindOfClass:[MKMapView class]]) {
            return root;
        }
        return [self findMap:v];
    }
    return nil;
}

- (GMSMapView *)gmsMapView {
    if (!_gmsMapView) {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.

    }
    return _gmsMapView;
}

- (Boolean)checkSearchFields {
    Boolean valid = YES;

    if (self.streetField.text.length == 0) {
//        self.streetField.borderStyle =
        NSLog(@"Empty field");
        valid = NO;
    }
//    if (self.houseField.text.length == 0) {
//        NSLog(@"Empty field");
//        valid = NO;
//    }

    return valid;
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end