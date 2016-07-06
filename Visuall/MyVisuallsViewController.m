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
