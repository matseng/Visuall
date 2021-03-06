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

- (void) viewWillAppear:(BOOL)animated
{
//    ViewController *visuallViewController = [self.viewControllers firstObject];
//    visuallViewController.firebaseVisuallKeyToLoad = @"global";
    ViewController *destViewController = [[ViewController alloc] init];
    destViewController.firebaseURL = @"global";
//    [self.navigationController pushViewController: destViewController animated:YES];
    [self pushViewController: destViewController animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    ViewController *visuallViewController = [self.viewControllers firstObject];
//    visuallViewController.firebaseVisuallKeyToLoad = @"global";


}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController.viewControllers indexOfObject:viewController] == tabBarController.selectedIndex
        && tabBarController.selectedIndex == 0)
    {
        return NO; // Prevent Public / Global tab from going back to a blank screen
    }
    else
    {
        return YES;
    }
}




@end
