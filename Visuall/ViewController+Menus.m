//
//  ViewController+Menus.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+Menus.h"
#import <UIKit/UIKit.h>
#import "UIImage+Extras.h"
#import "SevenSwitch.h"
#import "ViewController+panHandler.h"
#import "StateUtilFirebase.h"
#import "SegmentedControlMod.h"
#import "UIView+VisualItem.h"


@implementation ViewController (Menus) 

UIImage *trashImg;
UIImage *trashImgHilighted;
UIColor *backgroundColor;
UIColor *darkGrayBorderColor;

- (void) createTopMenu
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    float h = 42;
    float w = 42;
    float padding = 10;
    backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
    darkGrayBorderColor = [UIColor colorWithRed: 174/255.0f green: 174/255.0f blue: 174/255.0f alpha:1.0f];
    UIColor *blueButtonColor = self.view.tintColor;
    
    self.navigationItem.leftItemsSupplementBackButton = NO;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImg = [[UIImage imageNamed: @"back"] imageWithExtraPadding: .1];
    backImg = [UIImage imageWithCGImage:backImg.CGImage scale:2.4 orientation:backImg.imageOrientation];
    backImg = [backImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *backImgHilighted = [backImg  makeImageWithBackgroundColor:self.view.tintColor andForegroundColor: backgroundColor];
    [backButton setImage:backImg forState:UIControlStateNormal];
    [backButton setImage:backImgHilighted forState:UIControlStateHighlighted];
    [backButton addTarget:self
                   action:@selector(backButtonHandler)
         forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 30, h);
    backButton.layer.cornerRadius = 5;
    backButton.tintColor = self.view.tintColor;
    backButton.layer.borderWidth = 0;
    backButton.layer.masksToBounds = YES;
    [backButton.layer setBorderColor: [self.view.tintColor CGColor]];
    backButton.clipsToBounds = YES;
    backButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0, 85, 44)];
    searchBar.placeholder = @"Search";
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc]initWithCustomView:searchBar];
    searchBarItem.tag = 123;
    
    SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, w * 1.65, h * 0.75)];
//    SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, w * 1.65, 32 * 0.75)];
    self.editSwitch = mySwitch;
    mySwitch.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
    [mySwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch.offLabel.text = @"Edit";
    mySwitch.offLabel.textColor = blueButtonColor;
//    mySwitch.thumbTintColor = blueButtonColor;
//    mySwitch.onThumbTintColor = [UIColor whiteColor];
//    mySwitch.borderColor = blueButtonColor;
//    mySwitch.thumbTintColor = self.view.tintColor;
    mySwitch.inactiveColor = [UIColor colorWithRed: 227/255.0f green: 227/255.0f blue: 232/255.0f alpha:1.0f];
    mySwitch.onTintColor = blueButtonColor;
    mySwitch.onLabel.text = @" Done";
    mySwitch.onLabel.textColor = backgroundColor;
    mySwitch.shadowColor = [UIColor clearColor];

    NSLog(@"offlabel text width: %f", mySwitch.offLabel.frame.size.width);
    [mySwitch setOn:NO animated:YES];
    mySwitch.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithCustomView: mySwitch];
    
    int i = 3;
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] init];
    segmentControl.frame = CGRectMake(0, 0, w * i, h);
    segmentControl.backgroundColor = backgroundColor;
//    segmentControl.backgroundColor = [UIColor clearColor];
    segmentControl.layer.cornerRadius = 0.0f;
    segmentControl.layer.borderColor = backgroundColor.CGColor;
//    segmentControl.layer.borderColor = [UIColor clearColor].CGColor;
    segmentControl.layer.borderWidth = 2.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, segmentControl.frame.size.height), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [segmentControl setDividerImage:blank
                forLeftSegmentState:UIControlStateNormal
                  rightSegmentState:UIControlStateNormal
                         barMetrics:UIBarMetricsDefault];
    segmentControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
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
    UIImage *starImgHilighted = [starImg makeImageWithBackgroundColor: self.view.tintColor andForegroundColor:backgroundColor];
    [starButton setImage:starImg forState:UIControlStateNormal];
    [starButton setImage:starImgHilighted forState:UIControlStateHighlighted];
    [starButton addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    starButton.frame = CGRectMake(0, 0, w, h);
    starButton.layer.cornerRadius = 5;
    starButton.tintColor = self.view.tintColor;
    starButton.layer.borderWidth = 0;
    starButton.layer.masksToBounds = YES;
    [starButton.layer setBorderColor: [self.view.tintColor CGColor]];
    
    starButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    starButton.autoresizesSubviews = YES;
    
    UIBarButtonItem *starBarItem = [[UIBarButtonItem alloc]initWithCustomView:starButton];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width + 30, h+2)];
//    toolbar.backgroundColor = self.backgroundColor;
    toolbar.translucent = NO;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *negativeSpacer30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer30 setWidth:-30];
    UIBarButtonItem *negativeSpacer10 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer10 setWidth:-10];
    UIBarButtonItem *negativeSpacer5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer5 setWidth:-5];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    [toolbar setItems:@[backBarItem, flexibleSpace, searchBarItem, editBarItem, negativeSpacer5, segmentControlBarItem, flexibleSpace, negativeSpacer5, starBarItem] animated:YES];
    
    [toolbar setItems:@[flexibleSpace, editBarItem, flexibleSpace] animated:YES];
    
    UIBarButtonItem *toolBarItem = [[UIBarButtonItem alloc] initWithCustomView: toolbar];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer30, toolBarItem];
    //    self.navigationController.navigationBar.backgroundColor = self.backgroundColor;
    [self.navigationController.navigationBar setTranslucent: NO];  // NOTE: Changing this parameter affects positioning, weird.

}

- (void) __addSubmenu
{
    NSMutableArray *buttonList = [[NSMutableArray alloc] init];
    float h = 40;
    float w = 40;
    float padding = 10;
    float paddingTop = 4;
    int n = 25;
    int nLeftButtons = 1;
    int nSegmentControl = 7;
    int nStyleButtons = 2;
    int nInsertButtons = 3;
    int paddingCounter = 1;
    UIColor *backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
    UIColor *darkGrayBorderColor = [UIColor colorWithRed: 174/255.0f green: 174/255.0f blue: 174/255.0f alpha:1.0f];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, - (h + 2 * padding), [[UIScreen mainScreen] bounds].size.width, h + 2 * paddingTop);
//    scrollView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, h + 2 * paddingTop);
    scrollView.contentSize = CGSizeMake((w + padding) * n, h);
    scrollView.backgroundColor = backgroundColor;
    [scrollView setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, scrollView.frame.size.height - 1.0f, scrollView.contentSize.width, 0.5f);
    bottomBorder.backgroundColor = [darkGrayBorderColor CGColor];
    [scrollView.layer addSublayer:bottomBorder];
    self.scrollViewButtonList = scrollView;
    self.scrollViewButtonList.delegate = self;
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
//                                             initWithTarget:self
//                                             action:@selector(panHandlerForScrollViewButtonList:)];
//    [self.scrollViewButtonList addGestureRecognizer: pan];
    
    int i = 0;
    UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *undoImg = [[UIImage imageNamed: @"undo-arrow"] imageWithExtraPadding: .15];
    undoImg = [undoImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *undoImgHilighted = [undoImg makeImageWithBackgroundColor: self.view.tintColor andForegroundColor:backgroundColor];
    
    [undoButton setImage:undoImg forState:UIControlStateNormal];
    [undoButton setImage:undoImgHilighted forState:UIControlStateHighlighted];
    
    [undoButton addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [undoButton setTitle:@"undo" forState:UIControlStateNormal];
    undoButton.frame = CGRectMake(padding * (paddingCounter++) + ( (i-0) * w), paddingTop, w, h);
    undoButton.layer.cornerRadius = 5;
    undoButton.tintColor = self.view.tintColor;
    undoButton.layer.borderWidth = 1;
    undoButton.layer.masksToBounds = YES;
    [undoButton.layer setBorderColor: [self.view.tintColor CGColor]];
    [scrollView addSubview: undoButton];
    
    // TODO create array of button model objects (e.g. name, image, tag number, action, visible)
    i = nLeftButtons;
    SegmentedControlMod *segmentControl = [[SegmentedControlMod alloc] init];
    self.segmentControlVisualItem = segmentControl;
    [segmentControl addTarget:self action:@selector(segmentChangeViewValueChanged) forControlEvents:UIControlEventValueChanged];
    
    segmentControl.frame = CGRectMake(padding * paddingCounter++ + w * (i + 0), paddingTop, w * nSegmentControl, h);
    segmentControl.backgroundColor = backgroundColor;
    
    segmentControl.layer.cornerRadius = 5.0;
    for (int i = 0; i < nSegmentControl; i++) {
        [segmentControl insertSegmentWithTitle:[@(i) stringValue] atIndex:i animated:NO];
    }
    
    UIImage *leftRightUpDown = [[UIImage imageNamed: @"leftRightUpDown"] imageWithExtraPadding: 0.1f];
    [segmentControl setMyTitle:@"move" forSegmentAtIndex:0];
    [segmentControl setImage: leftRightUpDown forSegmentAtIndex: 0];
    
    UIImage *cursorClick = [[UIImage imageNamed: @"cursorClick.png"] imageWithExtraPadding: .1];
    [segmentControl setMyTitle:@"pointer" forSegmentAtIndex: 1];
    [segmentControl setImage: cursorClick forSegmentAtIndex: 1];
    
    UIImage *textLetter = [[UIImage imageNamed: @"textLetter.png"] imageWithExtraPadding: 0];
    [segmentControl setMyTitle:@"note" forSegmentAtIndex:2];
    [segmentControl setImage: textLetter forSegmentAtIndex: 2];
    
    UIImage *groupRectangle = [[UIImage imageNamed: @"groupRectangle"] imageWithExtraPadding: .15];
    [segmentControl setMyTitle:@"group" forSegmentAtIndex:3];
    [segmentControl setImage: groupRectangle forSegmentAtIndex: 3];
    
    UIImage *arrow = [[UIImage imageNamed: @"Archers-Arrowhead"] imageWithExtraPadding: .15];
    [segmentControl setMyTitle:@"arrow" forSegmentAtIndex:4];
    [segmentControl setImage: arrow forSegmentAtIndex: 4];
    
    UIImage *pen = [[UIImage imageNamed: @"Sign Up-50"] imageWithExtraPadding: .15];
    [segmentControl setImage: pen forSegmentAtIndex: 5];
    
    UIImage *conversation = [[UIImage imageNamed: @"conversation-with-text-lines"] imageWithExtraPadding: .15];
    [segmentControl setImage: conversation forSegmentAtIndex: 6];
    
//    [segmentControl removeSegmentAtIndex:0 animated:NO];
    [segmentControl setSelectedSegmentIndex:1];
    [scrollView addSubview: segmentControl];
    
    i = nLeftButtons + nSegmentControl;
    SegmentedControlMod *segmentControlFont = [[SegmentedControlMod alloc] init];
    self.segmentControlFormattingOptions = segmentControlFont;
    [segmentControlFont addTarget:self action:@selector(segmentControlFontClicked:) forControlEvents:UIControlEventValueChanged];
//    [segmentControlFont addTarget:self action:@selector(segmentControlFontTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    segmentControlFont.frame = CGRectMake(padding * (nLeftButtons + 2) + w * (i + 0), paddingTop, w * 2, h);
    segmentControlFont.backgroundColor = backgroundColor;
    segmentControlFont.layer.cornerRadius = 5.0;
    for (int i = 0; i < 2; i++) {
        [segmentControlFont insertSegmentWithTitle:[@(i) stringValue] atIndex:i animated:NO];
    }
    
    UIImage *fontSize = [[UIImage imageNamed: @"fontSize"] imageWithExtraPadding: .1];
    [segmentControlFont setImage: fontSize forSegmentAtIndex: 0];
    [segmentControlFont setMyTitle:@"fontSize" forSegmentAtIndex:0];
    
    UIImage *fontColor = [[UIImage imageNamed: @"Paint Bucket-50"] imageWithExtraPadding: .25];
    [segmentControlFont setImage: fontColor forSegmentAtIndex: 1];
    [segmentControlFont setMyTitle:@"color" forSegmentAtIndex:1];
    
    [segmentControlFont setSelectedSegmentIndex:-1];
    [scrollView addSubview: segmentControlFont];
    
    i = nLeftButtons + nSegmentControl + nStyleButtons;
    UISegmentedControl *segmentControlInsert = [[UISegmentedControl alloc] init];
    segmentControlInsert.frame = CGRectMake(padding * 4 + w * (i + 0), paddingTop, w * 3, h);
    segmentControlInsert.backgroundColor = backgroundColor;
    segmentControlInsert.layer.cornerRadius = 5.0;
    for (int i = 0; i < 3; i++) {
        [segmentControlInsert insertSegmentWithTitle:[@(i) stringValue] atIndex:i animated:NO];
    }
    
    UIImage *picture = [[UIImage imageNamed: @"picture"] imageWithExtraPadding: .1];
    [segmentControlInsert setImage: picture forSegmentAtIndex: 0];
    
    UIImage *camera = [[UIImage imageNamed: @"photo-camera"] imageWithExtraPadding: .1];
    [segmentControlInsert setImage: camera forSegmentAtIndex: 1];
    
    UIImage *file = [[UIImage imageNamed: @"Attach-50"] imageWithExtraPadding: .1];
    [segmentControlInsert setImage: file forSegmentAtIndex: 2];
    
    [segmentControlInsert setSelectedSegmentIndex:-1];
    [scrollView addSubview: segmentControlInsert];
    
    i = nLeftButtons + nSegmentControl + nStyleButtons + nInsertButtons;
    
//    UIButton *trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *trashImg = [[UIImage imageNamed: @"Trash-50"] imageWithExtraPadding: .15];
//    trashImg = [trashImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    UIImage *trashImgHilighted = [trashImg makeImageWithBackgroundColor:self.view.tintColor andForegroundColor:backgroundColor];
//    
//    [trashButton setImage:trashImg forState:UIControlStateNormal];
//    [trashButton setImage:trashImgHilighted forState:UIControlStateHighlighted];
//    
    self.trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    trashImg = [[UIImage imageNamed: @"Trash-50"] imageWithExtraPadding: 0.25];
    trashImg = [UIImage imageWithCGImage:trashImg.CGImage scale:1.0 orientation:trashImg.imageOrientation];
    trashImg = [trashImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    trashImgHilighted = [trashImg  makeImageWithBackgroundColor:self.view.tintColor andForegroundColor: backgroundColor];
    [self.trashButton setImage:trashImg forState:UIControlStateNormal];
    [self.trashButton setImage:trashImgHilighted forState:UIControlStateHighlighted];
    
    [self.trashButton addTarget:self
                    action:@selector(buttonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.trashButton setTitle:@"trash" forState:UIControlStateNormal];
    self.trashButton.frame = CGRectMake(padding * 5 + ( (i-0) * w), paddingTop, w, h);
    self.trashButton.layer.cornerRadius = 5;
    self.trashButton.tintColor = self.view.tintColor;
    self.trashButton.layer.borderWidth = 1;
    self.trashButton.layer.masksToBounds = YES;
    [self.trashButton.layer setBorderColor: [self.view.tintColor CGColor]];
    [scrollView addSubview: self.trashButton];
    
    //    for (int i = nLeftButtons + nSegmentControl + 2 + 2; i < n; i++) {
    //        UIButton *button = [[UIButton alloc] init];
    //        [button addTarget:self
    //                   action:@selector(buttonTapped:)
    //         forControlEvents:UIControlEventTouchUpInside];
    //        [button setTitle:[@(i) stringValue] forState:UIControlStateNormal];
    //        button.frame = CGRectMake((padding * (i - 2) ) + ( (i-1) * w), padding, w, h);
    //        button.backgroundColor = [UIColor greenColor];
    //        //        button.exclusiveTouch = YES;
    //        [scrollView addSubview: button];
    //        [buttonList addObject: button];
    //    }
    //    [scrollView setDelaysContentTouches:YES];
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    scrollView.contentSize = CGSizeMake(contentRect.size.width + padding, contentRect.size.height);
    float width = self.scrollViewButtonList.frame.size.width;
    float widthContent = self.scrollViewButtonList.contentSize.width;
    float newContentOffset = widthContent - width;
    scrollView.contentOffset = CGPointMake(newContentOffset, 0);
    
    [self.Background addSubview: scrollView];
    self.submenuScrollView = scrollView;
    
    //    [scrollView setHidden:YES];
}

- (void) addSubmenu
{
    NSMutableArray *buttonList = [[NSMutableArray alloc] init];
    float height = 44;
    float unit = 40;
    UIColor *backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
    
    SegmentedControlMod *segmentControl = [[SegmentedControlMod alloc] init];
    self.segmentControlVisualItem = segmentControl;
    [segmentControl addTarget:self action:@selector(segmentChangeViewValueChanged) forControlEvents:UIControlEventValueChanged];
    segmentControl.frame = CGRectMake(0, 0, 3 * unit, unit);
//    segmentControl.backgroundColor = backgroundColor;
    UIBarButtonItem *segmentControlItem = [[UIBarButtonItem alloc] initWithCustomView: segmentControl];

    UIImage *cursorClick = [[UIImage imageNamed: @"cursorClick.png"] imageWithExtraPadding: .1];
    [segmentControl insertSegmentWithImage:cursorClick atIndex:0 animated:YES];
    [segmentControl setMyTitle:@"pointer" forSegmentAtIndex: 0];
    [segmentControl setSelectedSegmentIndex: 0];
    
    UIImage *textLetter = [[UIImage imageNamed: @"textLetter.png"] imageWithExtraPadding: 0];
    [segmentControl insertSegmentWithImage:textLetter atIndex:1 animated:YES];
    [segmentControl setMyTitle:@"note" forSegmentAtIndex:1];
    
    UIImage *groupRectangle = [[UIImage imageNamed: @"groupRectangle"] imageWithExtraPadding: .15];
    [segmentControl insertSegmentWithImage:groupRectangle atIndex:2 animated:YES];
    [segmentControl setMyTitle:@"group" forSegmentAtIndex:2];
    
    SegmentedControlMod *segmentControlFont = [[SegmentedControlMod alloc] init];
    self.segmentControlFormattingOptions = segmentControlFont;
    [segmentControlFont addTarget:self action:@selector(segmentControlFontClicked:) forControlEvents:UIControlEventValueChanged];
    segmentControlFont.frame = CGRectMake(0, 0, unit, unit);
//    segmentControlFont.backgroundColor = backgroundColor;
    segmentControlFont.layer.cornerRadius = 5.0;
    segmentControlFont.autoresizingMask = UIViewAutoresizingNone;
    UIBarButtonItem *segmentControlFontItem = [[UIBarButtonItem alloc] initWithCustomView: segmentControlFont];

    UIImage *fontSize = [[UIImage imageNamed: @"fontSize"] imageWithExtraPadding: .1];
    fontSize = [fontSize imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [segmentControlFont insertSegmentWithImage:fontSize atIndex:0 animated:YES];
    [segmentControlFont setMyTitle:@"fontSize" forSegmentAtIndex:0];
    
    self.trashButton = [self makeButtonFromImage:@"Trash-50" buttonSize: unit andExtraPadding:0.25];
    [self.trashButton setTitle:@"trash" forState:UIControlStateNormal];
    self.trashButton.frame = CGRectMake(0, 0, unit, unit);
    [self.trashButton addTarget:self
                    action:@selector(buttonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *trashButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.trashButton];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    CGRect rect = CGRectMake(0, -height, [[UIScreen mainScreen] bounds].size.width, height);
    UIToolbar *toolbar2 = [[UIToolbar alloc] initWithFrame: rect];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, toolbar2.frame.size.height - 1.0f, toolbar2.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [darkGrayBorderColor CGColor];
//    [toolbar2.layer addSublayer:bottomBorder];
    toolbar2.autoresizesSubviews = NO;
    toolbar2.autoresizingMask = UIViewAutoresizingNone;
//    toolbar2.translucent = NO;
    toolbar2.backgroundColor = [UIColor whiteColor];

    [toolbar2 setItems:@[flexibleSpace, segmentControlItem, segmentControlFontItem, trashButtonItem, flexibleSpace]];
   
    [self.Background addSubview: toolbar2];
    self.submenu = toolbar2;
    
    
    //    [scrollView setHidden:YES];
}


- (void) addSecondSubmenu
{
    self.secondSubmenuScrollView = [[UIScrollView alloc] init];
    self.secondSubmenuScrollView.backgroundColor = backgroundColor;
    float h = 30;
//    float w = 40;
//    float padding = 10;
    float paddingTop = 4;
    
    float h0 = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float h1 = self.navigationController.navigationBar.frame.size.height;
    float h2 = self.submenu.frame.size.height;
    float y = h0 * 0 + h1 * 0 + h2;
    self.secondSubmenuScrollView.frame = CGRectMake(0, -y * 2, [[UIScreen mainScreen] bounds].size.width, h + paddingTop);
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.secondSubmenuScrollView.frame.size.height - 0.5f, self.secondSubmenuScrollView.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [darkGrayBorderColor CGColor];
    [self.secondSubmenuScrollView.layer addSublayer:bottomBorder];
    [self.Background addSubview: self.secondSubmenuScrollView];
    
    UIButton *decreaseFontSizeButton = [self makeButtonFromImage:@"Decrease Font Filled-50" buttonSize: h andExtraPadding:0.5];
    [decreaseFontSizeButton setTitle:@"decreaseFontSize" forState:UIControlStateNormal];
    UIBarButtonItem *decreaseFontSizeItem = [[UIBarButtonItem alloc] initWithCustomView: decreaseFontSizeButton];
    [decreaseFontSizeButton addTarget:self
                               action:@selector(decreaseFontSizeHandler:)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *increaseFontSizeButton = [self makeButtonFromImage:@"Increase Font Filled-50" buttonSize: h andExtraPadding:0.5];
    [increaseFontSizeButton setTitle:@"increaseFontSize" forState:UIControlStateNormal];
    UIBarButtonItem *increaseFontSizeItem = [[UIBarButtonItem alloc] initWithCustomView: increaseFontSizeButton];
    [increaseFontSizeButton addTarget:self
                               action:@selector(increaseFontSizeHandler:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer40 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer40 setWidth:80];
    
    CGRect rect = self.secondSubmenuScrollView.frame;
    rect.origin = CGPointZero;
    rect.size.height = rect.size.height - 0.5;
    UIToolbar *toolbar2 = [[UIToolbar alloc] initWithFrame: rect];
//    toolbar2.translucent = NO;
    [toolbar2 setItems:@[flexibleSpace, spacer40, decreaseFontSizeItem, increaseFontSizeItem, flexibleSpace]];

    self.secondSubmenuScrollView.delaysContentTouches = NO;
    [self.secondSubmenuScrollView addSubview: toolbar2];
//
//    UIBarButtonItem *negativeSpacer30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    [negativeSpacer30 setWidth:-30];
//    UIBarButtonItem *negativeSpacer10 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    [negativeSpacer10 setWidth:-10];
//    UIBarButtonItem *negativeSpacer5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    [negativeSpacer5 setWidth:-5];
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    
//    [toolbar setItems:@[backBarItem, flexibleSpace, searchBarItem, editBarItem, negativeSpacer5, segmentControlBarItem, flexibleSpace, negativeSpacer5, starBarItem] animated:YES];
}

- (void) resize
{
    CGFloat navBarHeight = self.navigationController.navigationBar.intrinsicContentSize.height;

    NSLog(@"\n here %f", navBarHeight);
    
    if ( [[UIScreen mainScreen] bounds].size.height < [[UIScreen mainScreen] bounds].size.width )  // landscape orientation
    {

//        float unit = self.navigationController.navigationBar.intrinsicContentSize.height;
//        SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 42 * 1.65, unit * 0.75)];
//        self.editSwitch;
//        self.editSwitch.autoresizesSubviews = YES;
//        CGRect rect = self.editSwitch.frame;
//        rect.size.height = 42 * 0.75;
//        self.editSwitch.shadowColor = [UIColor clearColor];
//        self.editSwitch.thumbTintColor = self.view.tintColor;
//        mySwitch.thumbTintColor = self.view.tintC
//        self.editSwitch.frame = rect;
//        self.editSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    }
}

- (void) decreaseFontSizeHandler: (UIButton *) button
{
    // TODO (Aug 19, 2016): update note font size of currently selected note (double-check that it's viewable on screen) and save to firebase
    
    NSLog(@"decreaseFontSizeButton title: %@", [button currentTitle]);
    NoteItem2 *ni = [self.lastSelectedObject getNoteItem];
    if ( (ni) && [self.lastSelectedObject isInBoundsOfView: self.BackgroundScrollView])
    {
        [ni decreaseFontSize];
        [self.visuallState updateChildValue:ni Property: @"fontSize"];
    }
    
}

- (void) increaseFontSizeHandler: (UIButton *) button
{
    NSLog(@"increaseFontSizeButton: %@", [button currentTitle]);
    NoteItem2 *ni = [self.lastSelectedObject getNoteItem];
    if ( (ni) && [self.lastSelectedObject isInBoundsOfView: self.BackgroundScrollView])
    {
        [ni increaseFontSize];
        [self.visuallState updateChildValue:ni Property: @"fontSize"];
    }
    
}

- (UIButton *) makeButtonFromImage: (NSString *) imageName buttonSize: (float) unit andExtraPadding: (float) padding
{
//    float unit = 40.0;
    UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *undoImg = [[UIImage imageNamed: imageName] imageWithExtraPadding: padding];
//    UIImage *undoImg = [UIImage imageNamed: imageName];
//    undoImg = [UIImage imageWithCGImage:undoImg.CGImage scale:1.5 orientation:undoImg.imageOrientation];
    undoImg = [undoImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *undoImgHilighted = [undoImg makeImageWithBackgroundColor: self.view.tintColor andForegroundColor: backgroundColor];
    [undoButton setImage:undoImg forState:UIControlStateNormal];
    [undoButton setImage:undoImgHilighted forState:UIControlStateHighlighted];
    undoButton.frame = CGRectMake(0, 0, unit, unit);  // TODO (Aug 12, 2016): change to constants e.g. BUTTON_WIDTH BUTTON_HEIGHT
    undoButton.layer.cornerRadius = 5;
    undoButton.tintColor = self.view.tintColor;
    undoButton.layer.borderWidth = 1;
    undoButton.layer.masksToBounds = YES;
    [undoButton.layer setBorderColor: [self.view.tintColor CGColor]];
    return undoButton;
}

- (void) showSecondSubmenu
{
    CGRect rect = self.secondSubmenuScrollView.frame;
//    rect.origin.y = fabs(rect.origin.y);
    rect.origin.y = self.submenu.frame.size.height;
    self.secondSubmenuScrollView.frame = rect;
}

- (void) hideSecondSubmenu
{
    CGRect rect = self.secondSubmenuScrollView.frame;
    rect.origin.y = self.submenu.frame.size.height * -2;
    self.secondSubmenuScrollView.frame = rect;
}

/*

 {
 float width = self.scrollViewButtonList.frame.size.width;
 float widthContent = self.scrollViewButtonList.contentSize.width;
 float newContentOffset = widthContent - width;
 NSLog(@"scrollViewButtonList width and content width: %f, %f", width, widthContent);
 
 if( ![[NSNumber numberWithFloat: self.scrollViewButtonList.contentOffset.x] isEqualToNumber:[NSNumber numberWithFloat: newContentOffset]] )
 {
 [UIView animateWithDuration:0.2
 delay:0.0
 options:UIViewAnimationOptionCurveEaseIn
 animations:^(void) {
 [self.scrollViewButtonList setContentOffset:CGPointMake(newContentOffset, 0)];
 }
 completion:NULL];
 }
 if ( [self trashButtonHitTest: gestureRecognizer] )
 {
 [self highlightTrashButton];
 } else {
 [self normalizeTrashButton];
 }
 }
 
 */

- (void) switchChanged:(id) sender
{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
        [self.visuallState setEditModeOn: YES];
        [self setSelectedObject: self.lastSelectedObject];
        [self.scrollViewButtonList setHidden: NO];
        
        CGRect rect = self.submenu.frame;
        
//        float h0 = [[UIApplication sharedApplication] statusBarFrame].size.height;
//        float h1 = self.navigationController.navigationBar.frame.size.height;
//        rect.origin.y = h0 + h1;
        rect.origin.y = 0;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             [self.submenu setFrame: rect];
                         }
                         completion:^(BOOL finished) {
                             //Completion Block
                             if ( !self.alreadyAnimated )
                             {
                                 self.alreadyAnimated = YES;
                                 [UIView animateWithDuration:1.8
                                                       delay:0.2
                                      usingSpringWithDamping:0.7
                                       initialSpringVelocity:3.6
                                                     options:UIViewAnimationOptionCurveEaseInOut animations:
                                                    ^{
                                                         self.scrollViewButtonList.contentOffset = CGPointMake(0, 0);
                                                     }
                                                  completion:^(BOOL finished)
                                                  {
                                                      if ( !(self.segmentControlFormattingOptions.selectedSegmentIndex == UISegmentedControlNoSegment) )
                                                      {
                                                          [self showSecondSubmenu];
                                                      }

                                                  }
                                  ];
                             } else
                             {
                                 if ( !(self.segmentControlFormattingOptions.selectedSegmentIndex == UISegmentedControlNoSegment) )
                                 {
                                     [self showSecondSubmenu];
                                 }
                             }
                         }
         ];
    }
    else
    {
        NSLog(@"Switch is OFF");
        [self.visuallState setEditModeOn: NO];
        [self setSelectedObject: self.lastSelectedObject];
        CGRect rect = self.submenu.frame;
        rect.origin.y = -rect.size.height;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             [self.submenu setFrame: rect];
                         }
                         completion:^(BOOL finished){
                             [self setNavigationBottomBorderColor: darkGrayBorderColor height: 0.5f];
//                             float width = self.scrollViewButtonList.frame.size.width;
//                             float widthContent = self.scrollViewButtonList.contentSize.width;
//                             float newContentOffset = widthContent - width;
//                             self.scrollViewButtonList.contentOffset = CGPointMake(newContentOffset, 0);
                         }];
        [self hideSecondSubmenu];
    }
}


- (void) setNavigationBottomBorderColor:(UIColor *)color height:(CGFloat) height
{
    return; // TODO (Aug 14, 2016): Figure out how to remove the built-in border from the nav bar
    UIView *oldBottomBorder = [self.navigationController.navigationBar viewWithTag:999];
    if (oldBottomBorder) {
        [oldBottomBorder removeFromSuperview];
    }
    CGRect bottomBorderRect = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame), CGRectGetWidth(self.navigationController.navigationBar.frame), height);
    UIView *bottomBorder = [[UIView alloc] initWithFrame:bottomBorderRect];
    bottomBorder.tag = 999;
    [bottomBorder setBackgroundColor: color];
    [self.navigationController.navigationBar addSubview:bottomBorder];
}

-(void) segmentChangeViewValueChanged
{
    
    NSString *segmentSelectedTitle =  [self.segmentControlVisualItem getMyTitleForSegmentAtIndex: (int) self.segmentControlVisualItem.selectedSegmentIndex];
    NSLog(@"segmentSelectedIndex: %li", self.segmentControlVisualItem.selectedSegmentIndex);
    NSLog(@"segmentSelectedTitle: %@", segmentSelectedTitle);
}

- (void) segmentControlFontClicked: (id) sender
{
    SegmentedControlMod *segmentedControlFont = (SegmentedControlMod *) sender;
    
    NSString *segmentSelectedTitle =  [segmentedControlFont getMyTitleForSegmentAtIndex: (int) segmentedControlFont.selectedSegmentIndex];
    NSLog(@"segmentSelectedIndex: %li", segmentedControlFont.selectedSegmentIndex);
    NSLog(@"segmentSelectedTitle: %@", segmentSelectedTitle);
    if ( [segmentedControlFont didValueChange] )
    {
        [self showSecondSubmenu];
    }
    else
    {
        segmentedControlFont.selectedSegmentIndex = UISegmentedControlNoSegment;
        [self hideSecondSubmenu];
    }

}

- (BOOL) isEditModeOn
{
    return [self.editSwitch isOn];
}

- (BOOL) isDrawGroupButtonSelected
{
    return [self.editSwitch isOn] && [[self.segmentControlVisualItem getMyTitleForCurrentlySelectedSegment] isEqualToString:@"group"];
}

- (BOOL) isNoteButtonSelected
{
    return [self.editSwitch isOn] && [[self.segmentControlVisualItem getMyTitleForCurrentlySelectedSegment] isEqualToString:@"note"];
}

- (BOOL) isPointerButtonSelected
{
    return [self.editSwitch isOn] && [[self.segmentControlVisualItem getMyTitleForCurrentlySelectedSegment] isEqualToString:@"pointer"];
}

- (BOOL) isArrowButtonSelected
{
    return [self.editSwitch isOn] && [[self.segmentControlVisualItem getMyTitleForCurrentlySelectedSegment] isEqualToString:@"arrow"];
}

- (BOOL) trashButtonHitTest: (UIGestureRecognizer *) gesture
{
    return [self.trashButton hitTest:[gesture locationInView: self.trashButton] withEvent:NULL];
}

- (void) highlightTrashButton
{
    [self.trashButton setImage:trashImgHilighted forState:UIControlStateNormal];
}

- (void) normalizeTrashButton
{
        [self.trashButton setImage:trashImg forState:UIControlStateNormal];
//    [trashButton sendActionsForControlEvents:UIControlEventTouchDragExit];
//    [trashButton sendActionsForControlEvents:UIControlEventTouchCancel];
//        [trashButton sendActionsForControlEvents:UIControlEvent
}


//if ([self.scrollViewButtonList hitTest:[gestureRecognizer locationInView: self.scrollViewButtonList] withEvent:NULL])
//{
//    return self.scrollViewButtonList;
//}


@end
