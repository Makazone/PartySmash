//
//  TestAuthService.m
//  PartySmash
//
//  Created by Makar Stetsenko on 08.07.14.
//  Copyright (c) 2014 PartySmash. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import "PSAuthService.h"
#import "VKSdk.h"

@interface TestAuthService : XCTestCase



@end

@implementation TestAuthService

+ (void)initialize {
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsUserLoggedIn {
    PFUser *user = [PFUser user];
    user.username = @"TestUserIOS";
    user.password = @"123";

    NSError *error;
    [user signUp:&error];

    XCTAssertTrue([PSAuthService isUserLoggedIn], "Should be able to check if current user is logged in");

    [user delete];
}


- (void)testCanLogInUser {
}

- (void)testCanCreateNewUser {
    [PSAuthService signUpVKUser:@1 withNickname:@"TestUser_iOS" avatar100:nil avatar200:nil completionHandler:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue(succeeded && error == nil, @"Should be able to create new user");
    }];
}


@end
