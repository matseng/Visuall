//
//  GlobalViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/5/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "GlobalViewController.h"
#import "ViewController.h"

@implementation GlobalViewController 

- (void)viewDidLoad
{
    self.tabBarController.delegate = self;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ViewController *visuallViewController = [self.viewControllers firstObject];
    visuallViewController.firebaseVisuallKeyToLoad = @"global";

}



@end