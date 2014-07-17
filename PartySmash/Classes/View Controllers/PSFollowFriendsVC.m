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

@interface PSFollowFriendsVC ()

//@property NSMutableSet *friendsToFollow;
@property NSMutableArray *friendsToFollow;

- (IBAction)donePressed:(id)sender;

@end

static NSString *const TO_FEED_SCREEN_SEGUE = @"newUserToFeed";

@implementation PSFollowFriendsVC {
    NSArray *_friendList;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[PSUser currentUser] getFriendsToFollowWithBlock:^(NSArray *result) {
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

    cell.friendPic.layer.cornerRadius = 100.0f;
//    PFFile *file = friend[@"photo_100"];
//    cell.friendPic.image = [UIImage imageWithData:file.getData];

//    NSLog(@"file.isDataAvailable = %d", file.isDataAvailable);

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
    if ([button.titleLabel.text isEqualToString:@"follow"]) {
        [self.friendsToFollow addObject:[_friendList objectAtIndex:indexPath.row]];
//        [self.friendsToFollow addObject:friendToFollow.username];
        NSLog(@"Follow user %@", friendToFollow.username);
        [button setTitle:@"unfollow" forState:UIControlStateNormal];
        NSLog(@"self.friendsToFollow = %@", self.friendsToFollow);
    } else {
        [self.friendsToFollow removeObject:[_friendList objectAtIndex:indexPath.row]];
//        [self.friendsToFollow removeObject:friendToFollow.username];
        NSLog(@"Unfollow user %@", friendToFollow.username);
        [button setTitle:@"follow" forState:UIControlStateNormal];
   }
}

#pragma mark - IBAction methods

- (IBAction)donePressed:(id)sender {
    [[PSUser currentUser] followUsers:self.friendsToFollow];
    [self performSegueWithIdentifier:TO_FEED_SCREEN_SEGUE sender:self];
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
