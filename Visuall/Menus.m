//
//  Menus.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "Menus.h"
#import <UIKit/UIKit.h>
#import "UIImage+Extras.h"
#import "SevenSwitch.h"

@implementation Menus

- (void) createTopMenu: (UIViewController *) this
{

    float h = 42;
    float w = 42;
    float padding = 10;
    UIColor *backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
    UIColor *blueButtonColor = this.view.tintColor;
    
    this.navigationItem.leftItemsSupplementBackButton = NO;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImg = [[UIImage imageNamed: @"back"] imageWithExtraPadding: .1];
    //    backImg = [UIImage imageNamed: @"back"];
    backImg = [UIImage imageWithCGImage:backImg.CGImage scale:2.4 orientation:backImg.imageOrientation];
    
    backImg = [backImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *backImgHilighted = [backImg  makeImageWithBackgroundColor:this.view.tintColor andForegroundColor:backgroundColor];
    [backButton setImage:backImg forState:UIControlStateNormal];
    [backButton setImage:backImgHilighted forState:UIControlStateHighlighted];
    [backButton addTarget:this
                   action:@selector(backButtonHandler)
         forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 30, h);
    backButton.layer.cornerRadius = 5;
    backButton.tintColor = this.view.tintColor;
    backButton.layer.borderWidth = 0;
    backButton.layer.masksToBounds = YES;
    [backButton.layer setBorderColor: [this.view.tintColor CGColor]];
    backButton.clipsToBounds = YES;
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0, 85,44)];
    searchBar.placeholder = @"Search";
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc]initWithCustomView:searchBar];
    searchBarItem.tag = 123;
    
    SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, w * 1.65, h * 0.75)];
    mySwitch.center = CGPointMake(this.view.bounds.size.width * 0.5, this.view.bounds.size.height * 0.5);
    [mySwitch addTarget:this action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch.offLabel.text = @"Edit";
    mySwitch.offLabel.textColor = blueButtonColor;
    mySwitch.onTintColor = blueButtonColor;
    mySwitch.onLabel.text = @" Done";
    mySwitch.onLabel.textColor = backgroundColor;
    NSLog(@"offlabel text width: %f", mySwitch.offLabel.frame.size.width);
    [mySwitch setOn:NO animated:YES];
    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithCustomView: mySwitch];
    
    int i = 3;
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] init];
    segmentControl.frame = CGRectMake(0, 0, w * i, h);
    segmentControl.backgroundColor = backgroundColor;
    segmentControl.layer.cornerRadius = 0.0f;
    segmentControl.layer.borderColor = backgroundColor.CGColor;
    segmentControl.layer.borderWidth = 2.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, segmentControl.frame.size.height), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [segmentControl setDividerImage:blank
                forLeftSegmentState:UIControlStateNormal
                  rightSegmentState:UIControlStateNormal
                         barMetrics:UIBarMetricsDefault];
    
    //    UIImage *reading = [this imageWithExtraPaddingFromImage:[UIImage imageNamed: @"Reading-50"] percentPadding: .1];
    UIImage *reading = [UIImage imageNamed: @"Reading-50"];
    reading = [UIImage imageWithCGImage:reading.CGImage scale:1.7 orientation:reading.imageOrientation];
    reading = [reading imageWithRoundedCornersSize:5.0f];
    [segmentControl insertSegmentWithImage:reading atIndex:0 animated:YES];
    
    UIImage *sharing = [UIImage imageNamed: @"User Groups-50"];
    sharing = [UIImage imageWithCGImage:sharing.CGImage scale:1.5 orientation:sharing.imageOrientation];
    [segmentControl insertSegmentWithImage:sharing atIndex:1 animated:YES];
    
    UIImage *info = [UIImage imageNamed: @"Info-50"];
    info = [UIImage imageWithCGImage:info.CGImage scale:1.7 orientation:info.imageOrientation];
    [segmentControl insertSegmentWithImage:info atIndex:2 animated:YES];
    
    UIBarButtonItem *segmentControlBarItem = [[UIBarButtonItem alloc] initWithCustomView: segmentControl];
    
    UIButton *starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *starImg = [UIImage imageNamed: @"Star-50"];
    starImg = [UIImage imageWithCGImage:starImg.CGImage scale:1.6 orientation:starImg.imageOrientation];
    starImg = [starImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *starImgHilighted = [starImg makeImageWithBackgroundColor:this.view.tintColor andForegroundColor:backgroundColor];
    [starButton setImage:starImg forState:UIControlStateNormal];
    [starButton setImage:starImgHilighted forState:UIControlStateHighlighted];
    [starButton addTarget:this
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [starButton setTitle:@"star" forState:UIControlStateNormal];
    starButton.frame = CGRectMake(0, 0, w, h);
    starButton.layer.cornerRadius = 5;
    starButton.tintColor = this.view.tintColor;
    starButton.layer.borderWidth = 0;
    starButton.layer.masksToBounds = YES;
    [starButton.layer setBorderColor: [this.view.tintColor CGColor]];
    UIBarButtonItem *starBarItem = [[UIBarButtonItem alloc]initWithCustomView:starButton];
    
    
    //    float totalHeight = [[UIScreen mainScreen] bounds].size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    //    NSLog(@"total height: %f", totalHeight);
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width + 30, h+2)];
    
    UIBarButtonItem *negativeSpacer30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer30 setWidth:-30];
    UIBarButtonItem *negativeSpacer10 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer10 setWidth:-10];
    UIBarButtonItem *negativeSpacer5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer5 setWidth:-5];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //    [toolbar setItems:@[backBarItem, searchBarItem, editBarItem, negativeSpacer5, segmentControlBarItem, negativeSpacer10, starBarItem] animated:YES];
    [toolbar setItems:@[backBarItem, flexibleSpace, searchBarItem, editBarItem, negativeSpacer5, segmentControlBarItem, flexibleSpace, negativeSpacer5, starBarItem] animated:YES];
    
    //    toolbar.clipsToBounds = YES;
    UIBarButtonItem *toolBarItem = [[UIBarButtonItem alloc] initWithCustomView: toolbar];
    
    //    this.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    //    this.navigationItem.leftBarButtonItems = @[negativeSpacer, negativeSpacer5, backBarItem, flexibleSpace, toolBarItem, flexibleSpace];
    this.navigationItem.leftBarButtonItems = @[negativeSpacer30, toolBarItem];
    
}


@end
