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

@interface PSPartyViewController ()

@property (weak, nonatomic) IBOutlet UITextView *partyDescription;
@property (weak, nonatomic) IBOutlet PFImageView *creatorImg;
@property (weak, nonatomic) IBOutlet UILabel *creatorNic;
@property (weak, nonatomic) IBOutlet UILabel *partyDate;
@property (weak, nonatomic) IBOutlet UITextView *address;
@property (weak, nonatomic) IBOutlet UITextView *price;
@property (weak, nonatomic) IBOutlet UITextView *placesLeft;



@end

@implementation PSPartyViewController {
    NSDateFormatter *_dateFormatter;
    NSAttributedString *_placesLeftText;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLocale *locale = [NSLocale currentLocale];
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.locale = locale;
    _dateFormatter.dateFormat = @"d MMMM HH:mm";

    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, -30, 0);

    // Creator image
    PFFile *creatorImgFile = self.party.creator.photo100;
    self.creatorImg.file = creatorImgFile;
    self.creatorImg.layer.cornerRadius = 30.0f;
    self.creatorImg.clipsToBounds = YES;
    [self.creatorImg loadInBackground];

    // Creator nicname
    self.creatorNic.text = self.party.creator.username;

    // Party date
    self.partyDate.text = [_dateFormatter stringFromDate:self.party.date];

    [self.party getInfoAboutPeopleWhoGoWithCallback:^(NSDictionary *result, NSError *error) {
        int placesLeft = [result[PLACES_LEFT_INDX] intValue];
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
            self.placesLeft.attributedText = _placesLeftText;

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
                        NSForegroundColorAttributeName : [UIColor colorWithRed:129/255.0 green:28/255.0 blue:64/255.0 alpha:1.0]
                } range:[purePlacesLeft rangeOfString:friendsWhoGo[i]]];
            }

            self.placesLeft.attributedText = placesInfo;
            _placesLeftText = placesInfo;
        }

//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadData];
//        [self.tableView endUpdates];
    }];
}

- (void)viewWillLayoutSubviews {
    self.partyDescription.translatesAutoresizingMaskIntoConstraints = NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int sec = indexPath.section;
    if (sec == 0) {
        NSString *purePartyDescr = [NSString stringWithFormat:@"%@\n\n%@", self.party.name, self.party.generalDescription];
        NSMutableAttributedString *partyDescription = [[NSMutableAttributedString alloc] initWithString:purePartyDescr attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:18]
        }];
        NSRange r = [purePartyDescr rangeOfString:self.party.name];
        [partyDescription addAttributes:@{
                NSStrokeColorAttributeName : [UIColor blackColor],
                NSStrokeWidthAttributeName : @-2.0,
        } range:r];
        self.partyDescription.attributedText = partyDescription;

        int h = [partyDescription boundingRectWithSize:CGSizeMake(320, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        NSLog(@"r = %i", h);
        NSLog(@"r.height = %i", self.partyDescription.contentSize.height);
        return h+40;
    } else if (sec == 1) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    } else if (sec == 2) {
        NSMutableAttributedString *address = [[NSMutableAttributedString alloc] initWithString:self.party.address attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:17]
        }];
        self.address.attributedText = address;

        NSString *purePrice;
        if (self.party.price) {
            purePrice = self.party.price;
        } else purePrice = @"Бесплатно";
        NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:purePrice attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:17]
        }];
        self.price.attributedText = price;

        NSLog(@"self.address.contentSize.height = %f", self.address.contentSize.height);
        NSLog(@"self.price.contentSize.height = %f", self.price.contentSize.height);

        int addressHeight = [address boundingRectWithSize:CGSizeMake(234, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        int priceHeight   = [price boundingRectWithSize:CGSizeMake(234, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;

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
    if (indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4) {
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
    }
}


@end