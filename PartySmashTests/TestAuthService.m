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
//    [Parse setApplicationId:@"j7Diayt7cMfsYNx2woz0KEHfUokWmFVTbqDKSJvV" clientKey:@"B2oauCoxucOBBTr597VwIXWtxXG9kv0scigBHfOc"];
//
//    PFUser *user = [PFUser user];
//    user.username = @"TestUserIOS";
//    user.password = @"123";
//
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            NSLog(@"yes");
//            // Hooray! Let them use the app now.
//        } else {
//            NSString *errorString = [error userInfo][@"error"];
//            NSLog(@"errorString = %@", errorString);
//            // Show the errorString somewhere and let the user try again.
//        }
//    }];
//
//    PSAuthService *authService = [PSAuthService new];
//    XCTAssertTrue([authService isUserLoggedIn], "Should be able to check if current user is logged in");
}


- (void)testCanLogInUser {
//    PSAuthService *authService = [PSAuthService new];
//    [authService loginVK:<#(id <VKSdkDelegate> *)delegate#>];
//
//    XCTAssertTrue([VKSdk isLoggedIn], "Authentication service should be able to log in user");
}

- (void)testCanCreateNewUser {
    NSError *error;
    //BOOL result = [PSAuthService signUpVKUser:@"1" withNickname:@"makazone" avatar100:nil avatar200:nil error:&error];

    //XCTAssertTrue(result, @"Should be able to create new user");

}


@end
