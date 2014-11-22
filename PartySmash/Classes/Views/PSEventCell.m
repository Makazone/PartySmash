#import "PSEventCell.h"
#import "PSAttributedDrawer.h"

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
        self.body = [PSAttributedDrawer new];
        self.body.translatesAutoresizingMaskIntoConstraints = NO;

        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.body];

        // Optimization tricks
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.body.backgroundColor = [UIColor whiteColor];
        self.imageView.backgroundColor = [UIColor whiteColor];

//        [self updateFonts];
    }

    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
       NSDictionary *viewsDictionary = @{@"userPic" : self.imageView, @"body" : self.body};

        // Note: if the constraints you add below require a larger cell size than the current size (which is likely to be the default size {320, 44}), you'll get an exception.
        // As a fix, you can temporarily increase the size of the cell's contentView so that this does not occur using code similar to the line below.
        // See here for further discussion: https://github.com/Alex311/TableCellWithAutoLayout/commit/bde387b27e33605eeac3465475d2f2ff9775f163#commitcomment-4633188
//        self.contentView.bounds = CGRectMake(0.0f, 0.0f, 99999.0f, 99999.0f);

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[userPic(60)]-10-[body]-10-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[userPic(60)]->=8-|" options:0 metrics:nil views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[body]->=8-|" options:0 metrics:nil views:viewsDictionary]];
//        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//        }];
//        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
//        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
//        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];

        // This is the constraint that connects the title and body labels. It is a "greater than or equal" inequality so that if the row height is
        // slightly larger than what is actually required to fit the cell's subviews, the extra space will go here. (This is the case on iOS 7
        // where the cell separator is only 0.5 points tall, but in the tableView:heightForRowAtIndexPath: method of the view controller, we add
        // a full 1.0 point in extra height to account for it, which results in 0.5 points extra space in the cell.)
        // See https://github.com/smileyborg/TableViewCellWithAutoLayout/issues/3 for more info.
//        [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
//
//        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
//            [self.bodyLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
//        }];
//        [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
//        [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
//        [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];

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
}

- (void)updateFonts
{
//    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//    self.bodyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

@end
