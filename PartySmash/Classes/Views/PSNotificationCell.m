//
//  PSNotificationCell.m
//  PartySmash
//
//  Created by Makar Stetsenko on 04.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "PSNotificationCell.h"
#import "PSCellDelegate.h"
#import "PSAttributedDrawer.h"
#import "PSNotificationFollowCell.h"
#import "PSImageView.h"
#import "UIView+PSViewInProgress.h"

@interface PSNotificationCell () {
    BOOL _didSetupConstraints;
}

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation PSNotificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.imageView removeFromSuperview];

        self.body = [UILabel new];
        self.body.numberOfLines = 0;

        self.userPic = [PSImageView new];

        self.body.translatesAutoresizingMaskIntoConstraints = NO;
        self.userPic.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.body];
        [self.contentView addSubview:self.userPic];

        self.body.backgroundColor = [UIColor whiteColor];
        self.userPic.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];

        UITapGestureRecognizer *tapOnUserImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedOnUser)];
        self.userPic.userInteractionEnabled = YES;
        [self.userPic addGestureRecognizer:tapOnUserImg];
//        _didSetupConstraints = NO;
    }

    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        NSLog(@"%s", sel_getName(_cmd));
        NSDictionary *viewsDictionary = @{@"userPic" : self.userPic, @"body" : self.body};

        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        // See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
//        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);
//        self.contentView.layoutMargins = UIEdgeInsetsMake(0,42,0,42); // set left and right margins to 42


        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[userPic(40)]-10-[body]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[userPic(40)]" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[body]->=8-|" options:0 metrics:nil views:viewsDictionary]];

//        [self.body setContentCompressionResistancePriority:752 forAxis:UILayoutConstraintAxisVertical];

//        [self.contentView addConstraint:
//                [NSLayoutConstraint constraintWithItem:self.body
//                                             attribute:NSLayoutAttributeCenterY
//                                             relatedBy:NSLayoutRelationEqual
//                                                toItem:self.contentView
//                                             attribute:NSLayoutAttributeCenterY
//                                            multiplier:1.f constant:0.f]
//        ];

        [self.contentView addConstraint:
                [NSLayoutConstraint constraintWithItem:self.userPic
                                             attribute:NSLayoutAttributeCenterY
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.contentView
                                             attribute:NSLayoutAttributeCenterY
                                            multiplier:1.f constant:0.f]
        ];

        self.didSetupConstraints = YES;
    }

    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    [self.body sizeToFit];

    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.body.preferredMaxLayoutWidth = CGRectGetWidth(self.body.frame);
//    self.body.preferredMaxLayoutWidth = 252.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)pressedOnUser {
    [self.delegate didClickOnCellAtIndexPath:self.cellIndexPath withData:@(1)];
}

@end
