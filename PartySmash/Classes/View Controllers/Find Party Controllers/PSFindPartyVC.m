//
// Created by Makar Stetsenko on 29.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSFindPartyVC.h"
#import "PSAuthService.h"
#import "PSUser.h"
#import "PSParty.h"
#import "PSPartyListCell.h"
#import "PSPartyViewController.h"
#import "PSAttributedDrawer.h"

@implementation PSFindPartyVC {
    PFGeoPoint *_userPosition;

    NSMutableDictionary *_offscreenCells;
    BOOL _recompute;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"find_parties_S"];

        self.parseClassName = @"Event";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;

        _offscreenCells = [NSMutableDictionary new];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![PSAuthService isUserLoggedIn]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[PSPartyListCell class] forCellReuseIdentifier:@"party_list_cell"];

    _recompute = NO;

    self.searchDisplayController.delegate = self.searchDisplayController;
    self.searchDisplayController.searchResultsDataSource = self.searchDisplayController;
    self.searchDisplayController.searchResultsDelegate = self.searchDisplayController;
    self.searchDisplayController.searchBar.delegate = self.searchDisplayController;

    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"user_cell" bundle:nil] forCellReuseIdentifier:@"user_cell"];


}

- (void)loadObjects {
    _userPosition = nil;

    _recompute = YES;

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            _userPosition = geoPoint;
            [super loadObjects];
        }
    }];
}


- (PFQuery *)queryForTable {
    if (!_userPosition) { return nil; }

    PFQuery *query = [PFQuery queryWithClassName:[PSParty parseClassName]];
    [query whereKey:@"geoPosition" nearGeoPoint:_userPosition];
    [query whereKey:@"date" greaterThanOrEqualTo:[[NSDate alloc] initWithTimeIntervalSinceNow:-86400]];
    [query whereKey:@"creator" notEqualTo:[PSUser currentUser]];
    [query includeKey:@"creator"];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    [query orderByAscending:@"date"];
//    [query orderByAscending:@"geoPosition"];

    return query;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
//    _recompute = NO;

    PSParty *party = object;

    PSPartyListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"party_list_cell" forIndexPath:indexPath];

    cell.body.attributedString = [party getBodyWithKilo:-3.0];

    PFFile *userImg = party.creator.photo100;
    cell.imageView.image = [UIImage imageNamed:@"feed_S"];
    cell.imageView.file = userImg;

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = @"party_list_cell";

    PSPartyListCell *cell = _offscreenCells[reuseId];
    if (!cell) {
        cell = [PSPartyListCell new];
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        _offscreenCells[reuseId] = cell;
    }

    PSParty *party = [self objectAtIndexPath:indexPath];

    cell.body.attributedString = [party getBodyWithKilo:[party.geoPosition distanceInKilometersTo:_userPosition]];

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.objects.count - 1 < indexPath.row) {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyViewController *partyVC = [sb instantiateViewControllerWithIdentifier:@"party_vc"];
    partyVC.party = [self objectAtIndexPath:indexPath];

    [self.navigationController pushViewController:partyVC animated:YES];
}

@end