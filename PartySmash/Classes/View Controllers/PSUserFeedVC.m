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

@interface PSUserFeedVC () {
    
}

@end

@implementation PSUserFeedVC {
    
}

- (IBAction)logOut:(id)sender {
    [PSUser logOut];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSLoginViewController *loginViewController = [(UINavigationController *) [sb instantiateInitialViewController] topViewController];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)deleteUser:(id)sender {
    [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"User has been deleted");
    }];
    [self logOut:sender];
}

@end
