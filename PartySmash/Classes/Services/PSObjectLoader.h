//
// Created by Makar Stetsenko on 04.01.15.
// Copyright (c) 2015 PartySmash. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSObjectLoader : NSObject

@property (nonatomic) int pageSize;

- (instancetype)initWithQuery:(PFQuery *)query;

- (void)loadPageInBackground:(void (^)(NSArray *, NSError *))callback;

@end