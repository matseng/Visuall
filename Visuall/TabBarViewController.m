//
//  TabBarViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "TabBarViewController.h"
#import "ViewController.h"

@interface TabBarViewController () <UITabBarControllerDelegate>

@end

@implementation TabBarViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.delegate = self;  // NOTE: self.tabBarController.delegate = self; is redundant & wrong!!
    [self loadMyTabBarIcons];
}

- (void) __loadMyTabBarIcons
{
    UITabBar *tabBar = self.tabBar;
    
    UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:4];
    
    tabBarItem0.title = @"Global";
    tabBarItem1.title = @"Favorites";
    tabBarItem2.title = @"My Visualls";
    tabBarItem3.title = @"Notifications";
    tabBarItem4.title = @"More";
    
    UIImage *globe = [UIImage imageNamed:@"Globe-50"];
    globe = [UIImage imageWithCGImage:globe.CGImage scale:2.2 orientation:globe.imageOrientation];
    [tabBarItem0 setImage:globe];
    
    UIImage *star = [UIImage imageNamed:@"Star-50"];
    star = [UIImage imageWithCGImage:star.CGImage scale:1.8 orientation:star.imageOrientation];
    [tabBarItem1 setImage:star];
    
    UIImage *lightBulb = [UIImage imageNamed:@"light-bulb"];
    lightBulb = [UIImage imageWithCGImage:lightBulb.CGImage scale:2.1 orientation:lightBulb.imageOrientation];
    [tabBarItem2 setImage:lightBulb];
    
    UIImage *alarmBell = [UIImage imageNamed:@"alarm-bell"];
    alarmBell = [UIImage imageWithCGImage:alarmBell.CGImage scale:2.6 orientation:alarmBell.imageOrientation];
    [tabBarItem3 setImage: alarmBell];
}

- (void) loadMyTabBarIcons
{
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ThisIsLimitLotsofTextHere"
//                                                                             style:UIBarButtonItemStylePlain
//                                                                            target:nil
//                                                                            action:nil];
    
//    UITabBarController *tabBarController = (UITabBarController *) self.tabBarController;
    UITabBar *tabBar = self.tabBar;
    
    UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:1];
    
    tabBarItem0.title = @"Global";
    tabBarItem1.title = @"My Visualls";
    
    UIImage *globe = [UIImage imageNamed:@"Globe-50"];
    globe = [UIImage imageWithCGImage:globe.CGImage scale:2.2 orientation:globe.imageOrientation];
    [tabBarItem0 setImage:globe];
    
    UIImage *lightBulb = [UIImage imageNamed:@"light-bulb"];
    lightBulb = [UIImage imageWithCGImage:lightBulb.CGImage scale:2.1 orientation:lightBulb.imageOrientation];
    [tabBarItem1 setImage:lightBulb];
    
    [self setSelectedIndex: 1];
//    ViewController *vc = self.viewControllers[1];
    
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


