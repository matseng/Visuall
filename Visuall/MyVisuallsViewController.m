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
