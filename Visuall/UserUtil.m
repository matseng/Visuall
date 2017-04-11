//
//  UserUtil.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/17/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "UserUtil.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "ViewController.h"

@implementation UserUtil

+(id)sharedManager {
    
    static UserUtil *sharedMyManager = nil;
    
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
//            sharedMyManager.zoom = 1.0;
//            sharedMyManager.pan = (CGPoint){0.0,0.0};
            NSLog(@"Initialized UserUtil");
        }
    }
    return sharedMyManager;
}

- (void) userIsSignedInHandler: (FIRUser *) user
{
    self.firebaseUser = user;
    self.userID = [FIRAuth auth].currentUser.uid;
    NSString *name;
    NSString *email;
    NSString *provider;
    for ( id <FIRUserInfo> profile in user.providerData) {
        NSString *providerID = profile.providerID;
        NSString *uid = profile.uid;  // Provider-specific UID
        name = profile.displayName;
        email = profile.email;
        //        provider = profile.email;
        NSURL *photoURL = profile.photoURL;
        NSLog(@"userID: %@", self.userID);
        NSLog(@"uid: %@", uid);
    }
}

- (void) GIDdisconnect
{
    //    [[GIDSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];
}

- (StateUtilFirebase *) getState
{
    ViewController *vc = (ViewController *)[self topViewController];
    if ( vc && vc.visuallState)
    {
        return vc.visuallState;
    }
    return nil;
}

- (UIViewController*) topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

//- (void) setAutoSignInIndicator: (BOOL) yesOrNo
//{
//    self.autoSignInIndicatorOn = yesOrNo;
//}

@end
