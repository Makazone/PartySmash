//
// Created by Makar Stetsenko on 17.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSFuturePartiesVC.h"
#import "PSParty.h"
#import "PSUser.h"
#import "PSPartyListCell.h"
#import "PSPartyViewController.h"

@interface PSFuturePartiesVC () {

}

@property (nonatomic) NSMutableArray *myParties;
@property (nonatomic) NSMutableArray *goingToParties;

@end

@implementation PSFuturePartiesVC {
    BOOL _firstLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myParties = [NSMutableArray new];
    self.goingToParties = [NSMutableArray new];

    [self.tableView registerNib:[UINib nibWithNibName:@"party_cell" bundle:nil] forCellReuseIdentifier:@"party_list_cell"];

    // Initialize the refresh control.
//    self.refreshControl = [UIRefreshControl new];
//    NSLog(@"self.refreshControl.frame.origin.y = %f", self.refreshControl.frame.origin.y);
//    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(downloadObjects)
                  forControlEvents:UIControlEventValueChanged];

    _firstLoad = YES;
    [self.refreshControl beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_firstLoad) {
//        [self.refreshControl beginRefreshing];
        [self downloadObjects];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"self.tableView.contentOffset (%f, %f)", self.tableView.contentOffset.x, self.tableView.contentOffset.y);
    NSLog(@"self.tableView.contentInset.top = (%f, %f, %f, %f)", self.tableView.contentInset.top, self.tableView.contentInset.right, self.tableView.contentInset.bottom, self.tableView.contentInset.left);
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)downloadObjects {
    NSLog(@"%s", sel_getName(_cmd));
    PFQuery *goingTo = [PFQuery queryWithClassName:[PSParty parseClassName]];
    [goingTo whereKey:@"invited" equalTo:[PSUser currentUser]];
    [goingTo whereKey:@"date" greaterThanOrEqualTo:[[NSDate alloc] initWithTimeIntervalSinceNow:-86400]];

    PFQuery *myParties = [PFQuery queryWithClassName:[PSParty parseClassName]];
    [myParties whereKey:@"creator" equalTo:[PSUser currentUser]];
    [goingTo whereKey:@"date" greaterThanOrEqualTo:[[NSDate alloc] initWithTimeIntervalSinceNow:-86400]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[goingTo, myParties]];
    [query orderByAscending:@"date"];
    [query includeKey:@"creator"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            _firstLoad = NO;
            [self objectsDidLoad:result];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)objectsDidLoad:(NSArray *)objects {
    [self.myParties removeAllObjects];
    [self.goingToParties removeAllObjects];

    for (PSParty *party in objects) {
        if ([[party creator].objectId isEqualToString:[PSUser currentUser].objectId]) {
            [self.myParties addObject:party];
        } else [self.goingToParties addObject:party];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_firstLoad) {

        // Display a message when the table is empty
        UILabel *messageLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

        self.tableView.backgroundView = messageLabel;
        self.tableView.backgroundView.layer.zPosition -= 1;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    } else {

        self.tableView.backgroundView = nil;

        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 2;

    }

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.goingToParties count];
    }
    return [self.myParties count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Я иду";
    }
    return @"Мои вечеринки";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyViewController *partyVC = [sb instantiateViewControllerWithIdentifier:@"party_vc"];
    partyVC.party = [self objectAtIndexPath:indexPath];

    [self.navigationController pushViewController:partyVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSParty *party = [self objectAtIndexPath:indexPath];

    PSPartyListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"party_list_cell" forIndexPath:indexPath];

    cell.partyBody.attributedText = [party getBodyWithKilo:-3.0];
    NSLog(@"width = %f", cell.partyBody.frame.size.width);

    PFFile *userImg = party.creator.photo100;
    cell.partyCreatorPic.image = [UIImage imageNamed:@"feed_S"];
    cell.partyCreatorPic.file = userImg;

    cell.partyCreatorPic.layer.cornerRadius = 25.0f;
    cell.partyCreatorPic.clipsToBounds = YES;

    [cell.partyCreatorPic loadInBackground];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSParty *party = [self objectAtIndexPath:indexPath];
    CGRect r = [[party getBodyWithKilo:-3.0] boundingRectWithSize:CGSizeMake(246, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    NSLog(@"party.getBodyWithKilo:-1 = %@", [party getBodyWithKilo:-1]);
//    NSLog(@"r.si = %f", r.size.height);
    float result = MAX(r.size.height + 23, 65);

//    [_cellHeights insertObject:@(result) atIndex:indexPath.row];
    return result;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1)
        return (self.myParties)[indexPath.row];

    return (self.goingToParties)[indexPath.row];
}


@end