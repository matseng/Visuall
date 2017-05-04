//
//  NetworkingViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 5/3/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface NetworkingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UITextField *textField;

- (IBAction)buttonPressed:(id)sender;

@end

