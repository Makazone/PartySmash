//
// Created by Makar Stetsenko on 06.08.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PSSelectPlaceVC.h"
#import "PSCreatePartyVC.h"
#import "GCGeocodingService.h"

static NSTimeInterval const animatedTransitionDuration = 0.6f;

@interface PSSelectPlaceVC () {

}

@property (weak, nonatomic) IBOutlet UIView *editAddressView;
@property (nonatomic) UIView *annotationView;

@property (weak, nonatomic) IBOutlet UITextField *streetField;
@property (weak, nonatomic) IBOutlet UITextField *houseField;
@property (weak, nonatomic) IBOutlet UITextField *flatField;

@property NSNumber *latitude;
@property NSNumber *longitude;

@property (weak, nonatomic) IBOutlet UIView *mapHolder;
@property (nonatomic) GMSMapView *gmsMapView;

@end

@implementation PSSelectPlaceVC {
    BOOL _reverseTransition;
    CGRect _endMapBounds;
    UIView *_activeResponder;

    GCGeocodingService *_geocodingService;
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

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
//    [self.mapView addGestureRecognizer:longPressGesture];
//
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    [self.gmsMapView addGestureRecognizer:tapGesture];

    _geocodingService = [[GCGeocodingService alloc] init];

//    CLLocation *partyLocation = [[CLLocation alloc] initWithLatitude:self.currentLocation.location.coordinate.latitude longitude:self.currentLocation.location.coordinate.longitude];
//    [_geocoder reverseGeocodeLocation:partyLocation completionHandler:^(NSArray *placemarks, NSError *error) {
//        if ((placemarks != nil) && (placemarks.count > 0)) {
//            self.currentLocation = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
//            [self dropLocationPin];
//        }
//        else {
//            NSLog(@"No placemark");
//        }
//    }];

    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.gmsMapView;

    [self.gmsMapView setSelectedMarker:marker];
}

#pragma mark - Google Map delegate methods

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_activeResponder) {
        [_activeResponder resignFirstResponder];
        _activeResponder = nil;
    }
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [_geocodingService geocodeCoordinate:coordinate completion:^(NSError *error){
        [self updatePartyAddressInformation];
    }];
}

- (void)updatePartyAddressInformation {
//    self.city = [_geocodingService city];
//    self.street = [_geocodingService street];
//    self.houseNumber = [_geocodingService house];

    self.latitude  = [_geocodingService latitude];
    self.longitude = [_geocodingService longitude];

//    self.streetField.text = [NSString stringWithFormat:@"%@, %@", self.city, self.street];
//    self.houseField.text  = self.houseNumber;

    [self.gmsMapView clear];

    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    marker.title = @"Select";
    marker.snippet = @"party here";
    marker.map = self.gmsMapView;

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.latitude doubleValue]
                                                            longitude:[self.longitude doubleValue]
                                                                 zoom:16];
    [self.gmsMapView setCamera:camera];
    [self.gmsMapView setSelectedMarker:marker];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
//    MKCoordinateSpan span = MKCoordinateSpanMake(.015, .015);
//    MKCoordinateRegion reg = MKCoordinateRegionMake(self.currentLocation, span);
//    self.mapView.region = reg;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"String"];
    if(!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"String"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;

    [annotationView targetForAction:@selector(doneButtonPressed:) withSender:annotationView];

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self doneButtonPressed:view];
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

    NSString *searchAddress = [NSString stringWithFormat:@"%@ %@", self.streetField.text, self.houseField.text];

    NSLog(@"You search for %@", searchAddress);

    [_geocodingService geocodeAddress:searchAddress completion:^(NSError *error) {
        if (error) {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                    initWithTitle:@"No such place!" message:@"Try changing query." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        } else {
            [self updatePartyAddressInformation];
        }
    }];
}

#pragma mark - Text Field delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"_activeResponder.tag = %i", _activeResponder.tag);
    if (_activeResponder.tag == 1) {
        _activeResponder = self.houseField;
        [_activeResponder becomeFirstResponder];
    } else if (_activeResponder) {
        [_activeResponder resignFirstResponder];
        _activeResponder = nil;
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
        MKMapView *map = [(PSCreatePartyVC *)[(UINavigationController *)toViewController topViewController] map];
//        endMapRect = [map.superview convertRect:map.frame toView:nil];

        [container insertSubview:toViewController.view belowSubview:fromViewController.view];
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
            toViewController.view.bounds = CGRectMake(0, 64, 320, 504);
            toViewController.view.center = CGPointMake(160, 316);
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

- (IBAction)doneButtonPressed:(id)sender {
//    [self.partyCreateVC setPartyLocation:self.currentLocation];
    [self.delegate updatePartyAddressWith:self.streetField.text
                                    house:self.houseField.text
                                     flat:self.flatField.text
                                longitude:0
                                 latitude:0];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAddress:(id)sender {
//    NSLog(@"self.currentLocation.addressDictionary = %@", self.currentLocation.addressDictionary);
//    NSString *str = [NSString stringWithFormat:@"%@", self.currentLocation.addressDictionary[@"FormattedAddressLines"]];
    NSString *str = [NSString stringWithFormat:@"%@", @"2"];
    NSLog(@"%@", str);
//    [self.partyCreateVC setPartyAddressString:[NSString stringWithFormat:@"%@, %@, %@, %@", _cityName, _streetField, _houseField, _flatField]];
    [UIView transitionFromView:self.editAddressView
                        toView:self.annotationView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished){
                        }];
}

- (GMSMapView *)gmsMapView {
    if (!_gmsMapView) {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                                longitude:151.20
                                                                     zoom:6];


        _gmsMapView = [GMSMapView mapWithFrame:self.mapHolder.bounds camera:camera];
        _gmsMapView.myLocationEnabled = YES;

        [_gmsMapView setDelegate:self];

        [self.mapHolder addSubview:_gmsMapView];
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
    if (self.houseField.text.length == 0) {
        NSLog(@"Empty field");
        valid = NO;
    }

    return valid;
}

- (IBAction)closeButtonPressed:(id)sender {
}

@end