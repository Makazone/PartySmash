//
// Created by Makar Stetsenko on 13.10.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSPriceDescriptionVC.h"
#import "SZTextView.h"
#import "PSParty.h"
#import "PSAppDelegate.h"
#import "MBProgressHUD.h"
#import "PSPartyViewController.h"
#import "PSUserFeedVC.h"

static NSString *GA_SCREEN_NAME = @"Party Create - price";

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [((PSAppDelegate *)[[UIApplication sharedApplication] delegate]) trackScreen:GA_SCREEN_NAME];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PSPriceDescriptionVC *vc = segue.destinationViewController;
    [vc setParty:self.party];
}

- (IBAction)doneButtonPressed:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Сохраняем вечеринку";//NSLocalizedString(@"CreateUser.hudLabel.Creating account", @"Hud label when signing up user");
    [hud show:YES];

    NSLog(@"Finished creating party");
    if (self.party.isFree) {
        [self.party setPrice:@"0"];
    }

    [self.party saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [hud hide:YES];

        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Упс =(" message:@"Мы не смогли сохранить вашу вечеринку, проверить свое соединение и попробуйте еще раз." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [((PSAppDelegate *) [[UIApplication sharedApplication] delegate]) trackEventWithCategory:@"ui_action"
                                                                                              action:@"button_pressed"
                                                                                               label:@"publish_party"
                                                                                               value:nil];

            [self.delegate didCreateParty:self.party];
            [self dismissViewControllerAnimated:YES completion:^{
            }];

        }
    }];
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