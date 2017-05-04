//
//  NetworkingViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 5/3/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import "NetworkingViewController.h"

@interface NetworkingViewController ()

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
    
    [self.webView loadRequest:urlRequest];
//    [self.view addSubview:webView];
    
    
}

- (IBAction) buttonPressed:(id)sender
{
    NSString* value = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('myId').value"];
    NSLog(@"\n Value: %@", value);
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElement‌​ById('myId').value = 'myNewValue'"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"increaseCounter(5)"];

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
