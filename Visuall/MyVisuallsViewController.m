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
#import "UserUtil.h"
#import "StateUtilFirebase.h"
#import "StateUtilFirebase+Create.h"
#import "NewVisuallViewController.h"

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

//    self.recipes = [NSMutableArray arrayWithObjects: @{@"title": @"n/a"}, nil];
//    self.recipes = [NSMutableArray arrayWithObjects: nil, nil];
    self.recipes = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(personalVisuallsDidLoadNotification:) name:@"newUserWithNoVisualls" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(personalVisuallsDidLoadNotification:) name:@"personalVisuallDidLoad" object:nil];
    [StateUtilFirebase loadVisuallsListForCurrentUser];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"+ New"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(addNewVisuall)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    self.av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.av.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
    //        self.av.center = CGPointMake(self.signInButton.center.x, self.signInButton.center.y + 50);
    self.av.tag  = 1;
    [self.av removeFromSuperview];
    [self.view addSubview: self.av];
    [self.av startAnimating];
    
}

- (void) viewWillAppear:(BOOL) animated
{
    if ([self.segue.identifier isEqualToString: @"unwindFromNewVisuall"])  // the automatically open the newly created visuall
    {
        [self.tableView selectRowAtIndexPath: self.indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self manualSegueToNewViewController: self.metadataOfCurrentVisuall];
        self.metadataOfCurrentVisuall = nil;
        self.indexPath = nil;
        self.segue = nil;
    }
}

/*
 * Name: unwindToContainerVC
 * Description: Receives manual unwind from NewVisuallViewController
 * Displays new Visuall name
 */
- (IBAction) unwindToContainerVC: (UIStoryboardSegue *) segue
{
    self.segue = segue;
    if ([segue.identifier isEqualToString: @"unwindFromNewVisuall"])
    {
//        NSString *title = [self.metadataOfCurrentVisuall[@"metadata"] valueForKey: @"title"];
//        self.metadataOfCurrentVisuall = [StateUtilFirebase setValueVisuall: title];
        self.metadataOfCurrentVisuall = [StateUtilFirebase setValueVisuall: self.metadataOfCurrentVisuall];
        [self.metadataOfCurrentVisuall setObject: @"YES" forKey: @"isNewVisuall"];
        self.indexPath = [self appendVisuallToList: self.metadataOfCurrentVisuall];
    }
    else if ([segue.identifier isEqualToString: @"unwindFromEditVisuall"])
    {
        // TODO (Mar 10, 2017): Update local state and list view to show current title
        self.recipes[self.indexPath.row] = self.metadataOfCurrentVisuall;
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath: self.indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [StateUtilFirebase updateMetadataVisuall: [self.metadataOfCurrentVisuall mutableCopy]];
        
        NSMutableSet *keysAdded = [[NSMutableSet alloc] init];
        NSMutableSet *keysRemoved = [[NSMutableSet alloc] init];
        NSMutableSet *keysInA = [NSMutableSet setWithArray:[self.sharedWithPrevious allKeys]];
        NSMutableSet *keysInB = [NSMutableSet setWithArray:[self.metadataOfCurrentVisuall[@"shared-with"] allKeys]];
        [keysAdded setSet:keysInB];
        [keysAdded minusSet:keysInA];
        [keysRemoved setSet: keysInA];
        [keysRemoved minusSet: keysInB];
        [StateUtilFirebase setSharedVisuall: self.metadataOfCurrentVisuall[@"key"] withEmails: [keysAdded allObjects]];
        NSLog(@"keys in A that are not in B: %@", keysAdded); // TODO (Apr 21, 2017): Create a new TABLE of these email address added called Invites... each email is a key with an object of visuall keys
        NSLog(@"keys in A that are not in B: %@", keysRemoved);  // TODO: remove email address from share list
        
    }
    else if ([segue.identifier isEqualToString: @"unwindFromDeleteVisuall"])
    {
        NSLog(@"\n Delete visuall from list and firebase");
        NSString *key = [self.recipes objectAtIndex: self.indexPath.row][@"key"];
        [self.tableView beginUpdates];
        [self.recipes removeObjectAtIndex: self.indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: self.indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [StateUtilFirebase removeVisuall: key];
        self.indexPath = nil;
    }
}

- (void) addNewVisuall
{
//    [self performSegueWithIdentifier:@"segueToInfoModal" sender:self];
    [self performSegueWithIdentifier:@"segueToNewVisuall" sender:self];
}


- (void) personalVisuallsDidLoadNotification:(NSNotification*) notification
{
    if ([notification.name isEqualToString:@"personalVisuallDidLoad"])
    {
        NSString *title = notification.userInfo[@"title"];
        if ( !title || (title == (id)[NSNull null] || title.length == 0 ) )
        {
//            [StateUtilFirebase removeVisuall: notification.userInfo[@"key"]];
            return;  // do not load a "null" visual

        }
        [self appendVisuallToList: notification.userInfo];
        [self.av removeFromSuperview];
    }
    else if ([notification.name isEqualToString:@"newUserWithNoVisualls"])
    {
        [self.av removeFromSuperview];
    }
}

- (NSIndexPath *) appendVisuallToList: (NSDictionary *) dict
{
    [self.recipes addObject: dict];
    [self.tableView beginUpdates];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.recipes.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[ip]
                          withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    return ip;
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
    
    cell.textLabel.text = [self.recipes objectAtIndex:indexPath.row][@"title"];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    /*
    if ([segue.identifier isEqualToString:@"showVisuallDetail"]) 
     {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ViewController *destViewController = segue.destinationViewController;
        NSLog(@"prep fro Segue: %@", [self.recipes objectAtIndex:indexPath.row]);
        destViewController.firebaseURL = [self.recipes objectAtIndex:indexPath.row][@"key"];
    }
     */
    
    if ([segue.identifier isEqualToString:@"segueToEditVisuall"])
    {
        NewVisuallViewController *destViewController = (NewVisuallViewController *) segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destViewController.metadata = [[self.recipes objectAtIndex:indexPath.row] mutableCopy];
        self.sharedWithPrevious = [destViewController.metadata[@"shared-with"] copy];
    }
}

//- (void) __tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ( !self.myGreenController )
//    {
//        self.myGreenController = [[ViewController alloc] init];
//    }
//    
////    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    self.myGreenController.firebaseURL = [self.recipes objectAtIndex:indexPath.row][@"key"];
//    [self.navigationController pushViewController: self.myGreenController animated:YES];
//    
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    ViewController *destViewController = [[ViewController alloc] init];
//    destViewController.firebaseURL = [self.recipes objectAtIndex:indexPath.row][@"key"];
//    [self.navigationController pushViewController: destViewController animated:YES];
    NSMutableDictionary *metadata = [[self.recipes objectAtIndex:indexPath.row] mutableCopy];
    if ([metadata objectForKey: @"isNewVisuall"])
    {
        [metadata removeObjectForKey: @"isNewVisuall"];
    }
    [self manualSegueToNewViewController: metadata];
}

- (void) manualSegueToNewViewController: (NSMutableDictionary *) dict
{
    ViewController *destViewController = [[ViewController alloc] init];
    destViewController.firebaseURL = (dict[@"key"]) ? dict[@"key"] : dict[@"metadata"][@"key"];
    destViewController.metadataTemp = dict;
    [self.navigationController pushViewController: destViewController animated:YES];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *) indexPath
{
    NSLog(@"prep fro Segue: %@", [self.recipes objectAtIndex:indexPath.row]);
    [self.tableView selectRowAtIndexPath: indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.indexPath = indexPath;
    [self performSegueWithIdentifier:@"segueToEditVisuall" sender:self];
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
