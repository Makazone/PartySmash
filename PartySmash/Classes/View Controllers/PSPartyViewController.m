//
// Created by Makar Stetsenko on 01.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "PSPartyViewController.h"
#import "PSParty.h"
#import "PSUser.h"
#import "PSProfileVC.h"
#import "FBDialog.h"
#import "PSPartyCell.h"
#import "UIView+PSViewInProgress.h"
#import "PSTableUsersVC.h"

static NSDateFormatter *_dateFormatter;

@interface PSPartyViewController ()

enum UserStatus {GOES, WAITS, CREATOR, NEW, NONE};

@end

@implementation PSPartyViewController {
    NSAttributedString *_placesLeftText;
    NSAttributedString *_generalDescText;
    NSAttributedString *_addressText;
    NSAttributedString *_priceText;

    enum UserStatus _status;

    BOOL _partyExpired;

    UIButton *_actionButton1;
    UIButton *_actionButton2;

    int _placesLeft;
}

+ (void)initialize {
    NSLocale *locale = [NSLocale currentLocale];
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.locale = locale;
    _dateFormatter.dateFormat = @"d MMMM HH:mm";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, -30, 0);

    _status = NONE;

    NSTimeInterval sinceCreation = [self.party.date timeIntervalSinceNow];
    _partyExpired = sinceCreation <= 0;

    if (_partyExpired) {
        _placesLeftText = [[NSAttributedString alloc] initWithString:@"Вечеринка прошла. Посмотрите кто был." attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    }

    if ([self.party.creator.objectId isEqualToString:[[PSUser currentUser] objectId]]) {
        _status = CREATOR;
    }

    if (!_partyExpired) {
        [self.party getInfoAboutPeopleWhoGoWithCallback:^(NSDictionary *result, NSError *error) {
            int placesLeft = [result[PLACES_LEFT_INDX] intValue];
            _placesLeft = placesLeft;
            int alsoGo = [result[PEOPLE_WHO_ALSO_GO_INDX] intValue];

            NSArray *friendsWhoGo = result[FRIENDS_WHO_GO_INDX];
            if ([friendsWhoGo count] == 0) {
                NSString *purePlacesLeft;
                if (alsoGo == 0) {
                    if (placesLeft == -1) {
                        purePlacesLeft = @"Пока никто не идет, стань первым гостем!";
                    } else {
                        purePlacesLeft = [NSString stringWithFormat:@"Есть %d приглашений. Стань первым гостем на этой вечеринке!", placesLeft];
                    }
                } else {
                    if (placesLeft == -1) {
                        purePlacesLeft = [NSString stringWithFormat:@"На эту вечеринку идут %d человек, ограничений на количество приглашенных нет", alsoGo];
                    } else {
                        purePlacesLeft = [NSString stringWithFormat:@"На эту вечеринку идут %d человек, всего осталось %d приглашений", alsoGo, placesLeft];
                    }
                }

                _placesLeftText = [[NSAttributedString alloc] initWithString:purePlacesLeft attributes:@{
                        NSFontAttributeName : [UIFont systemFontOfSize:17]
                }];

            } else {
                NSMutableString *purePlacesLeft = [NSMutableString new];
                NSMutableAttributedString *placesInfo;

                if (placesLeft == -1) {
                    [purePlacesLeft appendString:@"Ограничений на количество приглашенных нет. "];
                } else {
                    [purePlacesLeft appendString:[NSString stringWithFormat:@"Осталось %d приглашений. ", placesLeft]];
                }

                if ([friendsWhoGo count] == 1) {
                    if (alsoGo == 0) {
                        [purePlacesLeft appendString:[NSString stringWithFormat:@"%@ идет на эту вечеринку", friendsWhoGo[0]]];
                    } else {
                        [purePlacesLeft appendString:[NSString stringWithFormat:@"%@ и %d других идyт на эту вечеринку", friendsWhoGo[0], alsoGo]];
                    }
                } else {
                    if (alsoGo == 0) {
                        [purePlacesLeft appendString:[NSString stringWithFormat:@"%@ и %@ идут на эту вечеринку", friendsWhoGo[0], friendsWhoGo[1]]];
                    } else {
                        [purePlacesLeft appendString:[NSString stringWithFormat:@"%@, %@ и %d других идyт на эту вечеринку", friendsWhoGo[0], friendsWhoGo[1], alsoGo]];
                    }
                }

                placesInfo = [[NSMutableAttributedString alloc] initWithString:purePlacesLeft attributes:@{
                        NSFontAttributeName : [UIFont systemFontOfSize:17]
                }];

                for (int i = 0; i < friendsWhoGo.count; i++) {
                    [placesInfo addAttributes:@{
                            NSForegroundColorAttributeName : [UIColor colorWithRed:129 / 255.0 green:28 / 255.0 blue:64 / 255.0 alpha:1.0]
                    }                   range:[purePlacesLeft rangeOfString:friendsWhoGo[i]]];
                }

                _placesLeftText = placesInfo;
            }

            NSArray *numberOfActions = @[[NSIndexPath indexPathForRow:0 inSection:4], [NSIndexPath indexPathForRow:1 inSection:4]];

            if (_status == CREATOR) { }
            else if ([[PSUser currentUser] checkIfRequestedInviteForParty:self.party.objectId]) {
                _status = WAITS;
                numberOfActions = [NSArray arrayWithObject:numberOfActions[0]];
            } else if ([result[IS_USER_GOING] boolValue]) {
                _status = GOES;
            } else {
                numberOfActions = [NSArray arrayWithObject:numberOfActions[0]];
                _status = NEW;
            }

            NSLog(@"_status = %d", _status);

            [self.tableView beginUpdates];

            if (_status != CREATOR) [self.tableView insertRowsAtIndexPaths:numberOfActions withRowAnimation:UITableViewRowAnimationNone];

            NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 1)];
            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];

            [self.tableView endUpdates];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_partyExpired) { return 4; }
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < 4) { return 1; }
    if (_status == CREATOR || _status == GOES) {
        return 2;
    }
    if (_status == NONE) {
        return 0;
    }
    if (_status == NEW || _status == WAITS) {
        return 1;
    } else return -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = indexPath.section;

    PSPartyCell *cell;
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"party_header_cell" forIndexPath:indexPath];
        cell.headerText.attributedText = _generalDescText;
    } else if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"party_creator_cell" forIndexPath:indexPath];

        PFFile *creatorImgFile = self.party.creator.photo100;
        cell.creatorImg.file = creatorImgFile;
        cell.creatorImg.layer.cornerRadius = 30.0f;
        cell.creatorImg.clipsToBounds = YES;
        [cell.creatorImg loadInBackground];

        // Creator nicname
        cell.creatorNic.text = self.party.creator.username;
    } else if (section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"party_general_info_cell" forIndexPath:indexPath];

        // Party date
        cell.partyDate.text = [_dateFormatter stringFromDate:self.party.date];

        cell.address.attributedText = _addressText;
        cell.price.attributedText = _priceText;
    } else if (section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"party_places_left_cell" forIndexPath:indexPath];

        if (_placesLeftText) {
            cell.placesLeft.attributedText = _placesLeftText;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"party_actions_cell" forIndexPath:indexPath];
        [cell.actionButton setTitleColor:cell.actionButton.tintColor forState:UIControlStateNormal];
        [cell.actionButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];

        SEL action;
        NSString *actionTitle;
        if (_status == NEW) {
            if (self.party.isPrivate) {
                actionTitle = @"Попросить приглашение";
                action = @selector(actionRequestInvite:);
            } else {
                actionTitle = @"Хочу пойти!";
                action = @selector(actionBecomeInvited:);
            }
            _actionButton1 = cell.actionButton;
        } else if (_status == CREATOR) {
            if (indexPath.row == 1) {
                actionTitle = @"Удалить вечеринку";
                action = @selector(actionDeleteParty:);
                [cell.actionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                _actionButton2 = cell.actionButton;
            } else {
                actionTitle = @"Пригласить друзей";
                action = @selector(actionSendInvited:);
                _actionButton1 = cell.actionButton;
            }
        } else if (_status == GOES) {
            if (indexPath.row == 0) {
                actionTitle = @"Предложить друзьям";
                action = @selector(actionSendRecommendation:);
                _actionButton1 = cell.actionButton;
            } else {
                actionTitle = @"Я не cмогу пойти :(";
                action = @selector(actionLeave:);
                [cell.actionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                _actionButton2 = cell.actionButton;
            }
        } else if (_status == WAITS) {
            actionTitle = @"Приглашение запрошено";
            [cell.actionButton setEnabled:NO];
            [cell.actionButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }

        [cell.actionButton setTitle:actionTitle forState:UIControlStateNormal];
        [cell.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int sec = indexPath.section;
    if (sec == 0) {
        NSString *purePartyDescr = [NSString stringWithFormat:@"%@\n\n%@", self.party.name, self.party.generalDescription];
        NSLog(@"purePartyDescr = %@", purePartyDescr);

        NSMutableAttributedString *partyDescription = [[NSMutableAttributedString alloc] initWithString:purePartyDescr attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:18]
        }];
        NSRange r = [purePartyDescr rangeOfString:self.party.name];
        [partyDescription addAttributes:@{
                NSStrokeColorAttributeName : [UIColor blackColor],
                NSStrokeWidthAttributeName : @-2.0,
        } range:r];
        _generalDescText = partyDescription;

        int h = [partyDescription boundingRectWithSize:CGSizeMake(295, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        NSLog(@"r = %i", h);
        return h+40;
    } else if (sec == 1) {
        return 70;
    } else if (sec == 2) {
        NSMutableAttributedString *address = [[NSMutableAttributedString alloc] initWithString:self.party.address attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:17]
        }];
        _addressText = address;

        NSString *purePrice;
        if (self.party.price && ![self.party.price isEqualToString:@"0"]) {
            purePrice = self.party.price;
        } else purePrice = @"Бесплатно";
        NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:purePrice attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:17]
        }];
        _priceText = price;

        int addressHeight = [address boundingRectWithSize:CGSizeMake(234, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        int priceHeight   = [price boundingRectWithSize:CGSizeMake(224, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;

        NSLog(@"addressHeight = %i", addressHeight);
        NSLog(@"priceHeight = %i", priceHeight);

        return addressHeight + priceHeight + 129;
    } else if (sec == 3) {
        if (!_placesLeftText) {
            return 60;
        }
        CGRect rPlacesLeft = [_placesLeftText boundingRectWithSize:CGSizeMake(270, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return rPlacesLeft.size.height + 35;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || indexPath.section == 3 || (indexPath.section == 4 && _status != WAITS)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PSProfileVC *userProfileVS = [sb instantiateViewControllerWithIdentifier:@"userProfileVC"];
        userProfileVS.user = self.party.creator;

        [self.navigationController pushViewController:userProfileVS animated:YES];
    } else if (indexPath.section == 3) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PSTableUsersVC *usersTableVC = [sb instantiateViewControllerWithIdentifier:@"userListVC"];
        usersTableVC.userQueryToDisplay = [self.party relationForKey:@"invited"].query;
        usersTableVC.needsFollow = YES;
        usersTableVC.screenTitle = @"Идут";

        [self.navigationController pushViewController:usersTableVC animated:YES];
    } else {
        PSPartyCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.actionButton.enabled) {
            [cell.actionButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

// For private party user need to request an invite
- (void)actionRequestInvite:(id)sender {
    [_actionButton1 showIndicatorWithCornerRadius:0];
    [self.party enrollWithCallback:^(NSError *error){
        [_actionButton1 removeIndicator];
        _status = WAITS;
        [_actionButton1 setTitle:@"Запрос отправлен, ждите ответа" forState:UIControlStateNormal];
        [_actionButton1 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_actionButton1 setEnabled:NO];
    }];
}

// For public party user can enroll immediately
- (void)actionBecomeInvited:(id)sender {
    UIButton *b = _actionButton1;
    [b showIndicatorWithCornerRadius:0];
    [self.party enrollWithCallback:^(NSError *error){
        [b removeIndicator];
        _status = GOES;

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];
}

// Creator can send invites
- (void)actionSendInvited:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [sb instantiateViewControllerWithIdentifier:@"userListVCNav"];
    PSTableUsersVC *usersTableVC = [nav topViewController];
    usersTableVC.sendsInvites = YES;
    usersTableVC.placesLeft = _placesLeft;
    usersTableVC.party = self.party;
    usersTableVC.screenTitle = @"Пригласить";

    [self presentViewController:nav animated:YES completion:nil];
}

// Creator can dismiss the party
- (void)actionDeleteParty:(id)sender {
    NSLog(@"%s", sel_getName(_cmd));

}

// Invited user can send recommendations
- (void)actionSendRecommendation:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [sb instantiateViewControllerWithIdentifier:@"userListVCNav"];
    PSTableUsersVC *usersTableVC = [nav topViewController];
    usersTableVC.sendsInvites = NO;
    usersTableVC.placesLeft = 5000000;
    usersTableVC.party = self.party;
    usersTableVC.screenTitle = @"Предложить";

    [self presentViewController:nav animated:YES completion:nil];
}

// Already invited user can quit
- (void)actionLeave:(id)sender {
    NSLog(@"%s", sel_getName(_cmd));
    [_actionButton2 showIndicatorWithCornerRadius:0];
    [self.party removeUserFromInvited:^(NSError *error) {
        [_actionButton2 removeIndicator];
        _status = NEW;

        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4], [NSIndexPath indexPathForRow:1 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];
}

@end