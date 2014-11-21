//
// Created by Makar Stetsenko on 17.11.14.
// Copyright (c) 2014 PartySmash. All rights reserved.
//

#import "PSMyPartiesVC.h"

@interface PSMyPartiesVC () {
    
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic) UITableViewController *currentController;
@property (nonatomic) NSArray *controllers;

@end

@implementation PSMyPartiesVC {

}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"my_parties_S"];

//        self.parseClassName = @"Event";
//        self.pullToRefreshEnabled = YES;
//        self.paginationEnabled = YES;
//        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.segmentControl addTarget:self action:@selector(changeVC:) forControlEvents:UIControlEventValueChanged];


    self.currentController = self.childViewControllers[0]; // news controller
    UITableViewController *partiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FuturePartiesVC"]; // parties

    [self addChildViewController:partiesVC];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.controllers = @[self.currentController, partiesVC];
}

- (void) flipFromViewController:(UIViewController*) fromController
               toViewController:(UIViewController*) toController
                  withDirection:(UIViewAnimationOptions) direction
{
    toController.view.frame = fromController.view.frame;
    [self addChildViewController:toController];                                     //
    [fromController willMoveToParentViewController:nil];                            //

    [self transitionFromViewController:fromController
                      toViewController:toController
                              duration:0.1
                               options:direction | UIViewAnimationOptionCurveEaseIn
                            animations:nil
                            completion:^(BOOL finished) {

                                [toController didMoveToParentViewController:self];  //  2
                                [fromController removeFromParentViewController];    //  3
                            }];
}

- (void)changeVC:(id)sender {
    NSLog(@"Change to VC = %d", self.segmentControl.selectedSegmentIndex);

    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self flipFromViewController:self.controllers[1] toViewController:self.controllers[0] withDirection:UIViewAnimationCurveEaseIn];
    } else {
        [self flipFromViewController:self.controllers[0] toViewController:self.controllers[1] withDirection:UIViewAnimationCurveEaseIn];
    }
}

@end