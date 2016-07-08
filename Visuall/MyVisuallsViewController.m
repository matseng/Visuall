//
//  MyVisuallsViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/5/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "MyVisuallsViewController.h"
#import "MyVisuallsDetailViewController.h"
#import "ViewController.h"
#import "UIImage+Extras.h"

@interface MyVisuallsViewController ()

@end

@implementation MyVisuallsViewController
{
    NSArray *recipes;
}

//@synthesize tabqqqqqleView;

- (void)viewDidLoad {
    [super viewDidLoad];
    recipes = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ThisIsLimitLotsofTextHere"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    
    UITabBarController *tabBarController = (UITabBarController *) self.tabBarController;
    UITabBar *tabBar = tabBarController.tabBar;
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
    
//    [tabBarItem1 setSelectedImage:[UIImage imageNamed:@"Star-50"]];

//    UIImage *globe = [[UIImage imageNamed:@"Globe-50"] imageByScalingAndCroppingForSize:CGSizeMake(30, 30)];
//    globe = [globe imageWithExtraPadding:.15];
//    UIImage *globe = [[UIImage imageNamed:@"Globe-50"] imageWithExtraPadding:.15];
//    globe = [globe imageByScalingAndCroppingForSize:CGSizeMake(30, 30)];
    UIImage *globe = [UIImage imageNamed:@"Globe-50"];
    globe = [UIImage imageWithCGImage:globe.CGImage scale:2.2 orientation:globe.imageOrientation];
    [tabBarItem0 setImage:globe];
    
    UIImage *star = [UIImage imageNamed:@"Star-50"];
    star = [UIImage imageWithCGImage:star.CGImage scale:1.8 orientation:star.imageOrientation];
    [tabBarItem1 setImage:star];
    
//    UIImage *lightBulb = [[UIImage imageNamed:@"light-bulb"] imageByScalingAndCroppingForSize:CGSizeMake(30, 30)];
    UIImage *lightBulb = [UIImage imageNamed:@"light-bulb"];
    lightBulb = [UIImage imageWithCGImage:lightBulb.CGImage scale:2.1 orientation:lightBulb.imageOrientation];
    [tabBarItem2 setImage:lightBulb];
    
//    UIImage *alarmBell = [[[UIImage imageNamed:@"alarm-bell"] imageByScalingAndCroppingForSize:CGSizeMake(30, 30)] imageWithExtraPadding:0.2f];
//    UIImage *alarmBell = [[UIImage imageNamed:@"alarm-bell"] imageWithExtraPadding:0.1];
//    alarmBell = [alarmBell imageByScalingAndCroppingForSize:CGSizeMake(30,30)];
    
    UIImage *alarmBell = [UIImage imageNamed:@"alarm-bell"];
    alarmBell = [UIImage imageWithCGImage:alarmBell.CGImage scale:2.6 orientation:alarmBell.imageOrientation];
//    alarmBell = [ alarmBell imageWithExtraPadding:0];
    [tabBarItem3 setImage: alarmBell];
    
    
//    self.navigationController.navigationBar.topItem.title = @"";
//    self.navigationItem.leftItemsSupplementBackButton = YES;
    
//    UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
////    UIImage *starImg = [self imageWithExtraPaddingFromImage:[UIImage imageNamed: @"Star-50"] percentPadding: .15];
//    UIImage *starImg = [UIImage imageNamed: @"Star-50"];
//    starImg = [starImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
////    UIImage *starImgHilighted = [self makeImageFromImage: starImg withBackgroundColor:self.view.tintColor andForegroundColor:backgroundColor];
//    UIImage *starImgHilighted = [UIImage imageNamed: @"Star-50"];
//    [starButton setImage:starImg forState:UIControlStateNormal];
//    [starButton setImage:starImgHilighted forState:UIControlStateHighlighted];
//    [starButton setTitle:@"star" forState:UIControlStateNormal];
//    starButton.frame = CGRectMake(0, 0, 42, 42);
//    starButton.layer.cornerRadius = 5;
//    starButton.tintColor = self.view.tintColor;
//    starButton.layer.borderWidth = 0;
//    starButton.layer.masksToBounds = YES;
//    [starButton.layer setBorderColor: [self.view.tintColor CGColor]];
//    UIBarButtonItem *starBarItem = [[UIBarButtonItem alloc]initWithCustomView:starButton];
//    
//    self.navigationItem.backBarButtonItem = starBarItem;


}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVisuallDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        MyVisuallsDetailViewController *destViewController = segue.destinationViewController;
        ViewController *destViewController = segue.destinationViewController;
        NSLog(@"prep fro Segue: %@", [recipes objectAtIndex:indexPath.row]);
//        destViewController.recipeName = [recipes objectAtIndex:indexPath.row];
        destViewController.firebaseURL = [recipes objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
