//
//  WelcomeViewContoller.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "WelcomeViewController.h"

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO(developer) Configure the sign-in button look/feel
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    // Uncomment to automatically sign in the user.
    [[GIDSignIn sharedInstance] signInSilently];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToTabBarController"]) {

    }
}

- (IBAction)skipThisStep:(id)sender {
    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
}

- (IBAction)signoutHandler:(id)sender {
        NSError *error;
        [[FIRAuth auth] signOut:&error];
        if (!error) {
            NSLog(@"Sign-out succeeded");
        }
}

- (void) segueToNextView
{
    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
}


- (void) signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
}

@end
