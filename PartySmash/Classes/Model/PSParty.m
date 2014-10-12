//
// Created by Makar Stetsenko on 30.07.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSParty.h"
#import "Parse/PFObject+Subclass.h";
#import "PSUser.h"

@interface PSParty () {

}

@end


@implementation PSParty {

}

@dynamic address;
@dynamic description;
@dynamic name;
@dynamic creator;
@dynamic capacity;
@dynamic price;
@dynamic isPrivate;
@dynamic date;

+ (NSString *)parseClassName {
    return @"Party";
}

@end