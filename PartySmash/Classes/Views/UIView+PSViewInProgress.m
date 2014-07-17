//
// Created by Makar Stetsenko on 17.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "UIView+PSViewInProgress.h"

@interface UIView (PSViewInProgress)

@end;

@implementation UIView (PSViewInProgress)

- (void)showIndicatorWithCornerRadius:(int)radius {
    // default colors
    UIColor *dimColor = [UIColor colorWithRed:181/255.0 green:184/255.0 blue:188/255.0 alpha:0.8];
    UIColor *indicatorColor = [UIColor colorWithRed:94/255.0 green:44/255.0 blue:93/255.0 alpha:1];

    [self showIndicatorWithDimColor:dimColor indicatorColor:indicatorColor cornerRadius:radius];
}

- (void)showIndicatorWithDimColor:(UIColor *)dimColor indicatorColor:(UIView *)indicatorColor cornerRadius:(int)radius {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    indicatorView.color = indicatorColor;
    indicatorView.frame = self.bounds;
    indicatorView.backgroundColor = dimColor;
    indicatorView.layer.cornerRadius = radius;

    [self addSubview:indicatorView];

//    UIView *dimView = [[UIView alloc] initWithFrame:self.bounds];
//    dimView.backgroundColor = dimColor;
//    dimView.layer.cornerRadius = radius;
//
//    indicatorView.frame = dimView.bounds;
//    [dimView addSubview:indicatorView];

    [indicatorView startAnimating];
}

- (void)removeIndicator {
    NSArray *subviews = self.subviews;
    for (UIView *s in subviews) {
        if ([s isKindOfClass:[UIActivityIndicatorView class]]) {
            NSLog(@"s = %@", s);
            [s removeFromSuperview];
            break;
        }
    }
//    if (_dimView && _indicatorView) {
//        [_dimView removeFromSuperview];
//    } else { NSLog(@"Trying to stop indicator on with (dimV %@, ind %@)", _dimView, _indicatorView); }
}


@end