//
// Created by Makar Stetsenko on 16.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSSearchUserVC.h"
#import "PSUser.h"
#import "PSUserCell.h"
#import "UIView+PSViewInProgress.h"
#import "PSProfileVC.h"

@interface PSSearchUserVC () {

}

@property (nonatomic) NSArray *searchResults;
@property (nonatomic) UIView *searchingView;

@end

@implementation PSSearchUserVC {
    UIView *_searchingView;
    BOOL _isSearching;
    UIActivityIndicatorView *_indicatorView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSUser *user = [self.searchResults objectAtIndex:indexPath.row];

    PSUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user_cell" forIndexPath:indexPath];

    cell.userImg.file = user.photo100;
    cell.userImg.layer.cornerRadius = 25.0;
    cell.userImg.clipsToBounds = YES;
    [cell.userImg loadInBackground];

    [self setUpFollowButton:cell.userActionButton forUser:user];

    cell.userNic.text = user.username;

    cell.cellIndexPath = indexPath;
    cell.delegate = self;

    if ([[PSUser currentUser].username isEqualToString:user.username]) {
        [cell.userActionButton setHidden:YES];
        [cell.itsYouLabel setHidden:NO];
    } else {
        [cell.userActionButton setHidden:NO];
        [cell.itsYouLabel setHidden:YES];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"searchString = %@", searchString);
    [self performSearchFor:searchString];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchString = %@", searchBar.text);
    if (!_isSearching) {
        [self performSearchFor:searchBar.text];
    }
}

-(void)performSearchFor:(NSString *)searchString {
    NSLog(@"%s", sel_getName(_cmd));

    _isSearching = YES;

    PFQuery *query = [PSUser query];
    [query whereKey:@"username" containsString:searchString];
    [query setLimit:25];

    self.searchingView.hidden = NO;
    [self.searchResultsTableView bringSubviewToFront:self.searchingView];
    [_indicatorView startAnimating];
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        self.searchingView.hidden = YES;
        [_indicatorView stopAnimating];
        _isSearching = NO;
        if (!error) {
//            [_searchingView removeFromSuperview];
            self.searchResults = result;
            [self.searchResultsTableView reloadData];
        }
    }];
}

- (NSArray *)searchResults {
    if (!_searchResults) {
        _searchResults = [NSArray new];
    }
    return _searchResults;
}

- (void)setUpFollowButton:(UIButton *)button forUser:(PSUser *)user {
    if ([user isFollowing]) {
        [button setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
    } else [button setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSProfileVC *userProfileVS = [sb instantiateViewControllerWithIdentifier:@"userProfileVC"];
    userProfileVS.user = [self.searchResults objectAtIndex:indexPath.row];

    [self.searchContentsController.navigationController pushViewController:userProfileVS animated:YES];
}

- (void)didClickOnCellAtIndexPath:(NSIndexPath *)cellIndex withData:(id)data {
    PSUser *user = [self.searchResults objectAtIndex:cellIndex.row];
    PSUserCell *cell = [self.searchResultsTableView cellForRowAtIndexPath:cellIndex];

    [cell.userActionButton showIndicatorWithCornerRadius:5];
    if ([[PSUser currentUser] isFollowingUser:user.objectId]) {
//        NSLog(@"Unfollow user");
        [[PSUser currentUser] unfollowUser:user withCompletion:^(NSError *error) {
            [cell.userActionButton removeIndicator];
            if (!error) {
                [user setIsFollowing:NO];
                [cell.userActionButton setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
            }
        }];
    } else {
//        NSLog(@"Follow user");
        [[PSUser currentUser] followUser:user withCompletion:^(NSError *error) {
            [cell.userActionButton removeIndicator];
            if (!error) {
                [user setIsFollowing:YES];
                [cell.userActionButton setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
            }
        }];
    }
}

- (UIView *)searchingView {
    if (!_searchingView) {
        _searchingView = [[UIView alloc] initWithFrame:self.searchResultsTableView.frame];
        [_searchingView setBackgroundColor:[UIColor whiteColor]];
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicatorView setFrame:CGRectMake(0, 0, 320, 50)];
        [_searchingView addSubview:_indicatorView];
        _searchingView.hidden = YES;
        [self.searchResultsTableView addSubview:_searchingView];
    }
    return _searchingView;
}

@end