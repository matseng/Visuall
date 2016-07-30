//
//  WelcomeViewContoller.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "WelcomeViewContoller.h"

@implementation WelcomeViewContoller

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToTabBarController"]) {
//        segue.destinationViewController.navigationItem.hidesBackButton = YES;
        
//            self.tabBarController.navigationItem.hidesBackButton=YES;
    }
}

- (IBAction)skipThisStep:(id)sender {
//    [self childViewControllerContainingSegueSource: self.]
    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
}
@end
