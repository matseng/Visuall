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
#import "StateUtilFirebase+Delete.h"
#import "NewVisuallViewController.h"

@interface MyVisuallsViewController ()

@end

@implementation MyVisuallsViewController
{
//    NSArray *self.recipes;
    UIRefreshControl *__refreshControl;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent: NO];  // NOTE: Changing this parameter affects positioning, weird.
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(personalVisuallsDidLoadNotification:) name:@"newUserWithNoVisualls" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(personalVisuallsDidLoadNotification:) name:@"personalVisuallDidLoad" object:nil];


//    [StateUtilFirebase loadVisuallsListForCurrentUser];
    [self refreshTable];
    
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
    
    /*
    __refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview: __refreshControl];
    [__refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
     */
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

- (void) refreshTable
{
    self.tableView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.recipes = [[NSMutableArray alloc] init];
    
    NSLog(@"\n Now refreshing table");
    
    [self.recipes removeAllObjects];
//    self.tableView.dataSource = nil;
    [self.tableView reloadData];
    [StateUtilFirebase loadVisuallsListForCurrentUser];
    [__refreshControl endRefreshing];
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
        self.metadataOfCurrentVisuall = [StateUtilFirebase setValueVisuall: self.metadataOfCurrentVisuall];
        [self.metadataOfCurrentVisuall setObject: @"YES" forKey: @"isNewVisuall"];
        self.indexPath = [self appendVisuallToList: self.metadataOfCurrentVisuall];
        [self updateMetadata];
    }
    else if ([segue.identifier isEqualToString: @"unwindFromEditVisuall"])
    {
        self.recipes[self.indexPath.row] = self.metadataOfCurrentVisuall;
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath: self.indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self updateMetadata];
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

- (void) updateMetadata
{
    [StateUtilFirebase updateMetadataVisuall: [self.metadataOfCurrentVisuall mutableCopy]];
    NSMutableSet *keysAdded = [[NSMutableSet alloc] init];
    NSMutableSet *keysRemoved = [[NSMutableSet alloc] init];

    NSMutableSet *keysInA;
    if ( self.sharedWithPrevious != [NSNull null] && self.sharedWithPrevious[@"shared-with"] != [NSNull null] )
    {
        keysInA = [NSMutableSet setWithArray:[self.sharedWithPrevious allKeys]];
    }
    else
    {
        keysInA = [[NSMutableSet alloc] init];
    }

    NSMutableSet *keysInB = (self.metadataOfCurrentVisuall[@"shared-with"] != [NSNull null]) ?
    [NSMutableSet setWithArray:[self.metadataOfCurrentVisuall[@"shared-with"] allKeys]] : [[NSMutableSet alloc] init];
    [keysAdded setSet:keysInB];
    [keysAdded minusSet:keysInA];
    [keysRemoved setSet: keysInA];
    [keysRemoved minusSet: keysInB];
    NSLog(@"keysAdded: %@", keysAdded);
    NSLog(@"keysRemoved: %@", keysRemoved);
    [StateUtilFirebase setSharedVisuall: self.metadataOfCurrentVisuall[@"key"] withEmails: [keysAdded allObjects]];
    [StateUtilFirebase removeSharedVisuallInvite: self.metadataOfCurrentVisuall[@"key"] withEmails: [keysRemoved allObjects]];

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
    for (NSDictionary *iterDict in self.recipes)  // TODO (Apr 25, 2017): Brute force method for updating metadata in list of visualls
    {
        if(iterDict[@"key"] == dict[@"key"] || [(NSString *) iterDict[@"key"] isEqualToString: (NSString *) dict[@"key"]] )
        {
            [iterDict setValuesForKeysWithDictionary: dict];
            [self.tableView reloadData];
            return nil;
        }
    }

    [self.recipes addObject: dict];  // vs. [self.recipes insertObject: dict atIndex: 0];  // [self.tableView reloadData];
    [self.tableView beginUpdates];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.recipes.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[ip]
                          withRowAnimation:UITableViewRowAnimationTop];
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    [self addSharingIndicatorToCell: cell andIndexPath: indexPath];
    return cell;
}

- (void) addSharingIndicatorToCell: (UITableViewCell *) cell andIndexPath: (NSIndexPath *) indexPath
{
    for (UIView *subview in [cell.contentView subviews])
    {
        if (subview.tag == 2)  // shared-with indicator button
        {
            [subview removeFromSuperview];
        }
    }

    NSDictionary *sharedWith = [self.recipes objectAtIndex:indexPath.row][@"shared-with"];
    
    if ( sharedWith != [NSNull null] && [sharedWith count] > 0)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = 2;
        UIImage *sharingIndicator = [UIImage imageNamed: @"User Groups-50"];
        float buttonLength = 24.0;
        
        NSLog(@"addSharingIndicatorToCell: %@", NSStringFromCGRect(cell.frame));
        
        button.frame = CGRectMake(cell.frame.origin.x + cell.frame.size.width - 100, (cell.frame.size.height - buttonLength) / 2, buttonLength, buttonLength);
//        button.frame = CGRectMake(cell.contentView.frame.origin.x + cell.contentView.frame.size.width - 100,
//                                  (cell.contentView.frame.size.height - buttonLength) / 2,
//                                  buttonLength,
//                                  buttonLength);
        [button setImage:sharingIndicator forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onCustomAccessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor= [UIColor clearColor];
        [cell.contentView addSubview:button];
        
//        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;  // http://erkanyildiz.me/lab/autoresizingmask/
        [self addConstraintsToShareButton: button fromCell: cell];
    }
}

/*
 * Name:
 * Description: http://stackoverflow.com/questions/30590903/adding-constraints-programmatically-in-objective-c
 */
- (void) addConstraintsToShareButton: (UIButton *) button fromCell: (UITableViewCell *) cell
{
    float buttonLength = 24.0;
    float heightOffset = (cell.frame.size.height - buttonLength) / 2;
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    /* Leading space to superview */
    NSLayoutConstraint *leftButtonXConstraint = [NSLayoutConstraint
                                                 constraintWithItem:button attribute: NSLayoutAttributeRight
                                                 relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:
                                                 NSLayoutAttributeRight multiplier:1.0 constant: 0];
    /* Top space to superview Y*/
    NSLayoutConstraint *leftButtonYConstraint = [NSLayoutConstraint
                                                 constraintWithItem:button attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual toItem:button.superview attribute:
                                                 NSLayoutAttributeTop multiplier:1.0f constant: heightOffset];
    /* Fixed width */
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:buttonLength];
    /* Fixed Height */
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:buttonLength];
    
    [button.superview addConstraints:@[leftButtonXConstraint, leftButtonYConstraint, widthConstraint, heightConstraint]];
}


- (void) onCustomAccessoryTapped:(UIButton *) sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSDictionary *sharedWith = [self.recipes objectAtIndex:indexPath.row][@"shared-with"];
    NSLog(@"\n onCustomAccessoryTapped, sharedWith: %@", sharedWith);
    [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
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
