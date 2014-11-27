//
//  PSLoginViewController.m
//  PartySmash
//
//  Created by Makar Stetsenko on 22.05.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "PSLoginViewController.h"
#import "PSAuthService.h"
#import "UIView+PSViewInProgress.h"
#import "PSUser.h"
#import "PSAppDelegate.h"
#import "GAI.h"

static NSString *const CREATE_NEW_USER_SEGUE = @"createNewUserSegue";
static NSString *const GO_TO_FEED_SEGUE = @"toUserFeed";
static NSString *GA_SCREEN_NAME = @"Login";

@interface PSLoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *VKLoginButton;
@property (weak, nonatomic) IBOutlet UIImageView *LogoView;

@end

@implementation PSLoginViewController {
    NSOperationQueue *_logInQueue;
    UIButton *_loginButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s", sel_getName(_cmd));

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    _logInQueue = [NSOperationQueue new];
    _logInQueue.name = @"LogIn queue";


//    self.navigationController.navigationBar.hidden = YES;
//    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

    [(PSAppDelegate *)[UIApplication sharedApplication].delegate trackScreen:GA_SCREEN_NAME];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self logInAction:self.VKLoginButton];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackTranslucent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInAction:(id)sender {
    _loginButton = sender;
    [_logInQueue addOperationWithBlock:^{
        [PSAuthService loginVK:self];
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
    [_loginButton removeIndicator];
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
    NSLog(@"%s", sel_getName(_cmd));
    [_loginButton showIndicatorWithCornerRadius:5];

    NSNumber *vkId = [NSNumber numberWithInteger:[[newToken userId] integerValue]];

    NSLog(@"vkId = %@", vkId);

    PFQuery *query = [PSUser query];
    [query whereKey:@"vkId" equalTo:vkId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        [_loginButton removeIndicator];
        if (!error) {
            NSString *username = [(PSUser *) result.firstObject username];
            NSLog(@"username = %@", username);

            if (!username) {
                [self performSegueWithIdentifier:CREATE_NEW_USER_SEGUE sender:self];
                return;
            }

            [PSUser logInWithUsernameInBackground:username password:@"password" block:^(PFUser *user, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginVC.error.title", @"Alert view's title when log in error occuried")
                                                message:NSLocalizedString(@"LoginVC.error.message check your internet connection", @"Alert view's message when login error occuried")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"UIAlerView Ok button")
                                      otherButtonTitles:nil] show];
                } else {
                    [(PSAppDelegate *)[[UIApplication sharedApplication] delegate] registerForNotifications];
                    [[PSUser currentUser] checkFollowDefaults];
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

                    // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
                    // sent with all subsequent hits.
                    [tracker set:@"&uid"
                           value:user.objectId];

                    [[Crashlytics sharedInstance] setUserIdentifier:user.objectId];
                }
            }];

        } else {
            [[[UIAlertView alloc] initWithTitle:@"Упс =(" message:@"Произошло что-то очень плохое. Проверьте ваше соединение и перезапустите приложение." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];

}

#pragma mark - Other

@end
