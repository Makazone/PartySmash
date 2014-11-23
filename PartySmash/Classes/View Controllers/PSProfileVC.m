//
// Created by Makar Stetsenko on 29.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "PSProfileVC.h"
#import "PSUser.h"
#import "UIView+PSViewInProgress.h"
#import "PSTableUsersVC.h"
#import "PSAppDelegate.h"
#import "PSPartyListVC.h"

static NSString *GA_SCREEN_NAME = @"User Profile";

@interface PSProfileVC () {
    
}

@property (weak, nonatomic) IBOutlet PFImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *userNic;

@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet UIButton *followers;
@property (weak, nonatomic) IBOutlet UIButton *following;
@property (weak, nonatomic) IBOutlet UIButton *visited;
@property (weak, nonatomic) IBOutlet UIButton *created;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *statButtons;

@end

@implementation PSProfileVC {
    BOOL _myProfile;
    BOOL _isFollowed;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"profile_S"];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.followButton.hidden = YES;

    if (!self.user || [self.user.objectId isEqualToString:[PSUser currentUser].objectId]) {
        self.user = [PSUser currentUser];
        _myProfile = YES;
    } else {
        _myProfile = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }

    for (int i=0; i < 4; i++) {
        UIButton *b = self.statButtons[i];
        b.layer.borderWidth = 1.0f;
        b.layer.borderColor = [[UIColor colorWithRed:129/255.0 green:28/255.0 blue:64/255.0 alpha:1.0] CGColor];
        b.layer.cornerRadius = 5.0f;

        b.titleLabel.numberOfLines = 2;
        b.titleLabel.textAlignment = NSTextAlignmentCenter;

        [b showIndicatorWithCornerRadius:5];
    }

    [self.user getProfileInformation:^(NSError *error, int followers, int following, int visited, int created, BOOL isFollowed){
        for (int i=0; i < 4; i++) {
            UIButton *b = self.statButtons[i];
            [b removeIndicator];
        }

        [self.followers setTitle:[NSString stringWithFormat:@"Подписчики\n%d", followers] forState:UIControlStateNormal];
        [self.following setTitle:[NSString stringWithFormat:@"Подписки\n%d", following] forState:UIControlStateNormal];
        [self.visited setTitle:[NSString stringWithFormat:@"Создал\n%d", created] forState:UIControlStateNormal];
        [self.created setTitle:[NSString stringWithFormat:@"Посетил\n%d", visited] forState:UIControlStateNormal];

        if (_myProfile) return;

        _isFollowed = isFollowed;

        if (isFollowed) {
            [self.followButton setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
        } else {
            [self.followButton setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
        }

        self.followButton.hidden = NO;
    }];

    self.userNic.text = self.user.username;

    self.userPic.file = self.user.photo200;
    [self.userPic loadInBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [(PSAppDelegate *)[UIApplication sharedApplication].delegate trackScreen:GA_SCREEN_NAME];
}


- (IBAction)followUser:(id)sender {
    [self.followButton showIndicatorWithCornerRadius:5];
    self.followButton.enabled = NO;
    if (_isFollowed) {
        [[PSUser currentUser] unfollowUser:self.user withCompletion:^(NSError *e){
            [self.followButton removeIndicator];
            [self.followButton setImage:[UIImage imageNamed:@"ic_follow"] forState:UIControlStateNormal];
            self.followButton.enabled = YES;
        }];
    } else {
        [[PSUser currentUser] followUser:self.user withCompletion:^(NSError *e){
            [self.followButton removeIndicator];
            [self.followButton setImage:[UIImage imageNamed:@"ic_unfollow"] forState:UIControlStateNormal];
            self.followButton.enabled = YES;
        }];
    }

    _isFollowed = !_isFollowed;
}

- (IBAction)showFollowers:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSTableUsersVC *usersTableVC = [sb instantiateViewControllerWithIdentifier:@"userListVC"];

    PFQuery *query = [PSUser query];
    [query whereKey:@"following" equalTo:self.user];
    usersTableVC.userQueryToDisplay = query;
    usersTableVC.needsFollow = YES;
    usersTableVC.screenTitle = @"Подписчики";
    usersTableVC.gaScreenName = @"Followers";

    [self.navigationController pushViewController:usersTableVC animated:YES];
}

- (IBAction)showFollowing:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSTableUsersVC *usersTableVC = [sb instantiateViewControllerWithIdentifier:@"userListVC"];
    usersTableVC.userQueryToDisplay = [self.user getFollowingRelation].query;
    usersTableVC.needsFollow = YES;
    usersTableVC.screenTitle = @"Подписки";
    usersTableVC.gaScreenName = @"Following";

    [self.navigationController pushViewController:usersTableVC animated:YES];
}

- (IBAction)showCreated:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyListVC *vc = [sb instantiateViewControllerWithIdentifier:@"partyListVC"];
    vc.shouldShowMyParties = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showVisited:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PSPartyListVC *vc = [sb instantiateViewControllerWithIdentifier:@"partyListVC"];
    vc.shouldShowMyParties = NO;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goToVkProfile:(id)sender {
    NSURL *vkURL = [NSURL URLWithString:[NSString stringWithFormat:@"vk://vk.com/id%@", self.user.vkId]];
    if ([[UIApplication sharedApplication] canOpenURL:vkURL]) {
        [[UIApplication sharedApplication] openURL:vkURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/id%@", self.user.vkId]]];
    }
}

@end