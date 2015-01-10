#import "PSEventCell.h"
#import "PSAttributedDrawer.h"
#import "PSImageView.h"

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        10.0f

@interface PSEventCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation PSEventCell {
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"%s", sel_getName(_cmd));
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.body = [UILabel new];
        self.body.translatesAutoresizingMaskIntoConstraints = NO;
        self.body.numberOfLines = 0;

        self.userPic = [PSImageView new];
        self.userPic.translatesAutoresizingMaskIntoConstraints = NO;

//        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.body];
        [self.contentView addSubview:self.userPic];

        // Optimization tricks
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.body.backgroundColor = [UIColor whiteColor];
//        self.imageView.backgroundColor = [UIColor whiteColor];
        self.userPic.backgroundColor = [UIColor whiteColor];

//        [self updateFonts];
    }

    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
       NSDictionary *viewsDictionary = @{@"userPic" : self.userPic, @"body" : self.body};

        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        // See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
//        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[userPic(60)]-10-[body]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[userPic(60)]->=8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[body]->=8-|" options:0 metrics:nil views:viewsDictionary]];

        self.didSetupConstraints = YES;
    }

    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    if ([[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."][0] intValue] >= 8) {
//        return;
//    }

//    [self.body sizeToFit];

    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];

    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.body.preferredMaxLayoutWidth = CGRectGetWidth(self.body.frame);
}

- (void)updateFonts
{
//    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//    self.bodyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

@end
