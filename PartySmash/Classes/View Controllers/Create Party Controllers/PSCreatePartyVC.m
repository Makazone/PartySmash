//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "PSCreatePartyVC.h"
#import "PSParty.h"
#import "MapKit/MKMapView.h"
#import "PSSelectPlaceVC.h"

static NSDateFormatter *dateFormatter;

@interface PSCreatePartyVC () {
    
}

@property (nonatomic) PSParty *newParty;

@property (weak, nonatomic) IBOutlet UITextField *partyNameField;
@property (weak, nonatomic) IBOutlet UITextView *partyDescriptionField;
@property (weak, nonatomic) IBOutlet UILabel *partyDateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *partyTypeControl;
@property (weak, nonatomic) IBOutlet UIPickerView *partySizePicker;
@property (weak, nonatomic) IBOutlet MKMapView *partyLocationMap;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property UIDatePicker *datePicker;

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
    dateFormatter.dateFormat = @"dd.MM.yy HH:mm";
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.newParty = [PSParty object];

    _descriptionFirstEdit = YES;

    [self subscribeToNotifications];

    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

    _locationManager = [[CLLocationManager alloc] init];

//    self.partyCoordinate

//    CGRect pickerFrame = self.partySizePicker.frame;
//    pickerFrame.size.height = 162.0;
//
//    [self.partySizePicker setFrame:pickerFrame];
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
    [super viewWillLayoutSubviews];

    CGRect pickerFrame = self.partySizePicker.frame;
    pickerFrame.size.height = 162.0;

    [self.partySizePicker setFrame:pickerFrame];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.partyLocation) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    } else {
        [self updatePartyLocationPin:self.partyLocation.location];
    }
}


#pragma mark - Map delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"String"];
    if(!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"String"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    // Go to edit view
//    ViewController *detailViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//    [self.navigationController pushViewController:detailViewController animated:YES];
    NSLog(@"clicked!");
}

- (void)updatePartyLocationPin:(CLLocation *)newLocation {
    self.partyLocation = [[MKPlacemark alloc] initWithCoordinate:newLocation.coordinate addressDictionary:nil];

    [self.map removeAnnotations:self.map.annotations];

    MKPointAnnotation *ann = [MKPointAnnotation new];
    ann.coordinate = self.partyLocation.coordinate;
    ann.title = @"My party will be here!";

    [self.map addAnnotation:ann];

    [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.partyLocation.coordinate, 1000, 1000) animated:YES];
    [self.map selectAnnotation:ann animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//            initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self updatePartyLocationPin:newLocation];
    [_locationManager stopUpdatingLocation];
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) { return YES; }
    return NO;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        return @"When should we come?";
//    } else if (section == 2) {
//        return @"Are you open minded?";
//    }
//    return @"";
//}

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
    NSLog(@"%s", sel_getName(_cmd));
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%s", sel_getName(_cmd));
    if (![_keyboardResponder isFirstResponder]) {
        _keyboardResponder = textField;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"%s", sel_getName(_cmd));
    NSString *trimmedPartyName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedPartyName.length != 0) {
        [_newParty setName:trimmedPartyName];
    } else { [_newParty setName:nil]; textField.text = nil; }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textField = %@", textField);
    if (_keyboardResponder) {
        [_partyDescriptionField becomeFirstResponder];
        _keyboardResponder = _partyDescriptionField;
    }
    return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _keyboardResponder = textView;
    if (_descriptionFirstEdit) {
        _descriptionPlaceholder = textView.text;
        _descriptionPlaceholderColor = textView.textColor;
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textView.text = '%@'", textView.text);
    NSString *trimmedPartyDescription = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedPartyDescription.length == 0) {
        textView.text = _descriptionPlaceholder;
        textView.textColor = _descriptionPlaceholderColor;
        _descriptionFirstEdit = YES;
    } else {
        _descriptionFirstEdit = NO;
        [_newParty setDescription:trimmedPartyDescription];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"%s", sel_getName(_cmd));
    return YES;
}

# pragma mark - UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *titles = @[@"Small (3-5)", @"Medium (6-15)", @"Large (16-30)", @"World wide (30+)"];
    return titles[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_newParty setCapacity:[self getSizeBasedOnPickerRow:row]];
}

- (int)getSizeBasedOnPickerRow:(NSInteger)row
{
    int size = -1;
    switch (row) {
        case 0:
            size = 5;
            break;
        case 1:
            size = 15;
            break;
        case 2:
            size = 30;
            break;
        case 3:
            size = -1;
            break;
    }
    return size;
}


#pragma mark - Action methods

- (IBAction)saveParty:(id)sender {
    [_newParty setCapacity:[self getSizeBasedOnPickerRow:[self.partySizePicker selectedRowInComponent:0]]];
    [_newParty setCreator:[PFUser currentUser]];
    [_newParty saveInBackground];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)expandMapViewButton:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSSelectPlaceVC *selectPlaceVC = [sb instantiateViewControllerWithIdentifier:@"selectPlaceVC"];
    selectPlaceVC.transitioningDelegate = selectPlaceVC;

//    [selectPlaceVC setCurrentLocation:self.partyLocation];
//    [selectPlaceVC setCurrentLocation:self.partyLocation];
//    [selectPlaceVC setPartyCreateVC:self];

    [self presentViewController:selectPlaceVC animated:YES completion:nil];
}

- (void)datePickerChanged:(id)sender {
    [_newParty setDate:self.datePicker.date];
    self.partyDateLabel.text = [dateFormatter stringFromDate:self.datePicker.date];
}

- (MKMapView *)map {
    return self.partyLocationMap;
}

- (void)setPartyAddressString:(NSString *)partyAddressString {
    _partyAddressString = partyAddressString;
}

- (void)updatePartyAddressWith:(NSString *)cityStreet
                         house:(NSString *)houseNumber
                          flat:(NSString *)flatNumber
                     longitude:(NSNumber *)longitude
                      latitude:(NSNumber *)latitude {
    NSLog(@"Party place updated!");

}

#pragma mark - Getters

- (PSParty *)newParty {
    if (_newParty) {
        _newParty = [PSParty object];
    }
    return _newParty;
}

@end