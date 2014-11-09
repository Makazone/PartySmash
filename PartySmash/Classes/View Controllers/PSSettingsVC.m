//
// Created by Makar Stetsenko on 09.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSSettingsVC.h"
#import "PSUser.h"


@implementation PSSettingsVC {

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (IBAction)logOut:(id)sender {
    [PSUser logOut];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

- (IBAction)deleteUser:(id)sender {
    [[PSUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"User has been deleted");
    }];
}

@end