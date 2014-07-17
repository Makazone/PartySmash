//
//  PSLoginViewController.m
//  PartySmash
//
//  Created by Makar Stetsenko on 22.05.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSLoginViewController.h"
#import "PSAuthService.h"
#import "UIView+PSViewInProgress.h"

@interface PSLoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *VKLoginButton;
@property (weak, nonatomic) IBOutlet UIImageView *LogoView;

@end

static NSString *const CREATE_NEW_USER_SEGUE = @"createNewUserSegue";
static NSString *const GO_TO_FEED_SEGUE = @"toUserFeed";

@implementation PSLoginViewController {
    NSOperationQueue *_logInQueue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s", sel_getName(_cmd));

    _logInQueue = [NSOperationQueue new];
    _logInQueue.name = @"LogIn queue";


//    self.navigationController.navigationBar.hidden = YES;
//    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self logInAction:self.VKLoginButton];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInAction:(id)sender {
    [(UIView *)sender showIndicatorWithCornerRadius:5];

    [_logInQueue addOperationWithBlock:^{
        [PSAuthService loginVK:self block:^(PFUser *user, NSError *error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [(UIView *)sender removeIndicator];
                if (!user && !error) {
                    [self performSegueWithIdentifier:CREATE_NEW_USER_SEGUE sender:self];
                } else if (error) {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginVC.error.title", @"Alert view's title when log in error occuried")
                                                message:NSLocalizedString(@"LoginVC.error.message check your internet connection", @"Alert view's message when login error occuried")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"UIAlerView Ok button")
                                      otherButtonTitles:nil] show];
                } else{
                    [self performSegueWithIdentifier:GO_TO_FEED_SEGUE sender:self];
                    NSLog(@"Logged in!");
                }
            }];
        }];
    }];
}

#pragma mark - VK Delegate methods

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    NSLog(@"%s", sel_getName(_cmd));
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil
                                message:NSLocalizedString(@"LoginVC.error.message you should grant vk access to log in", @"User has denied VK access permition")
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    NSLog(@"%s", sel_getName(_cmd));
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    NSLog(@"accessToken = %@ duration = %@ userID = %@", [newToken accessToken], [newToken expiresIn], [newToken userId]);
    NSLog(@"[newToken isExpired] = %d", [newToken isExpired]);
}

#pragma mark - Other

@end
