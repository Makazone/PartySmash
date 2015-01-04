//
//  UserFeedControllerSpec.m
//  PartySmash
//
//  Created by Makar Stetsenko on 04.01.15.
//  Copyright 2015 PartySmash. All rights reserved.
//

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import "Specta.h"
#import "PSUserFeedVC.h"


SpecBegin(PSUserFeedVC)

describe(@"PSUserFeedVC", ^{
    UIStoryboard *st = [UIStoryboard storyboardWithName:[NSBundle mainBundle].infoDictionary[@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    __block PSUserFeedVC *feedController;
    
    beforeAll(^{

    });
    
    beforeEach(^{
        feedController = [st instantiateViewControllerWithIdentifier:@"PSUserFeedVC"];
    });

    context(@"when there is data to display", ^{
        pending(@"wait for object loader", ^{
            it(@"should load table view with rows", ^{
                expect([feedController.tableView numberOfRowsInSection:0]).to.equal(3);
            });
        });
    });

    afterEach(^{
        feedController = nil;
    });
    
    afterAll(^{

    });
});

SpecEnd
