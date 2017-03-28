//
//  SpeedReadingViewController.m
//  
//
//  Created by Michael Tseng MacBook on 3/27/17.
//
//

#import "SpeedReadingViewController.h"

@interface SpeedReadingViewController ()

@end

@implementation SpeedReadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"\n SpeedReadingViewController.h");
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Select a group with text to proceed with Speed Reading";
//    label.center = self.view.center;
//    [label sizeToFit];
    CGRect rect = self.view.frame;
    rect.origin = CGPointMake(0, 0);
    label.frame = rect;
    [self.view addSubview: label];
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
