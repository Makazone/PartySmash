//
//  PSUserFeedVC.m
//  PartySmash
//
//  Created by Makar Stetsenko on 16.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Crashlytics/Crashlytics.h>
#import "PSUserFeedVC.h"
#import "PSLoginViewController.h"
#import "PSUser.h"
#import "PSAuthService.h"
#import "PSEventNewPartyCell.h"
#import "PSParty.h"
#import "PSParty.h"
#import "PSEventCell.h"
#import "PSEvent.h"
#import "PSPartyViewController.h"
#import "PSAttributedDrawer.h"
#import "PSNotification.h"
#import "PSNotificationFollowCell.h"
#import "PSAppDelegate.h"
#import "PSCreatePartyVC.h"
#import "PSImageView.h"

static NSString *GA_SCREEN_NAME = @"User Feed";

@interface PSUserFeedVC () {
    
}

@property (nonatomic) NSMutableArray *atribitedStrings;
@property (nonatomic) NSMutableDictionary *offscreenCells;

@end

static NSString *event_cell_id = @"event_cell_id";

@implementation PSUserFeedVC {
    int _selectedRow;
    BOOL _redirected;
    BOOL _selfSizingCellEnabled;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"feed_S"];

        self.parseClassName = @"Event";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;

        self.offscreenCells = [NSMutableDictionary new];
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

    [self.tableView registerClass:[PSEventCell class] forCellReuseIdentifier:event_cell_id];

    // Use brand new self-sizing cells
    if ([(PSAppDelegate *)[[UIApplication sharedApplication] delegate] isUserRunningIOS8]) {
        _selfSizingCellEnabled = YES;
        self.tableView.estimatedRowHeight = 87;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![PSAuthService isUserLoggedIn]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginViewController = [sb instantiateViewControllerWithIdentifier:@"logInNavController"];
        [self presentViewController:loginViewController animated:YES completion:^{
            _redirected = YES;
//            [self loadObjects];
        }];
    }

    if (_redirected) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self loadObjects];
        _redirected = NO;
    }

    NSLog(@"%s", sel_getName(_cmd));
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [((PSAppDelegate *)[[UIApplication sharedApplication] delegate]) trackScreen:GA_SCREEN_NAME];
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

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    if (self.objects.count == 0) {
//        // Display a message when the table is empty
//        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//
//        messageLabel.text = @"Тут будут события пользователей, на которых вы подписаны";
//        messageLabel.textColor = [UIColor blackColor];
//        messageLabel.numberOfLines = 0;
//        messageLabel.textAlignment = NSTextAlignmentCenter;
////        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
//        [messageLabel sizeToFit];
//
//        self.tableView.backgroundView = messageLabel;
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    }

    return 1;

}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
//    [self setRecompute:NO];
    PSEvent *event = object;

    PSEventCell *cell = [tableView dequeueReusableCellWithIdentifier:event_cell_id forIndexPath:indexPath];

    // Configure the cell for this indexPath
//    cell.body.attributedString = [event getEventTextBody];
    cell.body.attributedText = [event getEventTextBody];

    PFFile *userImg = event.owner.photo100;
//    cell.imageView.image = [UIImage imageNamed:@"feed_S"];
//    cell.imageView.file = userImg;
//    cell.imageView.file = event.owner.photo100;
    cell.userPic.file = event.owner.photo100;
    [cell.userPic loadInBackground];

    // [cell updateFonts];

    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
//    if (!_selfSizingCellEnabled) {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
//    }

//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selfSizingCellEnabled) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    NSLog(@"%s", sel_getName(_cmd));
    // This project has only one cell identifier, but if you are have more than one, this is the time
    // to figure out which reuse identifier should be used for the cell at this index path.
    NSString *reuseIdentifier = event_cell_id;

    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    PSEventCell *cell = (self.offscreenCells)[reuseIdentifier];
    if (!cell) {
//        cell = (PSEventCell *)[[NSBundle mainBundle] loadNibNamed:@"event_friendgoes_tablecell" owner:self options:nil][0];//[[PSEventCell alloc] init];
        cell = [PSEventCell new];
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        (self.offscreenCells)[reuseIdentifier] = cell;
    }

    // Configure the cell for this indexPath
    // [cell updateFonts];
    PSEvent *event = [self objectAtIndexPath:indexPath];
//    cell.body.attributedString = [event getEventTextBody];
    cell.body.attributedText = [event getEventTextBody];

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
    NSLog(@"height = %f", height);

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    _selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"partyScreenSegueId" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"partyScreenSegueId"]) {
        PSPartyViewController *destVC = segue.destinationViewController;
        PSEvent *event = [self objectAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];

        destVC.party = event.party;
    } else if ([segue.identifier isEqualToString:@"CreatePartySegue"]) {
        PSCreatePartyVC *vc = [(UINavigationController *)(segue.destinationViewController) topViewController];
        vc.createDelegate = self;
    }
}

#pragma mark - Getters & Setters

- (NSMutableArray *)atribitedStrings {
    if (!_atribitedStrings) {
        _atribitedStrings = [NSMutableArray new];
    }
    return _atribitedStrings;
}

- (void)didCreateParty:(PSParty *)party {
    NSLog(@"%s", sel_getName(_cmd));
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyViewController *partyVC = [sb instantiateViewControllerWithIdentifier:@"party_vc"];
    partyVC.party = party;

    NSLog(@"self.presentingViewController = %@", self.presentingViewController);

    [self.navigationController pushViewController:partyVC animated:YES];
}


@end
