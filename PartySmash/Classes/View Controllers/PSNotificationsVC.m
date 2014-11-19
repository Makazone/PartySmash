//
// Created by Makar Stetsenko on 29.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PSNotificationsVC.h"
#import "PSAuthService.h"
#import "PSInvitation.h"
#import "PSUser.h"
#import "PSInvitationCell.h"
#import "PSParty.h"
#import "PSPartyViewController.h"

static NSString *invitaion_ok_cellid = @"invitationokcellid";
static NSString *invitaion_requires_answer_cellid = @"invitation_requires_answer_cellid";
static NSString *invitaion_waits_approval = @"invitaion_waits_approval";
static NSString *party_cellid = @"party_cellid";

@implementation PSNotificationsVC {
    BOOL _firstLoad;
    NSMutableArray *_invitations;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%s", sel_getName(_cmd));
    [[self tableView] registerNib:[UINib nibWithNibName:@"invitation_ok_cell" bundle:nil] forCellReuseIdentifier:invitaion_ok_cellid];

    [[self tableView] registerNib:[UINib nibWithNibName:@"invitaion_requeres_answer_cell" bundle:nil] forCellReuseIdentifier:invitaion_requires_answer_cellid];
    [[self tableView] registerNib:[UINib nibWithNibName:@"invitation_waits_approval_cell" bundle:nil] forCellReuseIdentifier:invitaion_waits_approval];
//    [[self tableView] registerNib:[UINib nibWithNibName:@"event_friendgoes_tablecell" bundle:nil] forCellReuseIdentifier:friend_goestoparty_cellid];

    [self.refreshControl addTarget:self action:@selector(refreshContent:) forControlEvents:UIControlEventValueChanged];

    _firstLoad = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.refreshControl beginRefreshing];
    [self refreshContent:self];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _invitations.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_firstLoad) {
        UILabel *messageLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.backgroundColor = [UIColor redColor];

        self.tableView.backgroundView = messageLabel;
        self.tableView.backgroundView.layer.zPosition -= 1;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        _firstLoad = NO;
    } else {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSInvitation *invitation = [_invitations objectAtIndex:indexPath.row];
    [invitation removePartyFromDefaults];

    NSLog(@"indexPath = %d", indexPath.row);

    PSInvitationCell *cell;

    if (invitation.type == SEND_INVITATION_TYPE) {
        cell = [tableView dequeueReusableCellWithIdentifier:invitaion_requires_answer_cellid forIndexPath:indexPath];
    }
//    else if (invitation.type == ACCEPT_INVITATION_TYPE) {
//        cell = [tableView dequeueReusableCellWithIdentifier:invitaion_ok_cellid forIndexPath:indexPath];
//    } else if (invitation.type == DECLINE_INVITATION_TYPE) {
//        cell = [tableView dequeueReusableCellWithIdentifier:invitaion_ok_cellid forIndexPath:indexPath];
    else if (invitation.type == SEND_REQUEST_TYPE) {
        if ([invitation.recipient.objectId isEqualToString:[[PSUser currentUser] objectId]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:invitaion_requires_answer_cellid forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:invitaion_waits_approval forIndexPath:indexPath];
        }
    } else if (invitation.type == ACCEPT_REQUEST_TYPE || invitation.type == DECLINE_REQUEST_TYPE || invitation.type == SEND_RECOMMENDATION_TYPE || invitation.type == ACCEPT_INVITATION_TYPE || invitation.type == DECLINE_INVITATION_TYPE || invitation.type == STARTED_FOLLOWING) {
        cell = [tableView dequeueReusableCellWithIdentifier:invitaion_ok_cellid forIndexPath:indexPath];
    }

    cell.delegate = self;
    cell.cellIndexPath = indexPath;

//    else if (invitation.type == DECLINE_REQUEST_TYPE) {
//
//        cell = [tableView dequeueReusableCellWithIdentifier:invitaion_ok_cellid forIndexPath:indexPath];
//    } else if (invitation.type == SEND_RECOMMENDATION_TYPE) {
//        cell = [tableView dequeueReusableCellWithIdentifier:invitaion_ok_cellid forIndexPath:indexPath];
//    }

    cell.body.attributedText = [invitation getBody];

    cell.userPic.layer.cornerRadius = 30.0f;
    cell.userPic.clipsToBounds = YES;

    if (invitation.type == SEND_REQUEST_TYPE && ![invitation.recipient.objectId isEqualToString:[[PSUser currentUser] objectId]]) {
        cell.userPic.file = [[invitation recipient] photo100];
    } else {
        cell.userPic.file = [[invitation sender] photo100];
    }

    [cell.userPic loadInBackground];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PSInvitation *invitation = [_invitations objectAtIndex:indexPath.row];

        CGRect r = [[invitation getBody] boundingRectWithSize:CGSizeMake(236, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (invitation.type == SEND_REQUEST_TYPE && [invitation.sender.objectId isEqualToString:[PSUser currentUser].objectId]) {
            return MAX(ceil(r.size.height) + 10, 75);
        }
        return MAX(ceil(r.size.height) + 40, 113);
    } else return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)okButtonClicked:(id)sender {
    UITableViewCell *cell = sender;
    int row = [self.tableView indexPathForCell:cell].row;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PSPartyViewController *partyVC = [sb instantiateViewControllerWithIdentifier:@"party_vc"];
        partyVC.party = [(PSInvitation *) [_invitations objectAtIndex:indexPath.row] party];

        [self.navigationController pushViewController:partyVC animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


// Actually did click on button in cell at indexpath
- (void)didClickOnCellAtIndexPath:(NSIndexPath *)cellIndex withData:(id)data {
    if (cellIndex.section != 0) { return; }

    PSInvitationCell *cell = (NSArray*)data[0];
    int code = [((NSArray *)data)[1] intValue];

    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    PSInvitation *invitation = [_invitations objectAtIndex:path.row];

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

- (void)refreshContent:(id)sender {
    [PSInvitation loadInvitationsInBackgroundWithCompletion:^(NSArray *invitations, NSError *error) {
        if (!error) {
            NSLog(@"invitations = %d", invitations.count);
            _invitations = [[NSMutableArray alloc] initWithArray:invitations];
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        } else {
            NSLog(@"ERROR");
            NSLog(@"error = %@", error);
        }
    }];
}

@end