//
//  PSFollowFriendsVC.m
//  PartySmash
//
//  Created by Makar Stetsenko on 17.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <VK-ios-sdk/VKApi.h>
#import <Parse/Parse.h>
#import "PSFollowFriendsVC.h"
#import "PSFriendCell.h"
#import "PSUser.h"
#import "PSAppDelegate.h"

@interface PSFollowFriendsVC ()

//@property NSMutableSet *friendsToFollow;
@property NSMutableArray *friendsToFollow;
@property (nonatomic) UILabel *tableHeader;

- (IBAction)donePressed:(id)sender;

@end

static NSString *const TO_FEED_SCREEN_SEGUE = @"newUserToFeed";

@implementation PSFollowFriendsVC {
    NSArray *_friendList;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [(PSAppDelegate *)[[UIApplication sharedApplication] delegate] registerForNotifications];

    [self.navigationItem setHidesBackButton:YES];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator startAnimating];

    self.tableView.backgroundView = activityIndicator;

    [[PSUser currentUser] getFriendsToFollowWithBlock:^(NSError *error, NSArray *result) {
        if (error || [result count] == 0) {
            // TODO procceed to next screen
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [activityIndicator removeFromSuperview];
        [self.tableView.tableHeaderView setHidden:NO];
        _friendList = result;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }];

//    self.friendsToFollow = [NSMutableSet new];
    self.friendsToFollow = [NSMutableArray new];

    NSLog(@"_friendList = %@", _friendList);
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", sel_getName(_cmd));
    static NSString *friendCell = @"friendCell";

    PFUser *friend = [_friendList objectAtIndex:indexPath.row];
    PSFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:friendCell forIndexPath:indexPath];

    cell.name.text = friend.username;

    [cell.follow addTarget:self action:@selector(followPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self setUpFollowButton:cell.follow forUser:friend];

    PFFile *file = friend[@"photo100"];

    NSLog(@"cell.friendPic.frame.size.height = %f", cell.friendPic.frame.size.height);
    NSLog(@"cell.friendPic.frame.size.height = %f", cell.friendPic.frame.size.width);

    cell.friendPic.layer.cornerRadius = 30.0f;
    cell.friendPic.clipsToBounds = YES;

    cell.friendPic.image = [UIImage imageWithData:file.getData];

//    cell.friendPic.layer.cornerRadius = 100.0f;
//    cell.friendPic.clipsToBounds = YES;

    NSLog(@"file.isDataAvailable = %d", file.isDataAvailable);

    return cell;
}


- (void)followPressed:(id)sender
{
    NSLog(@"sender = %@", sender);
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath == nil) { return; }

    PFUser *friendToFollow = [_friendList objectAtIndex:indexPath.row];

    UIButton *button = sender;
    if (![self.friendsToFollow containsObject:friendToFollow]) {
        [self.friendsToFollow addObject:[_friendList objectAtIndex:indexPath.row]];
        [button setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
    } else {
        [self.friendsToFollow removeObject:[_friendList objectAtIndex:indexPath.row]];
        [button setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
   }
}

- (void)setUpFollowButton:(UIButton *)button forUser:(PSUser *)user {
    if (![self.friendsToFollow containsObject:user]) {
        [button setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
    } else [button setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PSFriendCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.follow sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - IBAction methods

- (IBAction)donePressed:(id)sender {
    [[PSUser currentUser] followUsers:self.friendsToFollow];
//    [self performSegueWithIdentifier:TO_FEED_SCREEN_SEGUE sender:self];
//    NSLog(@"self.presentingViewController = %@", self.presentingViewController);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Other

//- (NSMutableSet *)friendsToFollow
//{
//    if (_friendsToFollow) {
//        _friendsToFollow = [NSMutableSet new];
//    }
//    return _friendsToFollow;
//}

@end
