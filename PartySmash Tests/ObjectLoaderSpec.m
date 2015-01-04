//
//  ObjectLoaderSpec.m
//  PartySmash
//
//  Created by Makar Stetsenko on 04.01.15.
//  Copyright 2015 PartySmash. All rights reserved.
//

#define EXP_SHORTHAND

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <Parse/Parse.h>
#import "Expecta.h"

#import "Specta.h"
#import "PSObjectLoader.h"

SpecBegin(PSObjectLoader)

describe(@"PSObjectLoader", ^{
    __block PSObjectLoader *loader;

    beforeAll(^{
        [Parse setApplicationId:@"Y0QJXabDuBwvcLhyG427MB6u35WTxXlr9Yao6bY0" clientKey:@"SvrJ7uUQw9XWNraxc3xpq5TSgRzDjgm6M9NOU1i8"];
    });
    
    beforeEach(^{
    });

    describe(@"no page size set", ^{
        it(@"should load all objects", ^{
            PFQuery *query = [[PFQuery alloc] initWithClassName:@"Party"];

            PSObjectLoader *loader = [[PSObjectLoader alloc] initWithQuery:query];

            waitUntil(^(DoneCallback done) {
                [loader loadPageInBackground:^(NSArray *result, NSError *error){
                    expect(result.count).to.equal(61);
                    done();
                }];
            });
        });
    });

    describe(@"page size is set", ^{
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"Party"];

        context(@"when page size is <= to the total number of objects", ^{
            it(@"shouldn't load more objects than page size", ^{
                PSObjectLoader *loader = [[PSObjectLoader alloc] initWithQuery:query];
                loader.pageSize = 10;

                waitUntil(^(DoneCallback done) {
                    [loader loadPageInBackground:^(NSArray *result, NSError *error){
                        expect(result.count).to.equal(10);
                        done();
                    }];
                });
            });

            it(@"should skip previous pages", ^{

            });
        });

        context(@"when page size is > than the total number of objects", ^{
            it(@"should load all objects", ^{
                PSObjectLoader *loader = [[PSObjectLoader alloc] initWithQuery:query];
                loader.pageSize = 100;

                waitUntil(^(DoneCallback done) {
                    [loader loadPageInBackground:^(NSArray *result, NSError *error){
                        expect(result.count).to.equal(61);
                        done();
                    }];
                });
            });
        });
    });

    afterEach(^{
    });
    
    afterAll(^{

    });
});

SpecEnd
