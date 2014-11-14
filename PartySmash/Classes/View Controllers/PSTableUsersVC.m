//
// Created by Makar Stetsenko on 08.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSTableUsersVC.h"
#import "PSAuthService.h"
#import "PSUser.h"
#import "PSUserCell.h"
#import "UIView+PSViewInProgress.h"
#import "PSProfileVC.h"
#import "PSParty.h"

@interface PSTableUsersVC ()

@property (nonatomic) NSMutableArray *usersToInvite;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIView *invitationsLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *placesLeftLabel;

@end

@implementation PSTableUsersVC {

    BOOL _unlimitedNumberOfPlaces;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.parseClassName = @"_User";
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"self.presentingViewController.presentedViewController = %@", self.presentingViewController.presentedViewController);
    NSLog(@"self.presentingViewController = %@", self.presentingViewController);

    [self.navigationItem setTitle:self.screenTitle];

    if (!self.isModal) {
//        [self.navItem removeFromSuperview];
        NSLog(@"%d", self.tableView.frame.origin.y);
        self.navItem = self.navigationController.navigationItem;
//        self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
        NSLog(@"%@", self.navItem.title);
    } else {
//        [(UINavigationItem *)self.navigationBar.items[0] setTitle:@"Пригласить"];
    }

    if (!self.sendsInvites) {
        [self.invitationsLeft removeFromSuperview];
        [self.tableView setTableHeaderView:nil];
    }

    if (self.needsFollow) {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItem:nil];
//        self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    } else if (self.sendsInvites) {
        if (self.placesLeft == -1) {
            self.placesLeftLabel.text = [NSString stringWithFormat:@"Приглашай сколько влезет =)", self.placesLeft];
            _unlimitedNumberOfPlaces = YES;
            self.placesLeft = 50000000;
        } else self.placesLeftLabel.text = [NSString stringWithFormat:@"Осталось приглашений: %d", self.placesLeft];
    }
}

- (PFQuery *)queryForTable {
    PFQuery *query;
    if (!self.needsFollow) {
        PFRelation *relation = [[PSUser currentUser] getFollowingRelation];
        query = [relation query];
        [query whereKey:@"following" equalTo:[PSUser currentUser]];
    } else query = self.userQueryToDisplay;

    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }

    [query orderByDescending:@"username"];

    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    NSLog(@"%s", sel_getName(_cmd));

    PSUser *user = object;
    NSLog(@"user.username = %@", user.username);

    PSUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user_cell" forIndexPath:indexPath];

    cell.userNic.text = user.username;

    cell.userImg.file = user.photo100;
    cell.userImg.layer.cornerRadius = 20.0f;
    cell.userImg.clipsToBounds = YES;
    [cell.userImg loadInBackground];

    if (!self.needsFollow) {
        cell.userActionButton.hidden = YES;
        cell.accessoryType = ([self.usersToInvite containsObject:user]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

    if (self.needsFollow) {
        if ([user.username isEqualToString:[PSUser currentUser].username]) {
            cell.itsYouLabel.hidden = NO;
            cell.userActionButton.hidden = YES;
        } else {
            cell.itsYouLabel.hidden = YES;
            cell.userActionButton.hidden = NO;
        }
    }

    [self setUpFollowButton:cell.userActionButton forUser:user];

    cell.cellIndexPath = indexPath;
    cell.delegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.objects.count - 1 < indexPath.row) {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

    if (self.needsFollow) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PSProfileVC *userProfileVS = [sb instantiateViewControllerWithIdentifier:@"userProfileVC"];
        userProfileVS.user = [self objectAtIndexPath:indexPath];

        [self.navigationController pushViewController:userProfileVS animated:YES];
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.placesLeft += 1;
            [self.usersToInvite removeObjectIdenticalTo:[self objectAtIndexPath:indexPath]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            if (self.placesLeft > 0) {
                [self.usersToInvite addObject:[self objectAtIndexPath:indexPath]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.placesLeft -= 1;
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Мест больше нет! =(" message:nil delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil] show];
            }
        }

        [self updateInvitesLeftLabel];
    }
}


- (void)didClickOnCellAtIndexPath:(NSIndexPath *)cellIndex withData:(id)data {
    PSUser *user = [self objectAtIndexPath:cellIndex];
    PSUserCell *cell = [self.tableView cellForRowAtIndexPath:cellIndex];

    [cell.userActionButton showIndicatorWithCornerRadius:5];
    if ([[PSUser currentUser] isFollowingUser:user.objectId]) {
        NSLog(@"Unfollow user");
        [[PSUser currentUser] unfollowUser:user withCompletion:^(NSError *error) {
            [cell.userActionButton removeIndicator];
            if (!error) {
                [user setIsFollowing:NO];
                [cell.userActionButton setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
            }
        }];
    } else {
        NSLog(@"Follow user");
        [[PSUser currentUser] followUser:user withCompletion:^(NSError *error) {
            [cell.userActionButton removeIndicator];
            if (!error) {
                [user setIsFollowing:YES];
                [cell.userActionButton setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
            }
        }];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [defaults stringArrayForKey:@"followingUsers"];
    NSLog(@"TOTALFOLLOWING = %u", arr.count);
    for (int i = 0; i < arr.count; i++) {
        NSLog(@"arr[i] = %@", arr[i]);
    }
}

- (void)setUpFollowButton:(UIButton *)button forUser:(PSUser *)user {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSArray *arr = [defaults stringArrayForKey:@"followingUsers"];
//    NSLog(@"TOTALFOLLOWING = %u", arr.count);

//    if ([[PSUser currentUser] isFollowingUser:user.objectId]) {
    if ([user isFollowing]) {
        [button setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
    } else [button setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
}

- (IBAction)cancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButton:(id)sender {
    if (self.sendsInvites) {
        [self.party inviteFriends:self.usersToInvite];
    } else
        [self.party recommendToFriends:self.usersToInvite];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableArray *)usersToInvite {
    if (!_usersToInvite) {
        _usersToInvite = [NSMutableArray new];
    }
    return _usersToInvite;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
            || self.navigationController.presentingViewController.presentedViewController == self.navigationController
            || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

- (void)updateInvitesLeftLabel {
    if (_unlimitedNumberOfPlaces) { return; }
    self.placesLeftLabel.text = [NSString stringWithFormat:@"Осталось приглашений: %d", self.placesLeft];
}

@end