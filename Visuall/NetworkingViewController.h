//
//  NetworkingViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 5/3/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@interface NetworkingViewController : UIViewController

@property WebViewJavascriptBridge* bridge;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property(strong,nonatomic) WKWebView *webView2;

@property (strong, nonatomic) IBOutlet UITextField *textField;

- (IBAction)buttonPressed:(id)sender;

@end

