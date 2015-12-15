//
//  HomeViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 12/9/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (strong, nonatomic) IBOutlet UIView *ContentView;
@property (strong, nonatomic) UIView *contentView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float contentWidth = 1000.0;
    float contentHeight = 1000.0;
    [self.scrollView setContentSize: CGSizeMake(contentWidth, contentHeight)];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, contentHeight)];
//    [contentView setBackgroundColor:(UIColor) UIC];
    self.contentView.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview: self.contentView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    imageView.center = self.view.center;
    UIImage *comp = [UIImage imageNamed:@"compass"];
    imageView.image = comp;
    [self.contentView addSubview:imageView];
    [self.scrollView setMinimumZoomScale: 0.1];
    [self.scrollView setMaximumZoomScale: 10.0];
    [self.scrollView setUserInteractionEnabled:YES];
//    self.ContentView.frame = CGRectMake(0, 0, 1000, 1000);
//    [self.ContentView setFrame:CGRectMake(0, 0, 1000, 1000)];
//    [self.ContentView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.height)];
//    self.scrollView.clipsToBounds = YES;
//    self.scrollView.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
//    [self.ContentView setFrame:CGRectMake(0, 0, 1000, 1000)];
}

//-(void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//{
//    NSLog(@"view size %@", NSStringFromCGRect(view.frame));
//    self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 4, 2);
//}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    //self.ContentView.frame = CGRectMake(0, 0, 10000, 10000);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
//    return [self.scrollView.subviews objectAtIndex:0];
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
