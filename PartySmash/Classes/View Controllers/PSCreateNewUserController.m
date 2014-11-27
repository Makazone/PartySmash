//
//  PSCreateNewUserController.m
//  PartySmash
//
//  Created by Makar Stetsenko on 03.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "PSCreateNewUserController.h"
#import "VKRequest.h"
#import "VKApi.h"
#import "PSAuthService.h"
#import "UIView+PSViewInProgress.h"
#import "MBProgressHUD.h"
#import "PSAppDelegate.h"
#import "GAI.h"
#import "PSUser.h"

static NSString *GA_SCREEN_NAME = @"Create new user";

@interface PSCreateNewUserController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UIView *slidingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonDone;

- (void)keyboardShow:(NSNotification *)n;
- (void)keyboardHide:(NSNotification *)n;

@end

static NSString *const FOLLOW_FRIENDS_SEGUE = @"followFriends";

@implementation PSCreateNewUserController {
    NSData *_photo100, *_photo200;
    UIView *_firstResponder;

    NSOperationQueue *_signUpUserQueue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.userImage.layer.cornerRadius = 100.0f;
    self.userImage.layer.borderWidth = 1.0f;
    self.userImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.userImage.clipsToBounds = YES;

    [self.userImage showIndicatorWithCornerRadius:100];

    _signUpUserQueue = [NSOperationQueue new];
    _signUpUserQueue.name = @"signUp_queue";

    [_signUpUserQueue addOperationWithBlock:^{
        VKRequest *request = [[VKApi users] get:@{ VK_API_FIELDS : @"photo_200,photo_100" }];

        [request executeWithResultBlock:^(VKResponse *response) {
            NSString *result = [NSString stringWithFormat:@"Result: %@", response];
            NSLog(@"result = %@", result);

            NSURL *photo200URL = [NSURL URLWithString:[(VKUser *) response.parsedModel[0] photo_200]];
            NSURL *photo100URL = [NSURL URLWithString:[(VKUser *) response.parsedModel[0] photo_100]];

            _photo200 = [NSData dataWithContentsOfURL:photo200URL];
            _photo100 = [NSData dataWithContentsOfURL:photo100URL];

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.userImage removeIndicator];
                [self.userImage setImage:[UIImage imageWithData:_photo200]];
            }];
        } errorBlock:^(NSError *error) {
            NSString *err = [NSString stringWithFormat:@"Error: %@", error];
            NSLog(@"err = %@", err);
            [self.userImage removeIndicator];
        }];
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];

    [(PSAppDelegate *)[UIApplication sharedApplication].delegate trackScreen:GA_SCREEN_NAME];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self finishSignUp:self];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
* Done button handler
*/
- (IBAction)finishSignUp:(id)sender {
    [_firstResponder resignFirstResponder];
    _firstResponder = nil;

    // TODO optimize token getter
    NSNumber *vkId = [NSNumber numberWithInteger:[[[VKSdk getAccessToken] userId] integerValue]];
    NSString *nickname = [[self nicknameField] text];

    [_signUpUserQueue waitUntilAllOperationsAreFinished];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"CreateUser.hudLabel.Creating account", @"Hud label when signing up user");
    [hud show:YES];

    [_signUpUserQueue addOperationWithBlock:^{
        [PSAuthService signUpVKUser:vkId withNickname:nickname avatar100:_photo100 avatar200:_photo200 completionHandler:^(BOOL succeeded, NSError *error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [hud hide:YES];
                if (error.domain == @"Parse") {
                    [[[UIAlertView alloc] initWithTitle:error.userInfo[NSLocalizedDescriptionKey]
                                                message:error.userInfo[NSLocalizedRecoverySuggestionErrorKey]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                } else if (error) {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginVC.error.title", @"Alert view's title when log in error occuried")
                                                message:NSLocalizedString(@"LoginVC.error.message check your internet connection", @"Alert view's message when login error occuried")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"UIAlerView Ok button")
                                      otherButtonTitles:nil] show];
                } else {
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

                    // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
                    // sent with all subsequent hits.
                    [tracker set:@"&uid"
                           value:[PSUser currentUser].objectId];

                    [[Crashlytics sharedInstance] setUserIdentifier:[PSUser currentUser].objectId];

                    NSLog(@"Success!");
                    [self performSegueWithIdentifier:FOLLOW_FRIENDS_SEGUE sender:self];
                }

            }];
        }];
    }];
}

//- (IBAction)editUserImage:(id)sender {
//    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
//    UIImagePickerController *picker = [UIImagePickerController new];
//    picker.sourceType = type;
//    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:type];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    [self presentViewController:picker animated:YES completion:nil];
//}

#pragma mark - Image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSURL *url = info[UIImagePickerControllerMediaURL];
//    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    self.userImage.imageView.image = editedImage;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if ([navigationController.viewControllers count] == 3) {
//        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
//
//        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1] subviews] objectAtIndex:0];
//
//        plCropOverlay.hidden = YES;
//
//        int position = 0;
//
//        if (screenHeight == 568) {
//            position = 124;
//        } else {
//            position = 80;
//        }
//
//        CAShapeLayer *circleLayer = [CAShapeLayer layer];
//
//        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
//                CGRectMake(0.0f, position, 320.0f, 320.0f)];
//        [path2 setUsesEvenOddFillRule:YES];
//
//        [circleLayer setPath:[path2 CGPath]];
//
//        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
//        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 320, screenHeight-72) cornerRadius:0];
//
//        [path appendPath:path2];
//        [path setUsesEvenOddFillRule:YES];
//
//        CAShapeLayer *fillLayer = [CAShapeLayer layer];
//        fillLayer.path = path.CGPath;
//        fillLayer.fillRule = kCAFillRuleEvenOdd;
//        fillLayer.fillColor = [UIColor blackColor].CGColor;
//        fillLayer.opacity = 0.8;
//        [viewController.view.layer addSublayer:fillLayer];
//
//        UILabel *moveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 50)];
//        [moveLabel setText:@"Move and Scale"];
//        [moveLabel setTextAlignment:NSTextAlignmentCenter];
//        [moveLabel setTextColor:[UIColor whiteColor]];
//
//        [viewController.view addSubview:moveLabel];
//    }
}

#pragma mark - Text field delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _firstResponder = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_firstResponder resignFirstResponder];
    _firstResponder = nil;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    if (text.length == 0) {
        text = nil;
    }

    NSLog(@"text = %@", text);

    self.buttonDone.enabled = text != nil;

    return YES;
}

#pragma mark - Key board methods

- (void)keyboardShow:(NSNotification *)n {
    NSDictionary *d = [n userInfo];
    CGRect r = [d[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    r = [self.slidingView convertRect:r fromView:nil];
    CGRect f = self.nicknameField.frame;
    CGFloat y = CGRectGetMaxY(f) + r.size.height - self.slidingView.bounds.size.height + 10;
    NSNumber *duration = d[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = d[UIKeyboardAnimationCurveUserInfoKey];
    if (r.origin.y < CGRectGetMaxY(f)) {
        [UIView animateWithDuration:duration.floatValue
                              delay:0
                            options:curve.integerValue << 16
                         animations:^{
                            self.topConstraint.constant = -y;
                            self.bottomConstraint.constant = y;
                            [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (void)keyboardHide:(NSNotification *)n {
    NSNumber *duration = n.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = n.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    [UIView animateWithDuration:duration.floatValue delay:0 options:curve.integerValue << 16 animations:^{
        self.topConstraint.constant = 0;
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Other

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
