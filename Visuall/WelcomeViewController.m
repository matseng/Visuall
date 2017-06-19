//
//  WelcomeViewContoller.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UserUtil.h"
#import "RCTRootView.h"

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UserUtil sharedManager] setAutoSignInIndicator: YES];
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signInSilently];  // Uncomment to automatically sign in the user
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (IBAction)highScoresButtonPressed:(id)sender {
    [self highScoreButtonPressedHandler];
}

- (void) highScoreButtonPressedHandler
{

    
    NSLog(@"High Score Button Pressed");
//    NSURL *jsCodeLocation = [NSURL
//                             URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios"];
    
    NSURL *jsCodeLocation;
    
    // Loading JavaScript code (https://gist.github.com/almost/898a829d5197c69d29b0)
    #if DEBUG
        // For Debug build load from development server. Start the server from the repository root:
        //
        // $ npm start
        #if TARGET_IPHONE_SIMULATOR
            // Run from locally running dev server:
            // $ npm run
            jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle"];

        #else
            // Run on device with code coming from dev server on PC (change the IP to your PCs IP):
            // $ npm run
            jsCodeLocation = [NSURL URLWithString:@"http://10.0.1.29:8081/index.ios.bundle"];

    #endif
    #else
        // For production load from pre-bundled file on disk. To re-generate the static bundle, run
        //
        // $ curl http://localhost:8081/index.ios.bundle -o main.jsbundle
        // $ react-native bundle --platform ios --dev true --entry-file index.ios.js --bundle-output ios/main.jsbundle
        jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
    #endif
    
    NSString *idToken = [[[[GIDSignIn sharedInstance] currentUser] authentication] idToken];
    NSString *accessToken = [[[[GIDSignIn sharedInstance] currentUser] authentication] accessToken];

    RCTRootView *rootView =
    [[RCTRootView alloc] initWithBundleURL : jsCodeLocation
                         moduleName        : @"RNHighScores"
                         initialProperties :
    @{
       @"scores" : @[
               @{
                   @"name" : @"Alex",
                   @"value": @"42"
                   },
               @{
                   @"name" : @"Joel",
                   @"value": @"99"
                   }
               ],
       @"idToken": idToken,
       @"accessToken": accessToken,
    }
                          launchOptions    : nil];
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = rootView;
    [self presentViewController:vc animated:YES completion:nil];
}


/*
 * Name: updateSubviews
 * Description: Re-centers subviews upon change of device orientation
 */
- (void) updateSubviews
{
    // Scale and center icon:
    UIImage *originalImage = [UIImage imageNamed: @"Microsoft-Visual-Studio-icon_v3"];
    float scale = 230.0 / originalImage.size.width;  // kGIDSignInButtonStyleStandard: 230 x 48 (default)
    UIImage *scaledImage = [UIImage imageWithCGImage:[originalImage CGImage]
                                               scale:(1/scale * 2)  // Multiplying by 2 makes the image appear smaller
                                         orientation:(originalImage.imageOrientation)];
    self.iconImageView.frame = CGRectMake(0, 0, scaledImage.size.width, scaledImage.size.height);
    self.iconImageView.center = CGPointMake(self.view.center.x, self.view.center.y / 2);
    self.iconImageView.image = scaledImage;
    
    // Create and center Google Sign-in button:
    if ( !self.signInButton) self.signInButton = [[GIDSignInButton alloc] initWithFrame: CGRectZero];
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        self.signInButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 2 / 3);
    }
    else
    {
        self.signInButton.center = self.view.center;
    }

    [self.view addSubview: self.signInButton];
    
    // Center text label:
    self.welcomeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width,  self.welcomeLabel.frame.size.height);
    self.welcomeLabel.center = CGPointMake(self.view.center.x,
                                           (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + self.signInButton.frame.origin.y) / 2);
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([[UserUtil sharedManager] autoSignInIndicator])
    {
        self.av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.av.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        self.av.center = CGPointMake(self.signInButton.center.x, self.signInButton.center.y + 50);
        self.av.tag  = 1;
        [self.av removeFromSuperview];
        [self.view addSubview: self.av];
        [self.av startAnimating];
    }
}


-(void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        [self updateSubviews];
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        [self updateSubviews];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToTabBarController"]) {

    }
}

- (IBAction)skipThisStep:(id)sender
{
    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
}

- (IBAction)signoutHandler:(id)sender {
        NSError *error;
        [[FIRAuth auth] signOut:&error];
        if (!error) {
            NSLog(@"Sign-out succeeded");
        }
    [[UserUtil sharedManager] GIDdisconnect];
}

- (void) segueToNextView
{
//    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
    [self highScoreButtonPressedHandler];
}


- (void) signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
//    [self performSegueWithIdentifier:@"segueToTabBarController" sender:self];
    [self segueToNextView];
}

@end
