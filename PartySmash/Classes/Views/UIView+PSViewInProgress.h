//
// Created by Makar Stetsenko on 17.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (PSViewInProgress)

- (void)showIndicatorWithCornerRadius:(int)radius;
- (void)showIndicatorWithDimColor:(UIColor *)dimColor indicatorColor:(UIView *)indicatorColor cornerRadius:(int)radius;

- (void)removeIndicator;

@end