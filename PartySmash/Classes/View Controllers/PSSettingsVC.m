//
// Created by Makar Stetsenko on 09.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

@import MessageUI;

#import <VK-ios-sdk/VKSdk.h>
#import "PSSettingsVC.h"
#import "PSUser.h"
#import "PSAppDelegate.h"
#import "iRate.h"

static NSString *GA_SCREEN_NAME = @"Settings";

@implementation PSSettingsVC {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [(PSAppDelegate *)[UIApplication sharedApplication].delegate trackScreen:GA_SCREEN_NAME];
}

#pragma mark -
#pragma mark Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) { [self logOut:self]; }
    else {
        if (indexPath.row == 0) {
            [self sendEmail];
        } else {
            [[iRate sharedInstance] openRatingsPageInAppStore];
        }
    }
}


- (void)logOut:(id)sender {
    [VKSdk forceLogout];
    [PSUser logOut];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
    [self presentViewController:loginViewController animated:YES completion:nil];

    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)socialVK:(id)sender {
    NSURL *vkURL = [NSURL URLWithString:@"vk://vk.com/partysmash"];
    if ([[UIApplication sharedApplication] canOpenURL:vkURL]) {
        [[UIApplication sharedApplication] openURL:vkURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vk.com/partysmash"]];
    }
}

- (IBAction)socialInsta:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=partysmash"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"www.instagram.com/partysmash"]];
    }
}

- (IBAction)socialTwitter:(id)sender {
    NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=PartySmashApp"];
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/PartySmashApp"]];
    }
}

#pragma mark -
#pragma mark Report Problem

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        [mailVC setSubject:@"PartySmash Report"];
        [mailVC setToRecipients:@[@"partysmashofficial@gmail.com"]];
        mailVC.mailComposeDelegate = self;
        [self presentViewController:mailVC animated:YES completion:nil];
    } else {
        NSLog(@"E-mailing Unavailable");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Customer.send_email_error.error", nil)
                                                            message:NSLocalizedString(@"Customer.send_email_error.unable to send email", @"MFMailComposeVC.canSendEmail = NO")
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"Error.Ok", @"Cancel OK button title of alertView")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end