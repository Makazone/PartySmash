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


@implementation PSFindPartyVC {
    PFGeoPoint *_userPosition;

    NSMutableArray *_cellHeights;
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

    [self.tableView registerNib:[UINib nibWithNibName:@"party_cell" bundle:nil] forCellReuseIdentifier:@"party_list_cell"];

    _cellHeights = [NSMutableArray new];
    _recompute = NO;
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

    cell.partyBody.attributedText = [party getBodyWithKilo:-3.0];

    PFFile *userImg = party.creator.photo100;
    cell.partyCreatorPic.image = [UIImage imageNamed:@"feed_S"];
    cell.partyCreatorPic.file = userImg;

    cell.partyCreatorPic.layer.cornerRadius = 25.0f;
    cell.partyCreatorPic.clipsToBounds = YES;

    [cell.partyCreatorPic loadInBackground];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.objects.count - 1 < indexPath.row) {
        _recompute = NO;
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    if (!_recompute && [_cellHeights count] > indexPath.row) {
        return [[_cellHeights objectAtIndex:indexPath.row] floatValue];
    }

    NSLog(@"_cellHeights.count = %u", _cellHeights.count);

    PSParty *party = [self objectAtIndexPath:indexPath];
    CGRect r = [[party getBodyWithKilo:[party.geoPosition distanceInKilometersTo:_userPosition]] boundingRectWithSize:CGSizeMake(240, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    NSLog(@"r.si = %f", r.size.height);
    float result = MAX(r.size.height + 23, 65);

    [_cellHeights insertObject:@(result) atIndex:indexPath.row];
    return result;
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