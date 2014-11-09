//
//  PSUserFeedVC.m
//  PartySmash
//
//  Created by Makar Stetsenko on 16.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PSUserFeedVC.h"
#import "PSLoginViewController.h"
#import "PSUser.h"
#import "PSAuthService.h"
#import "PSEventNewPartyCell.h"
#import "PSParty.h"
#import "PSEventFriendGoesCell.h"
#import "PSEvent.h"
#import "PSPartyViewController.h"

@interface PSUserFeedVC () {
    
}

@property (nonatomic) NSMutableArray *atribitedStrings;

@end

static NSString *newparty_cellid = @"newparty_event_cell";
static NSString *friend_goestoparty_cellid = @"friend_goestoparty_cell";

@implementation PSUserFeedVC {
    int _selectedRow;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"feed_S"];

        self.parseClassName = @"Event";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

//- (id)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:style];
//    if (self) {
//        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"feed_S"];
//
//        // This table displays items in the Todo class
//        self.parseClassName = @"Event";
//        self.pullToRefreshEnabled = YES;
//        self.paginationEnabled = YES;
//        self.objectsPerPage = 25;
//    }
//    return self;
//}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    NSLog(@"%s", sel_getName(_cmd));
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Music" image:[UIImage imageNamed:@"tab_bar_feed_line"] selectedImage:[UIImage imageNamed:@"feed_S"]];
//        NSLog(@"self.tabBarItem.title = %@", self.tabBarItem.title);
//    }
//
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s", sel_getName(_cmd));

    NSLog(@"%s", sel_getName(_cmd));

    [[self tableView] registerNib:[UINib nibWithNibName:@"event_newparty_tablecell" bundle:nil] forCellReuseIdentifier:newparty_cellid];
    [[self tableView] registerNib:[UINib nibWithNibName:@"event_friendgoes_tablecell" bundle:nil] forCellReuseIdentifier:friend_goestoparty_cellid];

//    [[PSUser currentUser] clearFollow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![PSAuthService isUserLoggedIn]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }

    NSLog(@"%s", sel_getName(_cmd));
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (PFQuery *)queryForTable {
    if (![PSAuthService isUserLoggedIn]) {
        return nil;
    }

    NSLog(@"%s", sel_getName(_cmd));
    PFRelation *relation = [[PSUser currentUser] getFollowingRelation];
    PFQuery *followingQuery = [relation query];

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"owner" matchesQuery:followingQuery];
    [query includeKey:@"party"];
    [query includeKey:@"party.creator"];
    [query includeKey:@"owner"];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    [query orderByDescending:@"createdAt"];

    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    NSLog(@"%s", sel_getName(_cmd));

    PSEvent *event = object;

    PSEventFriendGoesCell *cell = [tableView dequeueReusableCellWithIdentifier:friend_goestoparty_cellid forIndexPath:indexPath];

    cell.body.attributedText = [self.atribitedStrings objectAtIndex:indexPath.row]; //[event getEventTextBody];
    cell.body.userInteractionEnabled = NO;

    // TODO optimize attributed string creation
//    cell.timePassed.text = [event getTimePassed];

    PFFile *userImg = event.owner.photo100;
    cell.userImg.image = [UIImage imageNamed:@"feed_S"];
    cell.userImg.file = userImg;

    cell.userImg.layer.cornerRadius = 30.0f;
//    cell.creatorImage.layer.borderWidth = 1.0f;
//    cell.creatorImage.layer.borderColor = [UIColor grayColor].CGColor;
    cell.userImg.clipsToBounds = YES;

    [cell.userImg loadInBackground];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", sel_getName(_cmd));

    if (self.objects.count - 1 < indexPath.row) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

//    if (self.atribitedStrings.count <= indexPath.row || ![self.atribitedStrings objectAtIndex:indexPath.row]) {
        PSEvent *event = [self objectAtIndexPath:indexPath];
        [self.atribitedStrings insertObject:[event getEventTextBody] atIndex:indexPath.row];
//    }

    CGRect r = [[self.atribitedStrings objectAtIndex:indexPath.row] boundingRectWithSize:CGSizeMake(225, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    NSLog(@"(%d) r.size.height = %f", indexPath.row, r.size.height);

    return MAX(ceil(r.size.height) + 20, 85);
//    if (r.size.height <= 75) {
//        return 85;
//    } else return r.size.height + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.objects.count - 1 < indexPath.row) {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

    _selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"partyScreenSegueId" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"partyScreenSegueId"]) {
        PSPartyViewController *destVC = segue.destinationViewController;
        PSEvent *event = [self objectAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];

        destVC.party = event.party;
    }
}


#pragma mark - Getters & Setters

- (NSMutableArray *)atribitedStrings {
    if (!_atribitedStrings) {
        _atribitedStrings = [NSMutableArray new];
    }
    return _atribitedStrings;
}

@end
