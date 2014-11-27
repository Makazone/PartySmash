//
// Created by Makar Stetsenko on 29.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSFindPartyVC.h"
#import "PSAppDelegate.h"
#import "PSAuthService.h"
#import "PSUser.h"
#import "PSParty.h"
#import "PSPartyListCell.h"
#import "PSPartyViewController.h"
#import "PSAttributedDrawer.h"
#import "PSPartyListVC.h"

static NSString *GA_SCREEN_NAME = @"Party list";

@implementation PSPartyListVC {
    PFGeoPoint *_userPosition;

    NSMutableDictionary *_offscreenCells;
    BOOL _recompute;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.parseClassName = [PSParty parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
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

    [(PSAppDelegate *)[UIApplication sharedApplication].delegate trackScreen:GA_SCREEN_NAME];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[PSPartyListCell class] forCellReuseIdentifier:@"party_list_cell"];

    [self.navigationItem setTitle:(self.shouldShowMyParties) ? @"Создал(a)" : @"Посетил(a)"];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:[PSParty parseClassName]];

    if (self.shouldShowMyParties) {
        [query whereKey:@"creator" equalTo:self.user];
    } else {
        [query whereKey:@"invited" equalTo:self.user];
        [query whereKey:@"date" lessThanOrEqualTo:[NSDate new]];
    }

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
//    cell.imageView.image = [UIImage imageNamed:@"feed_S"];
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

    cell.body.attributedString = [party getBodyWithKilo:-3.0];

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