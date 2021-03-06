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
#import "UIBezierPath+arrowhead.h"
#import "ViewController+Group.h"
#import "UserUtil.h"
#import "SpeedReadingViewController.h"

@implementation ViewController (Menus) 

UIImage *trashImg;
UIImage *trashImgHilighted;
UIColor *backgroundColor;
UIColor *darkGrayBorderColor;
UITextView *sizeView;
float buttonUnit;
SegmentedControlMod *segmentControlTopMenuRight;

- (void) createTopMenu
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resize) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.buttonDictionary = [[NSMutableDictionary alloc] init];
    
    float h = 42;
    float w = 42;
    float padding = 10;
    buttonUnit = 42;
    if ( [[UIScreen mainScreen] bounds].size.width < 375.0 )
    {
        buttonUnit = buttonUnit * [[UIScreen mainScreen] bounds].size.width / 375.0;  // Resize submenu for iPhone SE
    }
    int numberOfButtons = 9;

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
    
//    SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, w * 1.65, h * 0.75)];
    float h1 = self.navigationController.navigationBar.frame.size.height;
    SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, w * 1.65, h1 * 0.75)];
    self.editSwitch = mySwitch;
    mySwitch.center = CGPointMake(self.view.bounds.size.width * 0.5, h1 * 0.5);
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
    
//    int i = 3;
    int i = 1;
    segmentControlTopMenuRight = [[SegmentedControlMod alloc] init];
    segmentControlTopMenuRight.frame = CGRectMake(0, 0, buttonUnit * i, buttonUnit);
//    segmentControl.backgroundColor = backgroundColor;
    segmentControlTopMenuRight.backgroundColor = [UIColor clearColor];
    segmentControlTopMenuRight.layer.cornerRadius = 0.0f;
    segmentControlTopMenuRight.layer.borderColor = backgroundColor.CGColor;
//    segmentControl.layer.borderColor = [UIColor clearColor].CGColor;
    segmentControlTopMenuRight.layer.borderWidth = 2.0f;
    segmentControlTopMenuRight.layer.borderColor = [[UIColor clearColor] CGColor];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, segmentControlTopMenuRight.frame.size.height), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [segmentControlTopMenuRight setDividerImage:blank
                forLeftSegmentState:UIControlStateNormal
                  rightSegmentState:UIControlStateNormal
                         barMetrics:UIBarMetricsDefault];
    segmentControlTopMenuRight.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [segmentControlTopMenuRight addTarget:self
                         action:@selector(segmentControlTopMenuRightHandler)
               forControlEvents: UIControlEventValueChanged];
    
//    UIImage *reading = [UIImage imageNamed: @"Reading-50"];
//    reading = [UIImage imageWithCGImage:reading.CGImage scale:1.7 orientation:reading.imageOrientation];
//    reading = [reading imageWithRoundedCornersSize:5.0f];
    UIImage *reading = [[UIImage imageNamed: @"Reading-50"] imageWithExtraPadding: .1];
    [segmentControlTopMenuRight insertSegmentWithImage:reading atIndex:0 animated:YES];
    [segmentControlTopMenuRight setEnabled:NO forSegmentAtIndex:0];
    segmentControlTopMenuRight.tintColor = [UIColor lightGrayColor];
    
    UIImage *sharing = [UIImage imageNamed: @"User Groups-50"];
    sharing = [UIImage imageWithCGImage:sharing.CGImage scale:1.5 orientation:sharing.imageOrientation];
//    [segmentControl insertSegmentWithImage:sharing atIndex:1 animated:YES];
    
    UIImage *info = [UIImage imageNamed: @"Info-50"];
    info = [UIImage imageWithCGImage:info.CGImage scale:1.7 orientation:info.imageOrientation];
//    [segmentControl insertSegmentWithImage:info atIndex:2 animated:YES];
    
    UIBarButtonItem *segmentControlBarItem = [[UIBarButtonItem alloc] initWithCustomView: segmentControlTopMenuRight];
    
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
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width + 30, h1)];
//    toolbar.backgroundColor = self.backgroundColor;
    toolbar.translucent = NO;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *spacer50 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer50 setWidth: buttonUnit / 2];
    UIBarButtonItem *negativeSpacer30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer30 setWidth:-30];
    UIBarButtonItem *negativeSpacer10 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer10 setWidth:-10];
    UIBarButtonItem *negativeSpacer5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer5 setWidth:-5];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    [toolbar setItems:@[backBarItem, flexibleSpace, searchBarItem, editBarItem, negativeSpacer5, segmentControlBarItem, flexibleSpace, negativeSpacer5, starBarItem] animated:YES];
    
    if (self.tabBarController.selectedIndex == 0)  // Public tab
    {
        [toolbar setItems:@[flexibleSpace, editBarItem, flexibleSpace, segmentControlBarItem, spacer50] animated:YES];
    }
    else
    {
        [toolbar setItems:@[backBarItem, flexibleSpace, editBarItem, flexibleSpace, segmentControlBarItem, spacer50] animated:YES];
    }
    
    UIBarButtonItem *toolBarItem = [[UIBarButtonItem alloc] initWithCustomView: toolbar];
//    CGRect rect = toolBarItem.width
    self.navigationItem.leftBarButtonItems = @[negativeSpacer30, toolBarItem];
    //    self.navigationController.navigationBar.backgroundColor = self.backgroundColor;
    [self.navigationController.navigationBar setTranslucent: NO];  // NOTE: Changing this parameter affects positioning, weird.
    
    if ( ![[[UserUtil sharedManager] getState] topMenuViews] )
    {
        [[[UserUtil sharedManager] getState] setTopMenuViews: [[NSMutableDictionary alloc] init]];
    }
    NSMutableDictionary *dict = [@{@"editSwitch": self.editSwitch} mutableCopy];
    StateUtilFirebase *state = [[UserUtil sharedManager] getState];
    state.topMenuViews = dict;
    NSMutableDictionary *md = [[[UserUtil sharedManager] getState] topMenuViews];
    SevenSwitch *ss = md[@"editSwitch"];
    NSLog(@"\n SegmentedControlMod: %@", [ss isOn] );
}

/*
 * Name:
 * Description:
 * http://stackoverflow.com/questions/25319179/uipopoverpresentationcontroller-on-ios-8-iphone
 */
- (void) segmentControlTopMenuRightHandler
{
    NSLog(@"\n segmentControlTopMenuRightHandler");
    ViewController *myNewVC = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"HelloWorld"];
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController: myNewVC];/*Here myNewVC is controller you want to show in popover*/
    float minLength = MIN(self.BackgroundScrollView.frame.size.width,
                          self.BackgroundScrollView.frame.size.height);
    NSLog(@"\n minLength: %f", minLength);

    myNewVC.preferredContentSize = CGSizeMake(300, 240);
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    
    self.dateTimePopover8 = destNav.popoverPresentationController;
    self.dateTimePopover8.delegate = self;
    self.dateTimePopover8.sourceView = self.view;
    self.dateTimePopover8.sourceRect = [self sourceRectForCenteredAlertController];
    self.dateTimePopover8.permittedArrowDirections = 0;

    CGRect rect = segmentControlTopMenuRight.frame;
    rect.origin = CGPointMake(rect.origin.x - buttonUnit / 2, rect.origin.y - buttonUnit);
    destNav.navigationBarHidden = YES;
    myNewVC.visuallState = self.visuallState;
    
    self.providesPresentationContextTransitionStyle = YES;
    [self presentViewController:destNav animated:YES completion:nil];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Check if your alert controller is still being presented
    if (self.dateTimePopover8.presentingViewController)
    {
        self.dateTimePopover8.sourceRect = [self sourceRectForCenteredAlertController];
    }
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller
{
    return UIModalPresentationNone;
}

-(void)hideIOS8PopOver
{
    [self dismissViewControllerAnimated:YES completion:nil];  // For future reference to prevent a modal from being dismissed: http://stackoverflow.com/questions/8317252/can-you-stop-a-modal-view-from-dismissing
}

- (void) popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [segmentControlTopMenuRight setEnabled:NO forSegmentAtIndex:0];
    [segmentControlTopMenuRight setEnabled:YES forSegmentAtIndex:0];
    segmentControlTopMenuRight.tintColor = [UIColor blueColor];
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    // do something now that it's been dismissed
    [segmentControlTopMenuRight setEnabled:YES forSegmentAtIndex:0];
    segmentControlTopMenuRight.tintColor = [UIColor blueColor];
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
    float unit = 38;  //  previously 40 with 8 buttons
    if ( [[UIScreen mainScreen] bounds].size.width < 375.0 )
    {
        unit = unit * [[UIScreen mainScreen] bounds].size.width / 375.0;  // Resize submenu for iPhone SE
    }
    int numberOfButtons = 9;

//    UIColor *backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
    
    SegmentedControlMod *segmentControl = [[SegmentedControlMod alloc] init];
    self.segmentControlVisualItem = segmentControl;
    [segmentControl addTarget:self action:@selector(segmentChangeViewValueChanged) forControlEvents:UIControlEventValueChanged];
    segmentControl.frame = CGRectMake(0, 0, 5 * unit, unit);
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
    
    UIImage *arrow = [[UIImage imageNamed: @"Archers-Arrowhead"] imageWithExtraPadding: .15];
    [segmentControl insertSegmentWithImage:arrow atIndex:3 animated:YES];
    [segmentControl setMyTitle:@"arrow" forSegmentAtIndex:3];
    
    UIImage *draw = [[UIImage imageNamed: @"Sign Up-50"] imageWithExtraPadding: .15];
    [segmentControl insertSegmentWithImage: draw atIndex:4 animated:YES];
    [segmentControl setMyTitle:@"draw" forSegmentAtIndex:4];
    
    SegmentedControlMod *segmentControlFont = [[SegmentedControlMod alloc] init];
    self.segmentControlFormattingOptions = segmentControlFont;
    [segmentControlFont addTarget:self action:@selector(segmentControlFontClicked:) forControlEvents:UIControlEventValueChanged];
    segmentControlFont.frame = CGRectMake(0, 0, unit, unit);
//    segmentControlFont.backgroundColor = backgroundColor;
    segmentControlFont.layer.cornerRadius = 5.0;
    segmentControlFont.autoresizingMask = UIViewAutoresizingNone;
    UIBarButtonItem *segmentControlFontItem = [[UIBarButtonItem alloc] initWithCustomView: segmentControlFont];

    UIImage *fontSize = [[UIImage imageNamed: @"changeSizePlusMinus"] imageWithExtraPadding: .1];
    fontSize = [fontSize imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [segmentControlFont insertSegmentWithImage:fontSize atIndex:0 animated:YES];
    [segmentControlFont setMyTitle:@"fontSize" forSegmentAtIndex:0];
    
    self.segmentControlInsertMedia = [[SegmentedControlMod alloc] init];
    [self.segmentControlInsertMedia addTarget:self action:@selector(segmentControlInsertMediaHandler:) forControlEvents:UIControlEventValueChanged];
    self.segmentControlInsertMedia.frame = CGRectMake(0, 0, 2 * unit, unit);
    [self.segmentControlInsertMedia setSelectedSegmentIndex: -1];
    UIBarButtonItem *segmentControlInsertMediaItem = [[UIBarButtonItem alloc] initWithCustomView: self.segmentControlInsertMedia];
    
    
    UIImage *insertPhoto = [[UIImage imageNamed: @"picture"] imageWithExtraPadding: .25];
//    insertPhoto = [insertPhoto makeImageWithBackgroundColor: [UIColor blackColor] andForegroundColor: [UIColor whiteColor]];
    [self.segmentControlInsertMedia insertSegmentWithImage:insertPhoto atIndex:0 animated:YES];
    [self.segmentControlInsertMedia setMyTitle:@"insertPhoto" forSegmentAtIndex: 0];
    
    UIImage *camera = [[UIImage imageNamed: @"photo-camera"] imageWithExtraPadding: .25];
    [self.segmentControlInsertMedia insertSegmentWithImage: camera atIndex:1 animated:YES];
    [self.segmentControlInsertMedia setMyTitle:@"camera" forSegmentAtIndex: 1];
    
    self.trashButton = [self makeButtonFromImage:@"Trash-50" buttonSize: unit andExtraPadding:0.25];
    [self.trashButton setTitle:@"trash" forState:UIControlStateNormal];
    self.trashButton.frame = CGRectMake(0, 0, unit, unit);
    [self.trashButton addTarget:self
                         action:@selector(buttonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(trashLongPress:)];
    [self.trashButton addGestureRecognizer:longPress];
    
    UIBarButtonItem *trashButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.trashButton];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *negativeSpacer30 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [negativeSpacer30 setWidth:-10];
    
    CGRect rect = CGRectMake(0, -height, [[UIScreen mainScreen] bounds].size.width, height);
    
    NSLog(@"\n [[UIScreen mainScreen] bounds].size.width: %f", [[UIScreen mainScreen] bounds].size.width);
    
    UIToolbar *toolbar2 = [[UIToolbar alloc] initWithFrame: rect];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, toolbar2.frame.size.height - 1.0f, toolbar2.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [darkGrayBorderColor CGColor];
    [toolbar2.layer addSublayer:bottomBorder];
    toolbar2.autoresizesSubviews = NO;
    toolbar2.autoresizingMask = UIViewAutoresizingNone;
    toolbar2.autoresizesSubviews = YES;
    toolbar2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [toolbar2 setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    toolbar2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    
    [toolbar2 setItems:@[flexibleSpace, segmentControlItem, segmentControlFontItem, segmentControlInsertMediaItem, trashButtonItem, flexibleSpace]];
    
    [self.Background addSubview: toolbar2];
    self.submenu = toolbar2;
    [[[[UserUtil sharedManager] getState] topMenuViews] setValue: self.segmentControlVisualItem forKey: @"segmentControlVisualItem"];

    SegmentedControlMod *scm = [[[UserUtil sharedManager] getState] topMenuViews][@"segmentControlVisualItem"];

        NSLog(@"\n SegmentedControlMod: %@", [scm getMyTitleForCurrentlySelectedSegment] );
    //    [scrollView setHidden:YES];
}


- (void) addSecondSubmenu
{
    self.secondSubmenuScrollView = [[UIScrollView alloc] init];
//    self.secondSubmenuScrollView.backgroundColor = backgroundColor;
    self.secondSubmenuScrollView.backgroundColor = [UIColor clearColor];
//    self.secondSubmenuScrollView.alpha = 0.8;
    
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
    
    UIButton *decreaseFontSizeButton = [self makeButtonFromImage:@"changeSizeMinus" buttonSize: h andExtraPadding:0.1];
    [self.buttonDictionary setObject: decreaseFontSizeButton forKey:@"decreaseFontSize"];
    [decreaseFontSizeButton setTitle:@"changeSizePlus" forState:UIControlStateNormal];
    UIBarButtonItem *decreaseFontSizeItem = [[UIBarButtonItem alloc] initWithCustomView: decreaseFontSizeButton];
    [decreaseFontSizeButton addTarget:self
                               action:@selector(decreaseFontSizeHandler:)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *increaseFontSizeButton = [self makeButtonFromImage:@"changeSizePlus" buttonSize: h andExtraPadding:0.1];
    [self.buttonDictionary setObject: increaseFontSizeButton forKey:@"increaseFontSize"];
    [increaseFontSizeButton setTitle:@"increaseFontSize" forState:UIControlStateNormal];
    UIBarButtonItem *increaseFontSizeItem = [[UIBarButtonItem alloc] initWithCustomView: increaseFontSizeButton];
    [increaseFontSizeButton addTarget:self
                               action:@selector(increaseFontSizeHandler:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    sizeView = [[UITextView alloc] init];  // defined at top of this file
    sizeView.editable = NO;
    sizeView.textAlignment = NSTextAlignmentCenter;
    sizeView.layer.borderWidth = 1.0f;
    sizeView.layer.borderColor = [self.view.tintColor CGColor];
    sizeView.layer.cornerRadius = 5.0f;
//    [sizeView setUserInteractionEnabled:NO];
    [self updateSizeViewFromSelectedVisualItem];
    UIBarButtonItem *sizeItem = [[UIBarButtonItem alloc] initWithCustomView: sizeView];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer setWidth: h * 2 + 10 - 15];
    
    CGRect rect = self.secondSubmenuScrollView.frame;
    rect.origin = CGPointZero;
    rect.size.height = rect.size.height - 0.5;
    UIToolbar *toolbar2 = [[UIToolbar alloc] initWithFrame: rect];
//    toolbar2.translucent = YES;
    [toolbar2 setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    
    [toolbar2 setBackgroundColor:[UIColor clearColor]];
    [toolbar2 setItems:@[flexibleSpace, spacer, decreaseFontSizeItem, sizeItem, increaseFontSizeItem, flexibleSpace]];

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

- (void) updateSecondSubmenuStateFromSelectedVisualItem
{
    [segmentControlTopMenuRight setEnabled:NO forSegmentAtIndex:0];
    segmentControlTopMenuRight.tintColor = [UIColor lightGrayColor];
    
    [self updateSizeViewFromSelectedVisualItem];
    if ( [self.visuallState.selectedVisualItem isNoteItem]
        || [self.visuallState.selectedVisualItem isArrowItem]
        || [self.visuallState.selectedVisualItem isDrawView])
    {
        [self setSecondSubmenuToActive:YES];
        
    }
    else
    {
        [self setSecondSubmenuToActive: NO];
    }

//    [self updateSizeViewFromSelectedVisualItem];
    
    // Speed Reading Button Style
    if ([self.visuallState.selectedVisualItem isGroupItem]
             || [self.visuallState.selectedVisualItem isNoteItem])
    {
        [segmentControlTopMenuRight setEnabled:YES forSegmentAtIndex:0];
        segmentControlTopMenuRight.tintColor = self.view.tintColor;
    }
    
}

- (void) setSecondSubmenuToActive: (BOOL) on
{
    if ( on )
    {
        // change size buttons in active state
        self.segmentControlFormattingOptions.tintColor = self.view.tintColor;
        [self enableButton:@"increaseFontSize"];
        [self enableButton:@"decreaseFontSize"];
        sizeView.textColor = self.view.tintColor;
        sizeView.layer.borderColor = [self.view.tintColor CGColor];
    }
    else
    {
        // change size buttons in inactive state
        self.segmentControlFormattingOptions.tintColor = [UIColor lightGrayColor];
        [self disableButton:@"increaseFontSize"];
        [self disableButton:@"decreaseFontSize"];
        sizeView.text = @"-";
        sizeView.textColor = [UIColor grayColor];
        sizeView.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

- (void) updateSizeViewFromSelectedVisualItem
{
    float size = [self.visuallState.selectedVisualItem getSize];
    if (size < 0)
    {
        size = [sizeView.text floatValue];
        sizeView.text = @"-";
        sizeView.textColor = [UIColor grayColor];
        sizeView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    else if (size < 1)
    {
        size = [sizeView.text floatValue];
        sizeView.text = [NSString stringWithFormat:@"%.0f", size];
        sizeView.textColor = [UIColor blueColor];
        sizeView.layer.borderColor = [self.view.tintColor CGColor];
    }
    else
    {
        sizeView.text = [NSString stringWithFormat:@"%.0f", size];
        sizeView.textColor = [UIColor blueColor];
        sizeView.layer.borderColor = [self.view.tintColor CGColor];
    }
    CGFloat fixedWidth = 35.0;
    CGSize newSize = [sizeView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = sizeView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    sizeView.frame = newFrame;
    
    if ( [self.visuallState.selectedVisualItem isNoteItem] )
    {
        self.visuallState.textFontSize = [self.visuallState.selectedVisualItem getSize];
    }
    else if ( [self.visuallState.selectedVisualItem isArrowItem])
    {
        self.visuallState.arrowHeadSize = [self.visuallState.selectedVisualItem getSize];
    }
    else if ( [self.visuallState.selectedVisualItem isDrawView] )
    {
        self.visuallState.pathLineWidth = [self.visuallState.selectedVisualItem getSize];
    }
}


- (void) enableButton: (NSString *) buttonName
{
    UIButton *button = self.buttonDictionary[buttonName];
    if (button)
    {
        button.enabled = YES;
        [button.layer setBorderColor: [self.view.tintColor CGColor]];
    }
}

- (void) disableButton: (NSString *) buttonName
{
    UIButton *button = self.buttonDictionary[buttonName];
    if (button)
    {
        button.enabled = NO;
        [button.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    }
}

- (void) resize
{
    CGFloat navBarHeight = self.navigationController.navigationBar.intrinsicContentSize.height;

    CGRect rect = self.submenu.frame;
    float width = [[UIScreen mainScreen] bounds].size.width;
    rect.size.width = width;
    self.submenu.frame = rect;
    
    CGRect rect2 = self.secondSubmenuScrollView.frame;
    rect2.size.width = width;
    self.secondSubmenuScrollView.frame = rect2;
    
    UIToolbar *secondSubmenuToolbar = self.secondSubmenuScrollView.subviews[0];
    CGRect rect3 = secondSubmenuToolbar.frame;
    rect3.size.width = width;
    secondSubmenuToolbar.frame = rect3;
    
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
    NSLog(@"decreaseFontSizeButton title: %@", [button currentTitle]);
    if ( [self.visuallState.selectedVisualItem isNoteItem] )
    {
        NoteItem2 *ni = [self.visuallState.selectedVisualItem getNoteItem];
        [ni decreaseFontSize];
        [self.visuallState updateChildValue:ni Property: @"fontSize"];
    }
    else if ( [self.visuallState.selectedVisualItem isArrowItem])
    {
        ArrowItem *ai = [self.visuallState.selectedVisualItem getArrowItem];
        [ai decreaseSize];
        [self.visuallState updateChildValue: ai Property: nil];
    }
    else if ( [self.visuallState.selectedVisualItem isDrawView] )
    {
        PathItem *pi = [self.visuallState.selectedVisualItem getPathItem];
        [pi decreaseLineWidth];
        [[[[UserUtil sharedManager] getState] DrawView] highlightSelectedPath];
        [[[UserUtil sharedManager] getState] updateValuePath: pi];  // update to firebase
    }
    else // No visual item is selected. Increase size based on current selection (e.g. note, arror or draw path)
    {
        float fontSize;
        if ( [sizeView.text intValue] % 2 == 1 )
        {
            fontSize = [sizeView.text floatValue] - 1;
        }
        else
        {
            fontSize = [sizeView.text floatValue] - 2;
        }
        sizeView.text = [[NSNumber numberWithFloat: fontSize] stringValue];
        if ([self isNoteButtonSelected])
        {
            self.visuallState.textFontSize = fontSize;
        }
        else if ([self isArrowButtonSelected])
        {
            self.visuallState.arrowHeadSize = fontSize;
        }
        else if ([self isDrawButtonSelected])
        {
            self.visuallState.pathLineWidth = fontSize;
        }
        
    }
    [self updateSizeViewFromSelectedVisualItem];
}

- (void) increaseFontSizeHandler: (UIButton *) button
{
    NSLog(@"increaseFontSizeButton: %@", [button currentTitle]);
    
//    if ( (ni) && [self.visuallState.selectedVisualItem isInBoundsOfView: self.BackgroundScrollView])
    if ( [self.visuallState.selectedVisualItem isNoteItem] )
    {
        NoteItem2 *ni = [self.visuallState.selectedVisualItem getNoteItem];
        [ni increaseFontSize];
        [self.visuallState updateChildValue:ni Property: @"fontSize"];
        
    }
    else if ( [self.visuallState.selectedVisualItem isArrowItem])
    {
        ArrowItem *ai = [self.visuallState.selectedVisualItem getArrowItem];
        [ai increaseSize];
        [self.visuallState updateChildValue: ai Property: nil];
    }
    else if ( [self.visuallState.selectedVisualItem isDrawView] )
    {
        PathItem *pi = [self.visuallState.selectedVisualItem getPathItem];
        [pi increaseLineWidth];
        [[[[UserUtil sharedManager] getState] DrawView] highlightSelectedPath];
        [[[UserUtil sharedManager] getState] updateValuePath: pi];  // update to firebase
    }
    else // No visual item is selected. Increase size based on current selection (e.g. note, arror or draw path)
    {
        float fontSize;
        if ( [sizeView.text intValue] % 2 == 1 )
        {
            fontSize = [sizeView.text floatValue] + 1;
        }
        else
        {
            fontSize = [sizeView.text floatValue] + 2;
        }

        sizeView.text = [[NSNumber numberWithFloat: fontSize] stringValue];
        if ([self isNoteButtonSelected])
        {
            self.visuallState.textFontSize = fontSize;
        }
        else if ([self isArrowButtonSelected])
        {
            self.visuallState.arrowHeadSize = fontSize;
        }
        else if ([self isDrawButtonSelected])
        {
            self.visuallState.pathLineWidth = fontSize;
        }
        
    }
    [self updateSizeViewFromSelectedVisualItem];
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
    UIImage *undoImgDisabled = [undoImg makeImageWithBackgroundColor: [UIColor clearColor] andForegroundColor: [UIColor lightGrayColor]];
    [undoButton setImage:undoImg forState:UIControlStateNormal];
    [undoButton setImage:undoImgHilighted forState:UIControlStateHighlighted];
    [undoButton setImage: undoImgDisabled forState: UIControlStateDisabled];
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
//        UIView *temp = [self lastSelectedObject];
//        [self setSelectedObject: nil];
        [self setSelectedObject: self.visuallState.selectedVisualItem];
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
        [self setSelectedObject: self.visuallState.selectedVisualItem];
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
    NSLog(@"segmentSelectedTitle: %@", segmentSelectedTitle);
    
    if ( [segmentSelectedTitle isEqualToString:@"pointer"] )
    {
        [[self.view window] endEditing:YES];  // hide keyboard when dragging a note
        return;
    }

    [self setSelectedObject: nil];

    if ( [segmentSelectedTitle isEqualToString:@"note"] )
    {
        sizeView.text = [NSString stringWithFormat:@"%.0f", [self.visuallState textFontSize]];
        [self setSecondSubmenuToActive: YES];
    }
    else if ( [segmentSelectedTitle isEqualToString:@"group"] )
    {
        
    }
    else if ( [segmentSelectedTitle isEqualToString:@"arrow"] )
    {
        sizeView.text = [NSString stringWithFormat:@"%.0f", [self.visuallState arrowHeadSize]];
        [self setSecondSubmenuToActive: YES];
    }
    else if ( [segmentSelectedTitle isEqualToString:@"draw"] )
    {
        sizeView.text = [NSString stringWithFormat:@"%.0f", [self.visuallState pathLineWidth]];
        [self setSecondSubmenuToActive: YES];
    }
}

- (void) makeArrow
{
    CGPoint startPoint;
    CGPoint endPoint;
    CGFloat tailWidth;
    CGFloat headWidth;
    CGFloat headLength;
    UIBezierPath *path;
    
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGPoint pointInScreenCoords = CGPointMake( [[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height / 2);
    CGPoint pointInWindowCoords = [mainWindow convertPoint:pointInScreenCoords fromWindow:nil];
    startPoint = [self.ArrowsView convertPoint:pointInWindowCoords fromView:mainWindow];
    endPoint = CGPointMake( startPoint.x + 100, startPoint.y + 100 );
    
    [[UIColor redColor] setStroke];
    tailWidth = 4;
    headWidth = 8 * 3;
    headLength = 8 * 3;
    path = [UIBezierPath bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                                  toPoint:(CGPoint)endPoint
                                                tailWidth:(CGFloat)tailWidth
                                                headWidth:(CGFloat)headWidth
                                               headLength:(CGFloat)headLength];
    [path setLineWidth:2.0];
    [path stroke];
    
    
    CGRect rect = [self createGroupViewRect: startPoint withEnd: endPoint];
    UIView *arrowView = [[UIView alloc] initWithFrame: rect];
    
    CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
    [shapeView setPath: path.CGPath];
    [self.ArrowsView.layer addSublayer: shapeView];
}

- (CGRect) createGroupViewRect:(CGPoint)start withEnd:(CGPoint)end {
    float x1 = start.x < end.x ? start.x : end.x;
    float y1 = start.y < end.y ? start.y : end.y;
    
    float x2 = start.x < end.x ? end.x : start.x;
    float y2 = start.y < end.y ? end.y : start.y;
    
    float width = x2 - x1;
    float height = y2 - y1;
    
    return CGRectMake(x1, y1, width, height);
}

- (void) segmentControlInsertMediaHandler: (SegmentedControlMod *) segmentedControl
{
    
    NSString *segmentSelectedTitle =  [segmentedControl getMyTitleForSegmentAtIndex: (int) segmentedControl.selectedSegmentIndex];
    NSLog(@"segmentSelectedTitle: %@", segmentSelectedTitle);
    if ( [segmentSelectedTitle isEqualToString: @"insertPhoto"])
    {
        UITabBarController * tabBarController = (UITabBarController*) self.tabBarController;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [tabBarController presentViewController: picker animated:YES completion:nil];
        
    }
    else if ( [segmentSelectedTitle isEqualToString: @"camera"] )
    {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            [self.segmentControlInsertMedia setSelectedSegmentIndex: -1];
        } else
        {
            UITabBarController * tabBarController = (UITabBarController*) self.tabBarController;
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
//            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [tabBarController presentViewController:picker animated:YES completion:nil];
        }
        
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.segmentControlInsertMedia setSelectedSegmentIndex: -1];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
//    self.mainImageView.image = chosenImage;
//  create new note but insert with image instead of text
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGPoint pointInScreenCoords = CGPointMake( [[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height / 2);
    CGPoint pointInWindowCoords = [mainWindow convertPoint:pointInScreenCoords fromWindow:nil];
    CGPoint pointInViewCoords = [self.GroupsView convertPoint:pointInWindowCoords fromView:mainWindow];
    
    GroupItemImage *gii = [[GroupItemImage alloc] initGroupWithImage: chosenImage andPoint: pointInViewCoords];
    [self addGroupItemToMVC: gii];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.segmentControlInsertMedia setSelectedSegmentIndex: -1];
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

- (BOOL) isDrawButtonSelected
{
    return [self.editSwitch isOn] && [[self.segmentControlVisualItem getMyTitleForCurrentlySelectedSegment] isEqualToString:@"draw"];
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
//    [self.trashButton setImage:trashImg forState:UIControlStateNormal];
}

- (CGRect) sourceRectForCenteredAlertController
{
    CGRect sourceRect = CGRectZero;
    sourceRect.origin.x = CGRectGetMidX(self.view.bounds)-self.view.frame.origin.x/2.0;
    sourceRect.origin.y = CGRectGetMidY(self.view.bounds)-self.view.frame.origin.y/2.0;
    return sourceRect;
}

@end
