//
// Created by Makar Stetsenko on 04.01.15.
// Copyright (c) 2015 PartySmash. All rights reserved.
//

#import <Parse/Parse.h>
#import "PSObjectLoader.h"

@interface PSObjectLoader () {

}

@property (nonatomic) PFQuery *query;

@end

@implementation PSObjectLoader {
    int _pages;
}

- (instancetype)initWithQuery:(PFQuery *)query {
    self = [super init];
    if (self) {
        self.query = query;
        self.pageSize = -1;
        _pages = 0;
    }

    return self;
}

- (void)loadPageInBackground:(void (^)(NSArray *, NSError *))callback {
    if (self.pageSize != -1)
        [self alterQuery];

    [self.query findObjectsInBackgroundWithBlock:callback];
}

- (void)alterQuery {
    self.query.limit = self.pageSize;
    self.query.skip = _pages * self.pageSize;
}

@end