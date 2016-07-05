//
//  MyVisuallsDetailViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/5/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "MyVisuallsDetailViewController.h"

@interface MyVisuallsDetailViewController ()

@end

@implementation MyVisuallsDetailViewController

//@synthesize recipeLabel;
//@synthesize recipeName;

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@", self.recipeName);
    self.recipeLabel.text = self.recipeName;
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
