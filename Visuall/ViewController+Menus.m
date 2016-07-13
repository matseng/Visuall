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
#import "UISegmentedControl+MyTitle.h"

//@property UIScrollView *scrollViewButtonList;



@implementation ViewController (Menus)

SevenSwitch *editSwitch;
UISegmentedControl *segmentControlTopMenu;
UISegmentedControl *segmentControlSubmenu;

- (void) createTopMenu
{
    float h = 42;
    float w = 42;
    float padding = 10;
    UIColor *backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
    UIColor *blueButtonColor = self.view.tintColor;
    
    self.navigationItem.leftItemsSupplementBackButton = NO;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImg = [[UIImage imageNamed: @"back"] imageWithExtraPadding: .1];
    //    backImg = [UIImage imageNamed: @"back"];
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
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0, 85,44)];
    searchBar.placeholder = @"Search";
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc]initWithCustomView:searchBar];
    searchBarItem.tag = 123;
    
    SevenSwitch *mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, w * 1.65, h * 0.75)];
    editSwitch = mySwitch;
    mySwitch.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
    [mySwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
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
    segmentControlTopMenu = segmentControl;
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
    
    //    UIImage *reading = [self imageWithExtraPaddingFromImage:[UIImage imageNamed: @"Reading-50"] percentPadding: .1];
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
    [starButton setTitle:@"star" forState:UIControlStateNormal];
    starButton.frame = CGRectMake(0, 0, w, h);
    starButton.layer.cornerRadius = 5;
    starButton.tintColor = self.view.tintColor;
    starButton.layer.borderWidth = 0;
    starButton.layer.masksToBounds = YES;
    [starButton.layer setBorderColor: [self.view.tintColor CGColor]];
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
    
    //    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    //    self.navigationItem.leftBarButtonItems = @[negativeSpacer, negativeSpacer5, backBarItem, flexibleSpace, toolBarItem, flexibleSpace];
    self.navigationItem.leftBarButtonItems = @[negativeSpacer30, toolBarItem];
    
}

- (void) addHorizontalScrollingButtonList
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
    scrollView.contentSize = CGSizeMake((w + padding) * n, h);
    scrollView.backgroundColor = backgroundColor;
    [scrollView setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, scrollView.frame.size.height - 1.0f, scrollView.contentSize.width, 0.5f);
    bottomBorder.backgroundColor = [darkGrayBorderColor CGColor];
    [scrollView.layer addSublayer:bottomBorder];
    self.scrollViewButtonList = scrollView;
    
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
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] init];
    segmentControlSubmenu = segmentControl;
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
    [segmentControl setImage: groupRectangle forSegmentAtIndex: 3];
    
    UIImage *arrow = [[UIImage imageNamed: @"Archers-Arrowhead"] imageWithExtraPadding: .15];
    [segmentControl setImage: arrow forSegmentAtIndex: 4];
    
    UIImage *pen = [[UIImage imageNamed: @"Sign Up-50"] imageWithExtraPadding: .15];
    [segmentControl setImage: pen forSegmentAtIndex: 5];
    
    UIImage *conversation = [[UIImage imageNamed: @"conversation-with-text-lines"] imageWithExtraPadding: .15];
    [segmentControl setImage: conversation forSegmentAtIndex: 6];
    
//    [segmentControl removeSegmentAtIndex:0 animated:NO];
    [segmentControl setSelectedSegmentIndex:1];
    [scrollView addSubview: segmentControl];
    
    i = nLeftButtons + nSegmentControl;
    UISegmentedControl *segmentControlFont = [[UISegmentedControl alloc] init];
    segmentControlFont.frame = CGRectMake(padding * (nLeftButtons + 2) + w * (i + 0), paddingTop, w * 2, h);
    segmentControlFont.backgroundColor = backgroundColor;
    segmentControlFont.layer.cornerRadius = 5.0;
    for (int i = 0; i < 2; i++) {
        [segmentControlFont insertSegmentWithTitle:[@(i) stringValue] atIndex:i animated:NO];
    }
    
    UIImage *fontSize = [[UIImage imageNamed: @"fontSize"] imageWithExtraPadding: .1];
    [segmentControlFont setImage: fontSize forSegmentAtIndex: 0];
    
    UIImage *fontColor = [[UIImage imageNamed: @"Paint Bucket-50"] imageWithExtraPadding: .25];
    [segmentControlFont setImage: fontColor forSegmentAtIndex: 1];
    
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
    UIButton *trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *trashImg = [[UIImage imageNamed: @"Trash-50"] imageWithExtraPadding: .15];
    trashImg = [trashImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *trashImgHilighted = [trashImg makeImageWithBackgroundColor:self.view.tintColor andForegroundColor:backgroundColor];
    
    [trashButton setImage:trashImg forState:UIControlStateNormal];
    [trashButton setImage:trashImgHilighted forState:UIControlStateHighlighted];
    
    [trashButton addTarget:self
                    action:@selector(buttonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [trashButton setTitle:@"trash" forState:UIControlStateNormal];
    trashButton.frame = CGRectMake(padding * 5 + ( (i-0) * w), paddingTop, w, h);
    trashButton.layer.cornerRadius = 5;
    trashButton.tintColor = self.view.tintColor;
    trashButton.layer.borderWidth = 1;
    trashButton.layer.masksToBounds = YES;
    [trashButton.layer setBorderColor: [self.view.tintColor CGColor]];
    [scrollView addSubview: trashButton];
    
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
    
    [self.Background addSubview: scrollView];
    
    //    [scrollView setHidden:YES];
}

- (void) switchChanged:(id) sender
{
    if([sender isOn]){
        // Execute any code when the switch is ON
        [self.scrollViewButtonList setHidden: NO];
        
        CGRect rect = self.scrollViewButtonList.frame;
        rect.origin.y = 0;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             [self.scrollViewButtonList setFrame: rect];
                         }
                         completion:NULL];
        UIColor *backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
        [self setNavigationBottomBorderColor: backgroundColor height: 0.5f];
        
        NSLog(@"Switch is ON");
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
        //        [self.scrollViewButtonList setHidden: YES];
        CGRect rect = self.scrollViewButtonList.frame;
        rect.origin.y = -rect.size.height;
        UIColor *darkGrayBorderColor = [UIColor colorWithRed: 174/255.0f green: 174/255.0f blue: 174/255.0f alpha:1.0f];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             [self.scrollViewButtonList setFrame: rect];
                         }
                         completion:^(BOOL finished){
                             [self setNavigationBottomBorderColor: darkGrayBorderColor height: 0.5f];
                         }];
    }
}


- (void) setNavigationBottomBorderColor:(UIColor *)color height:(CGFloat) height {
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
    
    NSString *segmentSelectedTitle =  [segmentControlSubmenu getMyTitleForSegmentAtIndex: (int) segmentControlSubmenu.selectedSegmentIndex];
    NSLog(@"segmentSelectedIndex: %li", segmentControlSubmenu.selectedSegmentIndex);
    NSLog(@"segmentSelectedTitle: %@", segmentSelectedTitle);
}

- (BOOL) isEditModeOn
{
    return [editSwitch isOn];
}

- (BOOL) isDrawGroupButtonSelected
{
    return NO;
}

- (BOOL) isNoteButtonSelected
{
    return [editSwitch isOn] && [[segmentControlSubmenu getMyTitleForCurrentlySelectedSegment] isEqualToString:@"note"];
}

- (BOOL) isPointerButtonSelected
{
    return [editSwitch isOn] && [[segmentControlSubmenu getMyTitleForCurrentlySelectedSegment] isEqualToString:@"pointer"];
}


@end
