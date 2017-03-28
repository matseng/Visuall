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
    label.numberOfLines = 0;
    label.text = @"Select a group that contains text \n to proceed with Speed Reading";
    [label setFont: [UIFont fontWithName:@"Arial Rounded MT Bold" size:14.0f]];
    [label sizeToFit];
    label.center = CGPointMake(self.preferredContentSize.width / 2, self.preferredContentSize.height / 2);
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
