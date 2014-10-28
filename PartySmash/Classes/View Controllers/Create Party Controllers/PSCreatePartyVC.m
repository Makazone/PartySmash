//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "PSCreatePartyVC.h"
#import "PSParty.h"
#import "PSUser.h"
#import "MapKit/MKMapView.h"
#import "PSSelectPlaceVC.h"
#import "PSGeneralDescriptionVC.h"
#import "PSMapInfoView.h"

static NSDateFormatter *dateFormatter;

@interface PSCreatePartyVC () {
}

@property (nonatomic) PSParty *newParty;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *partyNameField;
@property (weak, nonatomic) IBOutlet UITextView *partyDescriptionField;
@property (weak, nonatomic) IBOutlet UILabel *partyDateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *partyTypeControl;
@property (weak, nonatomic) IBOutlet UIPickerView *partySizePicker;

@property (weak, nonatomic) IBOutlet GMSMapView *partyLocationMap;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UILabel *partyStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *partyCapacityLabel;

@property (weak, nonatomic) IBOutlet UISlider *partyCapacitySlider;

@end

@implementation PSCreatePartyVC {
    UIView *_keyboardResponder;
    NSString *_descriptionPlaceholder;
    UIColor *_descriptionPlaceholderColor;
    BOOL _descriptionFirstEdit;
    BOOL _shouldDisplayDatePicker;
    BOOL _subscribed;

    CLLocationManager *_locationManager;
}

+ (void)initialize
{
    NSLocale *locale = [NSLocale currentLocale];
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = @"d MMMM HH:mm";
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.partyLocationMap.delegate = self;

    [self subscribeToNotifications];

    [self updateNextButton];

    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

    _locationManager = [[CLLocationManager alloc] init];

    [self.partyTypeControl addTarget:self action:@selector(changePartyType:) forControlEvents:UIControlEventValueChanged];
    [self.partyCapacitySlider addTarget:self action:@selector(partySizeChanged:) forControlEvents:UIControlEventValueChanged];

    UITapGestureRecognizer *tapOnFreeSpace = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardTap:)];
    [tapOnFreeSpace setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tapOnFreeSpace];

    self.partyLocationMap.myLocationEnabled = YES;
    [self.partyLocationMap setDelegate:self];

    self.partyLocationMap.settings.rotateGestures = NO;
    self.partyLocationMap.settings.scrollGestures = NO;
    self.partyLocationMap.settings.zoomGestures = NO;
    self.partyLocationMap.settings.tiltGestures = NO;

//    NSLog(@"self.partyLocationMap.projection.visibleRegion = ", self.partyLocationMap.projection.visibleRegion);self.partyLocationMap.projection.visibleRegion.nearLeft.;
//    [self printVisibleRegion:self.partyLocationMap.projection.visibleRegion.farLeft];
//    [self printVisibleRegion:self.partyLocationMap.projection.visibleRegion.farRight];
//    [self printVisibleRegion:self.partyLocationMap.projection.visibleRegion.nearRight];
//    [self printVisibleRegion:self.partyLocationMap.projection.visibleRegion.nearLeft];
}

- (void)printVisibleRegion:(CLLocationCoordinate2D) a {
    NSLog(@"[latitude = %f, longitude = %f]", a.latitude, a.longitude);
}

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

- (void)subscribeToNotifications
{
    if (_subscribed)
        return;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)unsubscribeFromNotifications
{
    if (!_subscribed)
        return;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    NSLog(@"%s", sel_getName(_cmd));



    [super viewWillLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"%s", sel_getName(_cmd));

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];

    [self updatePartyLocation];
}


#pragma mark - Map delegate methods

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"selectPlaceInfoWindow" owner:nil options:nil];

    PSMapInfoView *plainView = [nibContents lastObject];

    if (self.newParty.address) {
        plainView.subtitle.text  = @"Tap to change";
        plainView.title.text = self.newParty.address;
        plainView.title.font = [UIFont systemFontOfSize:16];
    } else {
        plainView.title.text = @"Tap to select a place";
        plainView.subtitle.text = @"";
    }

//    _infoWindow = plainView;

    return plainView;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self expandMapViewButton:mapView];
}

- (void)updatePartyLocation {
    [self.partyLocationMap clear];

    CLLocationCoordinate2D loc;
    if (self.newParty.address) {
        loc = CLLocationCoordinate2DMake(self.newParty.geoPosition.latitude, self.newParty.geoPosition.longitude);
    } else loc = CLLocationCoordinate2DMake(55.751186, 37.615432);

    self.newParty.geoPosition.latitude = loc.latitude;
    self.newParty.geoPosition.longitude = loc.longitude;

    GMSMarker *marker = [GMSMarker markerWithPosition:loc];
    marker.map = self.partyLocationMap;

//    CGPoint p = [self.partyLocationMap.projection pointForCoordinate:loc];
//    p.y -= 70;
//    CLLocationCoordinate2D l = [self.partyLocationMap.projection coordinateForPoint:p];

    self.partyLocationMap.padding = UIEdgeInsetsMake(150, 0, 0, 0);

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.latitude
                                                            longitude:loc.longitude
                                                                 zoom:16];
    [self.partyLocationMap setCamera:camera];
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.latitude
//                                                            longitude:loc.longitude
//                                                                 zoom:16];
//    [self.partyLocationMap setCamera:camera];
    [self.partyLocationMap setSelectedMarker:marker];

    [self updateNextButton];
}

#pragma mark - CLLocationManagerDelegate

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) { return YES; }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [super tableView:tableView heightForFooterInSection:section];
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        NSString *headerText = @"";
        if (section == 1) {
            headerText = @"When should we come?";
        } else if (section == 2) {
            headerText = @"Are you open minded?";
        } else if (section == 3) {
            headerText = @"So..how large will it be?";
        } else if (section == 4) {
            headerText = @"What about a place?";
        }
        tableViewHeaderFooterView.textLabel.text = headerText;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1 && _shouldDisplayDatePicker) {
        NSLog(@"%s", sel_getName(_cmd));
        return 2;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        UITableViewCell *cellPicker = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellPicker"];
        self.datePicker = [[UIDatePicker alloc] init];
        NSDate *dateMin = [NSDate dateWithTimeIntervalSinceNow:15 * 60];
        NSDate *dateProposed = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
        self.datePicker.minimumDate = dateMin;
        self.datePicker.minuteInterval = 15;
        [self.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
        [cellPicker.contentView addSubview:self.datePicker];
        return cellPicker;
    }

    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section != 1) { return cell; }

    UIImageView *disclosure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosureDown"]];

    cell.accessoryView = disclosure;

    NSLog(@"cell.accessoryView = %@", cell.accessoryView);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_keyboardResponder) {
        [_keyboardResponder resignFirstResponder];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSIndexPath *dateIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    if (indexPath.section == 1) {
        CGFloat angel = !_shouldDisplayDatePicker ? M_PI : 0;
        [UIView animateWithDuration:0.3 animations:^{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryView.transform = CGAffineTransformMakeRotation(angel);
        }];

        if (!_shouldDisplayDatePicker) {
            _shouldDisplayDatePicker = YES;
            [tableView insertRowsAtIndexPaths:@[dateIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            _shouldDisplayDatePicker = NO;
            [self.datePicker removeFromSuperview];
            [tableView deleteRowsAtIndexPaths:@[dateIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 216.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

#pragma mark - Text field, input text delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *name = [textField.text mutableCopy];
    [name replaceCharactersInRange:range withString:string];
    NSString *trimmedName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [self.newParty setName:trimmedName];
    [self updateNextButton];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%s", sel_getName(_cmd));
    if (![_keyboardResponder isFirstResponder]) {
        _keyboardResponder = textField;
    }
}

#pragma mark - Action methods

- (IBAction)cancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)expandMapViewButton:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    PSSelectPlaceVC *selectPlaceVC = [sb instantiateViewControllerWithIdentifier:@"selectPlaceVC"];
    selectPlaceVC.transitioningDelegate = selectPlaceVC;
    [selectPlaceVC setParty:self.newParty];

    [self presentViewController:selectPlaceVC animated:YES completion:nil];
}

- (void)datePickerChanged:(id)sender {
    [self.newParty setDate:self.datePicker.date];
    self.partyDateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
    self.partyDateLabel.textColor = [UIColor blackColor];
    [self updateNextButton];
}

- (MKMapView *)map {
    return self.partyLocationMap;
}

- (void)setPartyAddressString:(NSString *)partyAddressString {
    _partyAddressString = partyAddressString;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    static NSString *descrSegue = @"enterDescriptionSegue";
    if ([segue.identifier isEqualToString:descrSegue]) {
        PSGeneralDescriptionVC *vc = segue.destinationViewController;
        [vc setParty:self.newParty];
    }
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//
//    return YES;
//}

- (void)dismissKeyboardTap:(UIView *)sender {
    NSLog(@"%s", sel_getName(_cmd));
    if (_keyboardResponder) {
        [_keyboardResponder resignFirstResponder];
        _keyboardResponder = nil;
    }
}

- (IBAction)changePartyType:(id)sender {
    if (self.partyTypeControl.selectedSegmentIndex == 0) {
        self.partyStatusLabel.text = @"YES! Anyone is welcomed!";
        [self.newParty setIsPrivate:NO];
    } else {
        self.partyStatusLabel.text = @"Invitations are required.";
        [self.newParty setIsPrivate:YES];
    }
}

- (void)partySizeChanged:(id)sender {
    int descreteValue = self.partyCapacitySlider.value;

    [self.newParty setCapacity:descreteValue];

    NSString *capLabel = [NSString stringWithFormat:@"%d people max.", descreteValue];
    if (descreteValue == 101) {
        capLabel = @"NO Limits!";
        [self.newParty setCapacity:0];
    }

    [self.partyCapacitySlider setValue:descreteValue animated:YES];
    [self.partyCapacityLabel setText:capLabel];
}

- (void)updateNextButton {
    self.nextButton.enabled = self.newParty.name.length != 0 && self.newParty.date != nil && self.newParty.address;
}


#pragma mark - Getters

- (PSParty *)newParty {
    if (!_newParty) {
        _newParty = [PSParty object];
        [_newParty setCapacity:self.partyCapacitySlider.value];
        [_newParty setIsPrivate:NO];
        [_newParty setGeoPosition:[PFGeoPoint new]];
        [_newParty setCreator:[PSUser currentUser]];
    }
    return _newParty;
}

@end