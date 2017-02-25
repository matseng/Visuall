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
//#import "CustomTableViewCell.h"

@interface MyVisuallsViewController ()

@end

@implementation MyVisuallsViewController
{
//    NSArray *self.recipes;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

//    self.recipes = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];

    self.recipes = [NSMutableArray arrayWithObjects: @"n/a", nil];
    
    // TODO (Sep 21, 2016): get list of public and private Visualls loaded as CLASS variables in StateUtilFirebase
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(personalVisuallsDidLoadNotification:) name:@"personalVisuallDidLoad" object:nil];
    [StateUtilFirebase loadVisuallsListForCurrentUser];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"+ New"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(addNewVisuall)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
}

- (void) addNewVisuall
{
    NSString *title = @"New Visuall goes here";
    [self.recipes addObject: title];
    [self.tableView beginUpdates];
//    tblname.insertRowsAtIndexPaths([
//                                    NSIndexPath(forRow: Yourarray.count-1, inSection: 0)
//                                    ], withRowAnimation: .Automatic)
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath
                                                   indexPathForRow:self.recipes.count - 1 inSection:0]]
                           withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
//    [self performSegueWithIdentifier:@"segueToInfoModal" sender:self];
    [self performSegueWithIdentifier:@"segueToNewVisuall" sender:self];
}


-(void) personalVisuallsDidLoadNotification:(NSNotification*) notification
{
    if ([notification.name isEqualToString:@"personalVisuallDidLoad"])
    {
        NSDictionary* userInfo = notification.userInfo;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
        cell.textLabel.text = userInfo[@"title"];  // TODO (Sep 21, 2016): Load data here that needed for table view display... and to load the visuall graph
    }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ThisIsLimitLotsofTextHere"
//                                                                             style:UIBarButtonItemStylePlain
//                                                                            target:nil
//                                                                            action:nil];
//    
//    self.navigationController.navigationBar.translucent = NO;
//    
//    UITabBarController *tabBarController = (UITabBarController *) self.tabBarController;
//    UITabBar *tabBar = tabBarController.tabBar;
//    UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
//    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:1];
//    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:2];
//    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:3];
//    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:4];
//    
//    tabBarItem0.title = @"Global";
//    tabBarItem1.title = @"Favorites";
//    tabBarItem2.title = @"My Visualls";
//    tabBarItem3.title = @"Notifications";
//    tabBarItem4.title = @"More";
//    
//    UIImage *globe = [UIImage imageNamed:@"Globe-50"];
//    globe = [UIImage imageWithCGImage:globe.CGImage scale:2.2 orientation:globe.imageOrientation];
//    [tabBarItem0 setImage:globe];
//    
//    UIImage *star = [UIImage imageNamed:@"Star-50"];
//    star = [UIImage imageWithCGImage:star.CGImage scale:1.8 orientation:star.imageOrientation];
//    [tabBarItem1 setImage:star];
//    
//    UIImage *lightBulb = [UIImage imageNamed:@"light-bulb"];
//    lightBulb = [UIImage imageWithCGImage:lightBulb.CGImage scale:2.1 orientation:lightBulb.imageOrientation];
//    [tabBarItem2 setImage:lightBulb];
//    
//    UIImage *alarmBell = [UIImage imageNamed:@"alarm-bell"];
//    alarmBell = [UIImage imageWithCGImage:alarmBell.CGImage scale:2.6 orientation:alarmBell.imageOrientation];
//    [tabBarItem3 setImage: alarmBell];
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recipes count];
}

// TODO (Feb 23, 2017): Trying to create a custom table cell that has in-line editable text
// http://stackoverflow.com/questions/9090102/allow-a-user-to-edit-the-text-in-a-uitableview-cell
// https://code.tutsplus.com/tutorials/ios-sdk-crafting-custom-uitableview-cells--mobile-15702

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.recipes objectAtIndex:indexPath.row];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVisuallDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ViewController *destViewController = segue.destinationViewController;
        NSLog(@"prep fro Segue: %@", [self.recipes objectAtIndex:indexPath.row]);
        destViewController.firebaseURL = [self.recipes objectAtIndex:indexPath.row];
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"prep fro Segue: %@", [self.recipes objectAtIndex:indexPath.row]);
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
