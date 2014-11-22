//
//  PSPartyListCell.m
//  PartySmash
//
//  Created by Makar Stetsenko on 13.11.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSPartyListCell.h"
#import "PSAttributedDrawer.h"

@implementation PSPartyListCell {
    BOOL _didSetupConstraints;
}

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.body = [PSAttributedDrawer new];
        self.body.translatesAutoresizingMaskIntoConstraints = NO;

        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.body];

        // Optimization tricks
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.body.backgroundColor = [UIColor whiteColor];
        self.imageView.backgroundColor = [UIColor whiteColor];

//        [self updateFonts];
        _didSetupConstraints = NO;
    }

    return self;
}

- (void)updateConstraints {
    if (!_didSetupConstraints) {
        NSDictionary *viewsDictionary = @{@"userPic" : self.imageView, @"body" : self.body};

        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        // See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
//        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[userPic(50)]-10-[body]-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[userPic(50)]->=8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[body]->=8-|" options:0 metrics:nil views:viewsDictionary]];

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
