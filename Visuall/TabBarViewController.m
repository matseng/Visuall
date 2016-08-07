//
//  TabBarViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "TabBarViewController.h"
#import "StateUtil.h"

@interface TabBarViewController () <UITabBarControllerDelegate>

@end

@implementation TabBarViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.delegate = self;  // NOTE: self.tabBarController.delegate = self; is redundant & wrong!!
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"controller class: %@", NSStringFromClass([viewController class]));
    NSLog(@"controller title: %@", viewController.title);
    
    //    if (viewController == tabBarController.moreNavigationController)
    //    {
    //        tabBarController.moreNavigationController.delegate = self;
    //    }
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//
////    if (self.firebaseVisuallKeyToLoad)
//    if ( tabBarController.selectedIndex == 0)  // Global tab
//    {
//        [self.view setNeedsDisplay];  // resets the entire view and view controller
//    }
//}

@end


