//
// Created by Makar Stetsenko on 13.10.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSPriceDescriptionVC.h"
#import "SZTextView.h"
#import "PSParty.h"

@interface PSPriceDescriptionVC () {

}

@property (weak, nonatomic) IBOutlet SZTextView *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIView *partyFreeView;

@end

@implementation PSPriceDescriptionVC {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textField.placeholderTextColor = [UIColor lightGrayColor];
//    self.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

    [self.textField setPlaceholder:@"Provide any necessary information about the price. Don't forget to say about your special offers and discounts!"];

    if (!self.party.isFree) {
        [self.textField becomeFirstResponder];
    }

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.partyFreeView.hidden = !self.party.isFree;
    [self updateDoneButton];
//    self.doneButton.enabled = (self.party.isFree) || [self.party.price length] > 0;

    if (self.party.price != nil && !self.party.isFree) {
        [self.textField setText:self.party.price];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PSPriceDescriptionVC *vc = segue.destinationViewController;
    [vc setParty:self.party];
}

- (IBAction)doneButtonPressed:(id)sender {
    NSLog(@"Finished creating party");
    [self.party saveInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Text View delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSMutableString *descr = [textView.text mutableCopy];
    [descr replaceCharactersInRange:range withString:text];
    NSString *trimmedDescr = [descr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    self.doneButton.enabled = trimmedDescr.length != 0;

    [self.party setPrice:trimmedDescr];

    return YES;
}

- (IBAction)partyFreeButton:(id)sender {
    self.party.isFree = YES;
    [self.partyFreeView setHidden:NO];
    [self updateDoneButton];
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    //[self performSegueWithIdentifier:@"goToContactDescrSegue" sender:sender];
}

- (IBAction)changePartyPrice:(id)sender {
    self.party.isFree = NO;
    self.party.price = @"";
    self.textField.text = self.party.price;
    [self.partyFreeView setHidden:YES];
    [self updateDoneButton];
//    self.doneButton.enabled = (self.party.isFree) || [self.party.price length] > 0;
    [self.textField becomeFirstResponder];
}

- (void)updateDoneButton {
    self.doneButton.enabled = (self.party.isFree) || [self.party.price length] > 0;
}

@end