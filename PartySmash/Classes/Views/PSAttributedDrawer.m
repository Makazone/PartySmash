//
// Created by Makar Stetsenko on 21.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSAttributedDrawer.h"


@implementation PSAttributedDrawer {
}

- (CGSize)intrinsicContentSize {
    CGRect boundingRect = [self.attributedString boundingRectWithSize:CGSizeMake(_preferredMaxLayoutWidth, CGFLOAT_MAX)
                                 options:(NSStringDrawingUsesLineFragmentOrigin)
                                 context:nil];
    CGSize ceiledSize = CGSizeMake(ceil(boundingRect.size.width), ceil(boundingRect.size.height));
    return ceiledSize;
}


- (void)drawRect:(CGRect)rect {
    [self.attributedString drawWithRect:rect options:NSStringDrawingUsesLineFragmentOrigin context:nil];
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    _attributedString = attributedString;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}

@end