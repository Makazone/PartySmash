//
//  PSPartyListCell.m
//  PartySmash
//
//  Created by Makar Stetsenko on 13.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSPartyListCell.h"
#import "PSAttributedDrawer.h"
#import "PSImageView.h"

@implementation PSPartyListCell {
    BOOL _didSetupConstraints;
}

- (void)awakeFromNib {
    // Initialization code
}

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

        // Optimization tricks
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.body.backgroundColor = [UIColor whiteColor];
        self.userPic.backgroundColor = [UIColor whiteColor];

//        [self updateFonts];
        _didSetupConstraints = NO;
    }

    return self;
}

- (void)updateConstraints {
    if (!_didSetupConstraints) {
        NSDictionary *viewsDictionary = @{@"userPic" : self.userPic, @"body" : self.body};

        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        // See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
//        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[userPic(50)]-10-[body]-8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[userPic(50)]->=8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[body]->=8-|" options:0 metrics:nil views:viewsDictionary]];

        _didSetupConstraints = YES;
    }

    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    self.body.preferredMaxLayoutWidth = CGRectGetWidth(self.body.frame);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
