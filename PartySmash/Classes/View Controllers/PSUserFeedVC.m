//
//  PSUserFeedVC.m
//  PartySmash
//
//  Created by Makar Stetsenko on 16.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSUserFeedVC.h"
#import "PSLoginViewController.h"
#import "PSUser.h"
#import "PSAuthService.h"

@interface PSUserFeedVC () {
    
}

@end

@implementation PSUserFeedVC {
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"feed_S"];
    }

    return self;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    NSLog(@"%s", sel_getName(_cmd));
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Music" image:[UIImage imageNamed:@"tab_bar_feed_line"] selectedImage:[UIImage imageNamed:@"feed_S"]];
//        NSLog(@"self.tabBarItem.title = %@", self.tabBarItem.title);
//    }
//
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s", sel_getName(_cmd));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"%s", sel_getName(_cmd));
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    if (![PSAuthService isUserLoggedIn]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
        [self presentViewController:loginViewController animated:YES completion:nil];
        // TODO present login view controller
    }
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
