//
// Created by Makar Stetsenko on 29.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PSCellDelegate.h"
#import "PSNotificationsVC.h"
#import "PSAuthService.h"
#import "PSNotification.h"
#import "PSUser.h"
#import "PSNotificationCell.h"
#import "PSParty.h"
#import "PSPartyViewController.h"
#import "PSAttributedDrawer.h"
#import "PSNotificationFollowCell.h"
#import "PSEventCell.h"
#import "PSEvent.h"

static NSString *notification_cell = @"notification_cell";
static NSString *notification_following_cell = @"notification_started_following";

@implementation PSNotificationsVC {
    BOOL _firstLoad;
    NSMutableArray *_invitations;
    NSMutableDictionary *_offscreenCells;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"feed_S"];

        self.parseClassName = @"Invitation";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;

        _offscreenCells = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%s", sel_getName(_cmd));

    [self.tableView registerClass:[PSNotificationCell class] forCellReuseIdentifier:notification_cell];
    [self.tableView registerClass:[PSNotificationFollowCell class] forCellReuseIdentifier:notification_following_cell];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"self.tableView.contentOffset (%f, %f)", self.tableView.contentOffset.x, self.tableView.contentOffset.y);
    NSLog(@"self.tableView.contentInset.top = (%f, %f, %f, %f)", self.tableView.contentInset.top, self.tableView.contentInset.right, self.tableView.contentInset.bottom, self.tableView.contentInset.left);
//    if (![PSAuthService isUserLoggedIn]) {
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
//        [self presentViewController:loginViewController animated:YES completion:nil];
//    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (PFQuery *)queryForTable {
    PFQuery *generalQuery = [PFQuery queryWithClassName:[PSNotification parseClassName]];
    [generalQuery whereKey:@"recipient" equalTo:[PSUser currentUser]];

    // Invitaion to display that user is waiting for an approval
    PFQuery *userRequestedQuery = [PFQuery queryWithClassName:[PSNotification parseClassName]];
    [userRequestedQuery whereKey:@"sender" equalTo:[PSUser currentUser]];
    [userRequestedQuery whereKey:@"type" equalTo:[NSNumber numberWithInt:SEND_REQUEST_TYPE]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[generalQuery, userRequestedQuery]];
    [query includeKey:@"sender"];
    [query includeKey:@"party"];
    [query includeKey:@"party.creator"];
    [query includeKey:@"recipient"];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    [query orderByDescending:@"createdAt"];

    return query;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PSNotification *notification = object;

    if (notification.type == STARTED_FOLLOWING) {
        PSNotificationFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:notification_following_cell forIndexPath:indexPath];
        cell.body.attributedString = [notification getBody];
        cell.imageView.image = [UIImage imageNamed:@"feed_S"];
        cell.imageView.file = notification.sender.photo100;

        [self setUpFollowButton:cell.followButton forUser:notification.sender];

        cell.delegate = self;
        cell.indexPath = indexPath;

        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];

        return cell;
    } else {
        PSNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notification_cell forIndexPath:indexPath];
        cell.body.attributedString = [notification getBody];

        cell.imageView.image = [UIImage imageNamed:@"feed_S"];
        cell.imageView.file = notification.sender.photo100;

        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];

        return cell;
    }
}

- (void)setUpFollowButton:(UIButton *)button forUser:(PSUser *)user {
    if ([user isFollowing]) {
        [button setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
    } else [button setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSNotification *notification = [self objectAtIndexPath:indexPath];

    NSString *reuseIdentifier;
    if (notification.type == STARTED_FOLLOWING) {
        reuseIdentifier = notification_following_cell;
    } else reuseIdentifier = notification_cell;

    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    PFTableViewCell *cell = (_offscreenCells)[reuseIdentifier];
    if (!cell) {
        cell = (notification.type == STARTED_FOLLOWING) ? [PSNotificationFollowCell new] : [PSNotificationCell new];
        (_offscreenCells)[reuseIdentifier] = cell;
    }

    // Configure the cell for this indexPath
    // [cell updateFonts];
    if (notification.type == STARTED_FOLLOWING) {
        ((PSNotificationFollowCell *)cell).body.attributedString = [notification getBody];
    } else ((PSNotificationCell *)cell).body.attributedString = [notification getBody];

    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    // NOTE: if you are displaying a section index (e.g. alphabet along the right side of the table view), or
    // if you are using a grouped table view style where cells have insets to the edges of the table view,
    // you'll need to adjust the cell.bounds.size.width to be smaller than the full width of the table view we just
    // set it to above. See http://stackoverflow.com/questions/3647242 for discussion on the section index width.

    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;

//    (self.cellHeights)[indexPath.row] = @(height);
//    self.numberOfComputedHeights += 1;
//    NSLog(@"height = %f", height);

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyViewController *partyVC = [sb instantiateViewControllerWithIdentifier:@"party_vc"];
    partyVC.party =  ((PSNotification *)[self objectAtIndexPath:indexPath]).party;

    [self.navigationController pushViewController:partyVC animated:YES];
}

// Actually did click on button in cell at indexpath
- (void)didClickOnCellAtIndexPath:(NSIndexPath *)cellIndex withData:(id)data {
    if (cellIndex.section != 0) { return; }

    PSNotificationCell *cell = (NSArray*)data[0];
    int code = [((NSArray *)data)[1] intValue];

    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    PSNotification *invitation = [_invitations objectAtIndex:path.row];

    if (code == 3) { // OK
        [invitation deleteEventually];
    } else if (code == 2) { // accept
        [invitation acceptWithCompletion:^(NSError *error) {
            if (error) {
                NSLog(@"error = %@", error);
            }
        }];
    } else {
        [invitation declineWithCompletion:^(NSError *error) {
            if (error) {
                NSLog(@"error = %@", error);
            }
        }];
    }

    [self.tableView beginUpdates];

    [_invitations removeObjectAtIndex:path.row];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationRight];

    [self.tableView endUpdates];
}

@end