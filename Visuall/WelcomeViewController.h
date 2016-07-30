//
//  WelcomeViewContoller.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
@import Firebase;

@interface WelcomeViewController : UIViewController <GIDSignInUIDelegate>

@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;

- (IBAction) skipThisStep:(id)sender;

- (IBAction)signoutHandler:(id)sender;

- (void) segueToNextView;

@end
