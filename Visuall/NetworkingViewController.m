//
//  NetworkingViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 5/3/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import "NetworkingViewController.h"
#import "WebViewJavascriptBridge.h"



@interface NetworkingViewController ()

@property WebViewJavascriptBridge* bridge;

@end

@implementation NetworkingViewController

- (void)viewDidLoad {

    [super viewDidLoad];

//    UIWebView *webView = [[UIWebView alloc] init];
//    webView.frame = self.view.frame;
//    NSString *urlString = @"http://www.sourcefreeze.com";  // TODO (May 3, 2017): temp security hack via http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http/32560433#32560433
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    
    NSString *localURL = [NSBundle pathForResource:@"index" ofType:@"html" inDirectory: [[NSBundle mainBundle] bundlePath]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:localURL]];
    
    self.webView2 = [[WKWebView alloc] initWithFrame: self.webView.frame];
    [self.webView2 loadRequest: urlRequest];
//    self.webView2.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.webView2];
    
    if (_bridge) {
        return;
    }
    
    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView: self.webView2];
    [_bridge setWebViewDelegate: self];
    
    [self.bridge registerHandler:@"ObjC Echo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC Echo called with: %@", data);
        responseCallback(data);
    }];
    [self.bridge callHandler:@"JS Echo" data:nil responseCallback:^(id responseData) {
        NSLog(@"ObjC received response: %@", responseData);
    }];
    
}

- (IBAction) buttonPressed:(id)sender
{
//    NSString* value = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('myId').value"];
//    NSLog(@"\n Value: %@", value);
//    
//    [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElement‌​ById('myId').value = 'myNewValue'"];
//    [self.webView stringByEvaluatingJavaScriptFromString:@"increaseCounter(5)"];
//    [self.webView2 evaluateJavaScript:@"increaseCounter(5)" completionHandler: nil];
    
    [self.bridge callHandler:@"JS Echo" data: @{@"myKey": @7} responseCallback:^(id responseData) {
        NSLog(@"ObjC received response: %@", responseData);
    }];

    
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
