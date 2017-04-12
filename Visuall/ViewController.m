//
//  ViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import "ViewController.h"
#import "Note.h"
#import "NoteItem2.h"
#import "UIView+VisualItem.h"
#import "AppDelegate.h"
#import "TouchDownGestureRecognizer.h"
#import "SevenSwitch.h"
#import "UIImage+Extras.h"
#import "ViewController+Menus.h"
#import "ViewController+ViewHit.h"
#import "ViewController+panHandler.h"
#import "ViewController+TapHandler.h"
#import "ViewController+Group.h"
#import "StateUtilFirebase.h"
#import "StateUtilFirebase+Delete.h"
#import "UserUtil.h"
#import "TouchDownGestureRecognizer.h"
#import "ViewController+xmlParser.h"
#import "MyVisuallsViewController.h"

@interface ViewController () <UITextViewDelegate, UIGestureRecognizerDelegate, UITabBarControllerDelegate> {
    UIPinchGestureRecognizer *pinchGestureRecognizer; UITapGestureRecognizer *BackgroundScrollViewTapGesture;
}
//@property (strong, nonatomic) IBOutlet UIView *Background;

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property UIGestureRecognizer *panBackground;
@property NSManagedObjectContext *moc;
//@property (strong, nonatomic) IBOutlet UIView *GestureView;
@property CGPoint panBeginPoint;
@property (strong, nonatomic) IBOutlet UITextField *fontSize;
//@property CGRect totalBoundsRect;
@property CGPoint zoomOffsetPoint;

@end

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0
#define SELECTED_VIEW_BORDER_COLOR [[UIColor blueColor] CGColor]
#define SELECTED_VIEW_BORDER_WIDTH 2.0

@implementation ViewController {
    NSArray *recipes;
}

- (void) viewWillAppear:(BOOL)animated
{
//    [self restrictRotation:YES];  // http://stackoverflow.com/questions/31794317/how-can-i-lock-orientation-for-a-specific-view-an-objective-c-iphone-app-in-ios
    NSLog(@"\n viewWillAppear, %@", self.firebaseURL);
    
}

- (void) viewDidLoad
{
//    int count = self.navigationController.viewControllers.count;
//    MyVisuallsViewController *listVC = (MyVisuallsViewController *) self.navigationController.viewControllers[count - 2];
//    if (listVC.myGreenController.visuallState)
//    {
//        NSLog(@"\n will return here");
//    }
    if ( !self.firebaseURL) return;
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(addNoteToViewWithHandlersNotification:) name:@"addNoteToViewWithHandlers" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(addGroupToViewWithHandlersNotification:) name:@"addGroupToViewWithHandlers" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(allGroupsDidLoadHandler) name:@"allGroupsDidLoad" object:nil];  // http://www.numbergrinder.com/2008/12/patterns-in-objective-c-observer-pattern/
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(allNotesDidLoadHandler) name:@"allNotesDidLoad" object:nil];
    
    self.visuallState = [[StateUtilFirebase alloc] init];
    
    [self buildViewHierarchyAndMenus];
    
    NSLog(@"Firebase URL: %@", self.firebaseURL);  // TODO (Aug 17, 2016): In the future this value will be populated from the previous selection of a Visuall
    
    NSString *userID = [[UserUtil sharedManager] userID];
    
    [self.visuallState setUserID: userID];
    
    [self.visuallState setBackgroundScrollView: self.BackgroundScrollView];
    [self.visuallState setBoundsTiledLayerView: self.BoundsTiledLayerView];
    [self.visuallState setVisualItemsView: self.VisualItemsView];
    [self.visuallState setGroupsView: self.GroupsView];
    [self.visuallState setNotesView: self.NotesView];
    [self.visuallState setArrowsView: self.ArrowsView];
    [self.visuallState setDefaultSizes];
    
    [self.visuallState setCallbackPublicVisuallLoaded:^{
        //        [self loadAndUploadXML];
    }];
    
    //    if ( /* DISABLES CODE */ (NO) && self.tabBarController.selectedIndex == 0)  // Global tab
    if (self.tabBarController.selectedIndex == 0)  // Public tab
    {
        [self.visuallState loadPublicVisuallsList];
        //        [self loadAndUploadXML];
    }
    else
    {
        //        [self.visuallState loadVisuallsForCurrentUser];
        [self.visuallState loadVisuallFromKey: self.firebaseURL];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    self.visuallState.metadata = self.metadataTemp;
    if ( [self.metadataTemp objectForKey: @"isNewVisuall"] )
    {
        [self addNoteToBrandNewVisuall];
    }
}

- (void) addNoteToBrandNewVisuall
{
    /*
    [self.editSwitch setOn: YES animated: YES];
    [self switchChanged: self.editSwitch];
    */
    CGPoint point = CGPointMake(self.BoundsTiledLayerView.frame.size.width / 2,
                                self.BoundsTiledLayerView.frame.size.height / 4);
    NoteItem2 *newNote = [[NoteItem2 alloc] initNote: self.metadataTemp[@"title"]
                                           withPoint: point];
    [self.visuallState setValueNote: newNote];  // TODO: add a callback to indicate if the note was sync'd successfully
    [self addNoteToViewWithHandlers:newNote];
//    CGRect rect = newNote.frame;
//    rect.origin = CGPointMake(rect.origin.x - rect.size.width / 2,  rect.origin.y);
//    newNote.frame = rect;
    [newNote translateTx: -newNote.frame.size.width / 2 andTy: -newNote.frame.size.height / 2];
    [self.visuallState updateChildValue: newNote Property: nil];  // save note coordinates
    [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
    [self setSelectedObject:newNote];
    /*
    BOOL accept = [newNote becomeFirstResponder];  // puts cursor on text field
    NSLog(@"\n addNoteToBrandNewVisuall, first responder: %s", accept ? "true" : "false");
    [newNote.noteTextView selectAll:nil];  // selects all text
     */
}

- (void) allGroupsDidLoadHandler
{
    [self refreshGroupsView];
    [self centerScrollViewContents2];
    [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
    self.BoundsTiledLayerView.frame = CGRectUnion(self.BoundsTiledLayerView.frame, self.BackgroundScrollView.frame);
     CGRect rect = [self.BoundsTiledLayerView convertRect: self.totalBoundsRect fromView:self.VisualItemsView];
     [self.BackgroundScrollView zoomToRect: rect animated:YES];
}

- (void) allNotesDidLoadHandler
{
    [self centerScrollViewContents2];
    [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
    CGRect rect = [self.BoundsTiledLayerView convertRect: self.totalBoundsRect fromView:self.VisualItemsView];
    CGRect minRect = self.BoundsTiledLayerView.frame;
    if (rect.size.width * rect.size.height < minRect.size.width * minRect.size.height)
    {
        rect.origin = CGPointMake(rect.origin.x - minRect.size.width / 2, rect.origin.y - minRect.size.height / 2);
        rect.size = minRect.size;
    }
    [self.BackgroundScrollView zoomToRect: rect animated:YES];
}

- (void) addNoteToViewWithHandlersNotification:(NSNotification*) notification
{
    if ([notification.name isEqualToString:@"addNoteToViewWithHandlers"])
    {
        NSDictionary* userInfo = notification.userInfo;
        NoteItem2 *ni = (NoteItem2*) userInfo[@"data"];
        [self addNoteToViewWithHandlers: ni];
    }
}

-(void) addGroupToViewWithHandlersNotification:(NSNotification*) notification
{
    if ([notification.name isEqualToString:@"addGroupToViewWithHandlers"])
    {
        NSDictionary* userInfo = notification.userInfo;
        GroupItem *gi = (GroupItem *) userInfo[@"data"];
        [[self.visuallState GroupsView] addSubview: gi];
        if ( !self.visuallState.groupsCollection ) self.visuallState.groupsCollection = [GroupsCollection new];
        [self.visuallState.groupsCollection addGroup: gi withKey: gi.group.key];
        [self calculateTotalBounds: gi];
    }
}

- (void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

/*
 * Name:
 * Description:
 *  - Background
 *    - BackgroundScrollView
 *      - BoundsTiledLayerView
 *        - VisualItemsView
 *          - GroupsView, ArrowsView, NotesView
 *
 */
- (void) buildViewHierarchyAndMenus
{
    [self.Background removeFromSuperview];
    self.view.backgroundColor = [UIColor whiteColor];
    self.Background = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
//    self.Background.backgroundColor = [UIColor redColor];
    [self.Background setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview: self.Background];
    [self constrainViewToSuperview: self.Background];
    
    self.BackgroundScrollView = [[ScrollViewMod alloc] init];
    self.BackgroundScrollView.backgroundColor = [UIColor whiteColor];
    [self initializeBackgroundScrollView];
    [self.BackgroundScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.Background addSubview: self.BackgroundScrollView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.BoundsTiledLayerView = [[TiledLayerView alloc] initWithFrame: self.BackgroundScrollView.frame];
//    self.BoundsTiledLayerView.backgroundColor = [UIColor purpleColor];
    self.BoundsTiledLayerView.backgroundColor = [UIColor whiteColor];
    
    self.VisualItemsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//    self.VisualItemsView.backgroundColor = [UIColor orangeColor];
    self.VisualItemsView.contentMode = UIViewContentModeRedraw;

    self.GroupsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.NotesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.NotesView.opaque = NO;
    self.ArrowsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    
    // this is the main view and used to show drawing from other users and let the user draw
     FDDrawView *DrawView = [[FDDrawView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    DrawView.delegate = self;
//    DrawView.backgroundColor  = [UIColor greenColor];
    [[[UserUtil sharedManager] getState] setDrawView: DrawView];
    
    // make sure it's resizable to fit any device size
    DrawView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.BackgroundScrollView addSubview: self.BoundsTiledLayerView];
    [self.BoundsTiledLayerView addSubview: self.VisualItemsView];
    [self.VisualItemsView addSubview: self.GroupsView];
    [self.VisualItemsView addSubview: self.NotesView];
    [self.VisualItemsView addSubview: self.ArrowsView];
    [self.VisualItemsView addSubview: DrawView];
    
    self.drawGroupView = [self initializeDrawGroupView];
    [self createTopMenu];
//    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
//    self.navigationController.navigationBar.tintColor = [UIColor redColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed: 249/255.0f green: 249/255.0f blue: 249/255.0f alpha:1.0f];
//    self.navigationController.navigationBar.translucent = NO;  // NOTE: Changing this parameter affects positioning, weird.
    [self addSubmenu];
    [self addSecondSubmenu];
    
    /*
    self.fontSize.delegate = self;
    [self.fontSize addTarget:self
                      action:@selector(fontSizeEditingChangedHandler:)
            forControlEvents:UIControlEventEditingChanged];
    */
    self.totalBoundsRect = CGRectZero;
    [self.Background setNeedsDisplay];
}

/*
 * Name: constrainViewToSuperview
 * Description: See http://matthewmorey.com/creating-uiviews-programmatically-with-auto-layout/
 */
- (void) constrainViewToSuperview: (UIView *) subView
{
    [self constrainWidthToSuperview: subView];
    
    UIView *parent = [subView superview];
    
    NSLayoutConstraint *height =[NSLayoutConstraint
                                constraintWithItem:subView
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:parent
                                attribute:NSLayoutAttributeHeight
                                multiplier:1.0f
                                constant:0.f];
    [parent addConstraint:height];
}

- (void) constrainWidthToSuperview: (UIView *) subView
{
    UIView *parent = [subView superview];
    
    NSLayoutConstraint *width =[NSLayoutConstraint
                                constraintWithItem:subView
                                attribute:NSLayoutAttributeWidth
                                relatedBy:NSLayoutRelationEqual
                                toItem:parent
                                attribute:NSLayoutAttributeWidth
                                multiplier:1.0f
                                constant:0.f];
    [parent addConstraint:width];
}

-(void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        [self resizeBackgroundScrollView];
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        [self resizeBackgroundScrollView];
    }
    [self expandBoundsTiledLayerView: 1.75];
}

- (void) resizeBackgroundScrollView
{
    
    float x = 0;
    float y = 0;
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float h0 = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float h1 = self.navigationController.navigationBar.frame.size.height;
    float h2 = self.tabBarController.tabBar.frame.size.height;
    height = height - h0 - h1 - h2;
    self.BackgroundScrollView.frame = CGRectMake(x, y, width, height);
}


- (void) initializeBackgroundScrollView
{
    [self resizeBackgroundScrollView];
    
    self.BackgroundScrollView.multipleTouchEnabled = YES;
    self.BackgroundScrollView.isZoomedToRect = NO;
    self.BackgroundScrollView.zoomFromDoubleTapGesture = NO;
    
    TouchDownGestureRecognizer *touchDown = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchDown:)];
    touchDown.delegate = self;
    [self.BackgroundScrollView addGestureRecognizer:touchDown];
    
    BackgroundScrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    BackgroundScrollViewTapGesture.delegate = self;
    [self.BackgroundScrollView addGestureRecognizer:BackgroundScrollViewTapGesture];

    
     UITapGestureRecognizer *tapGestureDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
     tapGestureDoubleTap.numberOfTapsRequired = 2;
    [self.BackgroundScrollView addGestureRecognizer:tapGestureDoubleTap];
    
    UITapGestureRecognizer *twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    twoFingerDoubleTap.numberOfTouchesRequired = 2;
    twoFingerDoubleTap.numberOfTapsRequired = 2;
    [self.BackgroundScrollView addGestureRecognizer:twoFingerDoubleTap];
    
    
    UIPanGestureRecognizer *panBackgroundScrollView = [[UIPanGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(panHandler:)];
//                                            action:nil];
    panBackgroundScrollView.cancelsTouchesInView = YES;
    panBackgroundScrollView.delaysTouchesBegan = YES;
    panBackgroundScrollView.delegate = self;
    self.panBackground = panBackgroundScrollView;
    [self.BackgroundScrollView addGestureRecognizer: panBackgroundScrollView];
    
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handlePinchBackground:)];
    pinchBackground.delegate = self;
//    pinchBackground.cancelsTouchesInView = YES;
    [self.BackgroundScrollView addGestureRecognizer:pinchBackground];
    
    /*
    CGRect rect = self.VisualItemsView.frame;
    rect = [[UIScreen mainScreen] bounds];
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor clearColor].CGColor;
    sublayer.frame = rect;
    sublayer.borderColor = [UIColor blueColor].CGColor;
    sublayer.borderWidth = 100.0;
    [self.NotesView.layer addSublayer:sublayer];
    NSLog(@"NoteView dimensions: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    */
    
    self.BackgroundScrollView.contentSize = CGSizeMake(self.BoundsTiledLayerView.frame.size.width, self.BoundsTiledLayerView.frame.size.height);
    self.BackgroundScrollView.minimumZoomScale = 0.01;
    self.BackgroundScrollView.maximumZoomScale = 10.0;
    self.BackgroundScrollView.delegate = self;  // REQUIRED to enable pinch to zoom
    self.automaticallyAdjustsScrollViewInsets = NO;
//    NSLog(@"NoteView dimensions: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void) drawView:(FDDrawView *)view didFinishDrawingPath:(FDPath *)path
{
    [self setSelectedObject: view];
}

- (void) centerScrollViewContents
{
    CGRect backgroudScrollViewBounds = self.BackgroundScrollView.bounds;
    CGRect boundsTiledLayerRect = self.BoundsTiledLayerView.frame;
    boundsTiledLayerRect.origin = CGPointMake(-backgroudScrollViewBounds.origin.x, backgroudScrollViewBounds.origin.y);
    
    NSLog(@"BackgroundScrollView origin: %f, %f", backgroudScrollViewBounds.origin.x, backgroudScrollViewBounds.origin.y);
    NSLog(@"boundsTiledLayerRect origin: %f, %f", boundsTiledLayerRect.origin.x, boundsTiledLayerRect.origin.y);
    
//    boundsTiledLayerRect.origin.x = boundsTiledLayerRect.origin.x - backgroudScrollViewBounds.origin.x;
//    boundsTiledLayerRect.origin.y = boundsTiledLayerRect.origin.y - backgroudScrollViewBounds.origin.y;
//    self.BoundsTiledLayerView.frame = boundsTiledLayerRect;

//    self.BackgroundScrollView.frame = boundsTiledLayerRect;
    self.BackgroundScrollView.contentOffset = boundsTiledLayerRect.origin;
}

- (void) __centerScrollViewContents
{
    
    CGRect backgroudScrollViewBounds = self.BackgroundScrollView.bounds;
    CGRect boundsTiledLayerRect = self.BoundsTiledLayerView.frame;
    
    NSLog(@"BackgroundScrollView origin: %f, %f", backgroudScrollViewBounds.origin.x, backgroudScrollViewBounds.origin.y);
    NSLog(@"boundsTiledLayerRect origin: %f, %f", boundsTiledLayerRect.origin.x, boundsTiledLayerRect.origin.y);
    
    if (boundsTiledLayerRect.size.width < backgroudScrollViewBounds.size.width) {
        boundsTiledLayerRect.origin.x = boundsTiledLayerRect.origin.x - self.BackgroundScrollView.bounds.origin.x;
    }
    
    if (boundsTiledLayerRect.size.height < backgroudScrollViewBounds.size.height) {
        boundsTiledLayerRect.origin.y = boundsTiledLayerRect.origin.y - self.BackgroundScrollView.bounds.origin.y;
    }
    self.BoundsTiledLayerView.frame = boundsTiledLayerRect;
}

/*
 * Name:
 * Description: Adds extra padding to the bounds rect to allow better scrolling and less buggy zooming out. 
 * If s = 2, that takes the bounds rect and adds two screen sizes to the width and height.
 */
- (CGRect) addExtraScrollPaddingToBoundsRect: (CGRect) rect byMultiple: (CGFloat) s
{
//    CGSize screenSize = self.BackgroundScrollView.frame.size;
    
    CGRect convertedBackgroundRectInScrollView = [self.BackgroundScrollView convertRect: self.Background.frame fromView: self.view];
    CGSize screenSize = convertedBackgroundRectInScrollView.size;
    CGRect newRect = CGRectMake(rect.origin.x - screenSize.width / 2 * s,
                                rect.origin.y - screenSize.height / 2 * s,
                                rect.size.width + screenSize.width * s,
                                rect.size.height + screenSize.height * s);
    return newRect;
}

- (void) expandBoundsTiledLayerView: (float) scale
{
    
    CGRect convertedVisualItemsRectInScrollView = [self.BackgroundScrollView convertRect: self.VisualItemsView.frame fromView: self.BoundsTiledLayerView];
    CGRect convertedBoundsRectInScrollView = [self.BackgroundScrollView convertRect: self.totalBoundsRect fromView: self.VisualItemsView];
    
    CGRect newBoundsTiledLayerRect = [self addExtraScrollPaddingToBoundsRect: convertedBoundsRectInScrollView byMultiple: scale];
    
//    newBoundsTiledLayerRect = CGRectUnion(newBoundsTiledLayerRect, convertedBoundsRectInScrollView);
    
    self.BoundsTiledLayerView.frame = newBoundsTiledLayerRect;
    
    self.BackgroundScrollView.contentSize = newBoundsTiledLayerRect.size;
    
    CGRect convertedVisualItemsRectInNewBoundsTiledLayerView = [self.BoundsTiledLayerView convertRect: convertedVisualItemsRectInScrollView fromView: self.BackgroundScrollView];
//    self.VisualItemsView.frame = convertedVisualItemsRectInNewBoundsTiledLayerView;
    self.VisualItemsView.frame = CGRectMake(convertedVisualItemsRectInNewBoundsTiledLayerView.origin.x,
                                            convertedVisualItemsRectInNewBoundsTiledLayerView.origin.y,
                                            1,
                                            1);
    
    UIEdgeInsets newContentInset = UIEdgeInsetsZero;
    CGSize newContentSize = newBoundsTiledLayerRect.size;
    if (newBoundsTiledLayerRect.origin.x < 0)
    {
        newContentInset.left = -newBoundsTiledLayerRect.origin.x;
        newContentSize.width = newBoundsTiledLayerRect.size.width + newBoundsTiledLayerRect.origin.x;
    }
    if (newBoundsTiledLayerRect.origin.y < 0)
    {
        newContentInset.top = -newBoundsTiledLayerRect.origin.y;
        newContentSize.height = newBoundsTiledLayerRect.size.height + newBoundsTiledLayerRect.origin.y;
    }
    self.BackgroundScrollView.contentInset = newContentInset;
    self.BackgroundScrollView.contentSize = newContentSize;
}

/*
 * Name: centerScrollViewContents2
 * Description: Prevents the content from automatically (and annoyingly) bouncing back to the origin of the scroll view
 */
- (void) centerScrollViewContents2
{
    CGPoint offsetPoint = CGPointMake(-self.BackgroundScrollView.bounds.origin.x, -self.BackgroundScrollView.bounds.origin.y);
    CGRect newBoundsTiledLayerViewRect = CGRectMake(self.BoundsTiledLayerView.frame.origin.x + offsetPoint.x,
                                                    self.BoundsTiledLayerView.frame.origin.y + offsetPoint.y,
                                                    self.BoundsTiledLayerView.frame.size.width,
                                                    self.BoundsTiledLayerView.frame.size.height);

    self.BoundsTiledLayerView.frame = newBoundsTiledLayerViewRect;

    self.BackgroundScrollView.bounds = CGRectMake(0,
                                                  0,
                                                  self.BackgroundScrollView.bounds.size.width,
                                                  self.BackgroundScrollView.bounds.size.height);
}

- (void) setNewScrollViewOuterContentsFrame
{
    CGPoint scrollViewCenter = CGPointMake(self.BackgroundScrollView.frame.origin.x + 0.5 * self.BackgroundScrollView.frame.size.width, self.BackgroundScrollView.frame.origin.y + 0.5 * self.BackgroundScrollView.frame.size.height);
    CGRect convertedBoundsRectInScrollView = [self.BackgroundScrollView convertRect: self.totalBoundsRect fromView: self.VisualItemsView];
    CGPoint convertedOriginOfVisualItemsRectInScrollView = [self.BackgroundScrollView convertPoint: self.VisualItemsView.frame.origin fromView: self.BoundsTiledLayerView];
    CGPoint farCornerPointRelativeToSrollViewCenter = [self findFarCornerPointOf: convertedBoundsRectInScrollView relativeToPoint: scrollViewCenter];
    CGPoint pointFar = CGPointMake(scrollViewCenter.x + farCornerPointRelativeToSrollViewCenter.x,
                                   scrollViewCenter.y + farCornerPointRelativeToSrollViewCenter.y);
    CGPoint pointFarFar = CGPointMake(scrollViewCenter.x + 2 * farCornerPointRelativeToSrollViewCenter.x,
                                   scrollViewCenter.y + 2 * farCornerPointRelativeToSrollViewCenter.y);
    CGRect rectFarFar = [self CGRectMakeFromPoint: pointFar andPoint:pointFarFar];
    CGRect newOuterContentsRect = CGRectUnion(self.BackgroundScrollView.frame, rectFarFar);
    self.BoundsTiledLayerView.frame = CGRectMake(0, 0, newOuterContentsRect.size.width, newOuterContentsRect.size.height);
    self.BackgroundScrollView.contentOffset = CGPointMake( newOuterContentsRect.origin.x, newOuterContentsRect.origin.y);
    
    CGPoint originOfVisualItemsInBoundsTiledLayerView = [self.BoundsTiledLayerView convertPoint: convertedOriginOfVisualItemsRectInScrollView fromView: self.BackgroundScrollView];
    self.VisualItemsView.frame = CGRectMake(originOfVisualItemsInBoundsTiledLayerView.x,
                                            originOfVisualItemsInBoundsTiledLayerView.y,
                                            self.VisualItemsView.frame.size.width,
                                            self.VisualItemsView.frame.size.height);
}

- (CGRect) CGRectMakeFromPoint: (CGPoint) p1 andPoint: (CGPoint) p2
{
    return CGRectMake(MIN(p1.x, p2.x),
                      MIN(p1.y, p2.y),
                      fabs(p1.x - p2.x),
                      fabs(p1.y - p2.y));
}

- (CGPoint) findFarCornerPointOf: (CGRect) rect relativeToPoint: (CGPoint) point
{
    float x;
    float y;
    
    float x0 = rect.origin.x - point.x;
    float x1 = (rect.origin.x + rect.size.width) - point.x;
    x = ( fabs(x0) > fabs(x1) ) ? x0 : x1;
    
    float y0 = rect.origin.y - point.y;
    float y1 = (rect.origin.y + rect.size.height) - point.y;
    y = ( fabs(y0) > fabs(y1) ) ? y0 : y1;
    
    return CGPointMake(x, y);  // (x, y) are RELATIVE to the given point
}

- (void) scrollViewWillBeginZooming:(UIScrollView *) scrollView withView:(UIView *)view
{
    return;
    float velocity = scrollView.pinchGestureRecognizer.velocity;
    if ( ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) && velocity < 0 )  // if ipad then proceed with this fix
    {
        [self expandBoundsTiledLayerView: 4];  // Adds 4 screen widths to the self.BackgroundScrollView
    }
}

- (void) scrollViewDidEndZooming:(UIScrollView *) scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self centerScrollViewContents2];
    [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
}

/*
 * Name: scrollViewDidZoom
 * Description: Attempt to fix zoom out behaivor which annoying changes the focal point when zooming out beyond the content size.
 */
- (void) scrollViewDidZoom:(UIScrollView *) scrollView
{
    return;  // behavoir below is too jumpy
    
    float velocity = scrollView.pinchGestureRecognizer.velocity;
    // if iphone (not ipad) then proceed with this fix
    if (([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) && velocity < 0 )
    {
    CGSize boundsSize = self.BackgroundScrollView.bounds.size;
    CGRect contentsFrame = self.BoundsTiledLayerView.frame;
    
    if ( contentsFrame.size.width  < boundsSize.width) {
//    if ( (contentsFrame.size.width + scrollView.contentInset.left + scrollView.contentInset.right)  < boundsSize.width) {
//        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
        contentsFrame.origin.x = (scrollView.bounds.size.width - scrollView.contentInset.left - scrollView.contentInset.right - contentsFrame.size.width) / 2.0f;
//        [self centerScrollViewContents2];
//        [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
    } else {
        contentsFrame.origin.x = 0.0f;
    }

    if ( contentsFrame.size.height < boundsSize.height) {
//    if ( (contentsFrame.size.height + scrollView.contentInset.top + scrollView.contentInset.bottom) < boundsSize.height) {
//        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
        contentsFrame.origin.y = (scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom - contentsFrame.size.height) / 2.0f;
//        [self centerScrollViewContents2];
//        [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
    } else {
        contentsFrame.origin.y = 0.0f;
    }

    self.BoundsTiledLayerView.frame = contentsFrame;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.BoundsTiledLayerView;
}

/*
 * Name: calculateTotalBounds
 * Description: Calculate the total bounds of the view items upon INITIAL loading of data
 */
- (void) calculateTotalBounds: (UIView *) view
{
//    self.BackgroundScrollView.zoomScale = 1.0;
//    
//    if ( self.totalBoundsRect.size.width == 0 )
//    {
//        self.totalBoundsRect = CGRectZero;
//    }

    if (CGRectIsEmpty( self.totalBoundsRect) )
    {
        self.totalBoundsRect = view.frame;
    }
    else
    {
        self.totalBoundsRect = CGRectUnion(self.totalBoundsRect, view.frame);
    }
    
//    [self expandBoundsTiledLayerView: 0];
    
//    self.BoundsTiledLayerView.frame = CGRectMake(0, 0, self.totalBoundsRect.size.width, self.totalBoundsRect.size.height);
//
////    self.BackgroundScrollView.contentSize = self.BoundsTiledLayerView.frame.size;
//    self.BackgroundScrollView.contentSize = self.totalBoundsRect.size;
//    float contentOriginX = -self.totalBoundsRect.origin.x;
//    float contentOriginY = -self.totalBoundsRect.origin.y;
//
//    self.VisualItemsView.frame = CGRectMake(contentOriginX, contentOriginY, 100, 100);
}

- (void) backButtonHandler
{
    ViewController *vc = (ViewController *)[self.navigationController popViewControllerAnimated:YES];
//    [vc removeFromParentViewController];
//    vc.BoundsTiledLayerView = nil;
//    vc.visuallState.BoundsTiledLayerView = nil;
//    vc.visuallState = nil;
//    vc = nil;
}

- (UIImage*) makeImageFromImage:(UIImage*) source withBackgroundColor: (UIColor *) backgroundColor andForegroundColor: (UIColor *) foregroundColor
{
//    const CGFloat margin = source.size.width * percentPadding;
//    CGSize size = CGSizeMake([source size].width + 2*margin, [source size].height + 2*margin);
    CGSize size = source.size;
    UIGraphicsBeginImageContext(size);
    
    [backgroundColor setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [foregroundColor setFill];
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *testImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}


- (UIImage*)imageWithExtraPaddingFromImage:(UIImage*) source percentPadding: (float) percentPadding
{
    const CGFloat margin = source.size.width * percentPadding;
    CGSize size = CGSizeMake([source size].width + 2 * margin, [source size].height + 2*margin);
    UIGraphicsBeginImageContext(size);
    
    [[UIColor clearColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    
    CGRect rect = CGRectMake(margin, margin, size.width-2*margin, size.height-2*margin);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *testImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

- (void) buttonTapped: (id) sender
{
    UIButton *button = (UIButton *) sender;
    NSLog(@"Button title: %@", [button currentTitle]);
    UIImage *imageNormal = [button imageForState: UIControlStateNormal];
    UIImage *imageHighlighted = [button imageForState:UIControlStateHighlighted];
    if (imageHighlighted) {
        [button setImage:imageHighlighted forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                        target:[NSBlockOperation blockOperationWithBlock:^{ [button setImage:imageNormal forState:UIControlStateNormal]; }]
                                       selector:@selector(main)
                                       userInfo:nil
                                        repeats:NO
         ];
        
    }
    if ( [button.currentTitle isEqualToString: @"trash"] )
    {
        [self trashButtonHandler];
    }
}

- (void) trashButtonHandler
{
    [self trashButtonHelper: (VisualItem *) self.visuallState.selectedVisualItem];
    /*
    if ([self.visuallState.selectedVisualItem isPartiallyInBoundsOfView: self.BackgroundScrollView])
    {
        if ([self.visuallState.selectedVisualItem isNoteItem])
        {
            NoteItem2 *ni = [self.visuallState.selectedVisualItem getNoteItem];
            [self.visuallState.notesCollection deleteNoteGivenKey: ni.note.key];
        }
        
        else if ([self.visuallState.selectedVisualItem isGroupItem])
        {
            GroupItem *gi = [self.visuallState.selectedVisualItem getGroupItem];
            [[self.visuallState groupsCollection] deleteGroupGivenKey: gi.group.key];
        }
        
        else if ( [self.visuallState.selectedVisualItem isArrowItem] )
        {
            ArrowItem *ai = [self.visuallState.selectedVisualItem getArrowItem];
            [self.visuallState.arrowsCollection deleteItemGivenKey: ai.key];
        }
        
        else if ( [self.visuallState.selectedVisualItem isDrawView] )
        {
            NSLog(@"\n TODO: delete PathItem");
            FDDrawView *dv = [self.visuallState.selectedVisualItem getDrawView];
            [self.visuallState removeValue: dv];
            [dv deleteSelectedPath];
            return;  // return here because we don't want to delete DrawView, rather we delete the selected path as above
        }
        
        [self.visuallState.selectedVisualItem removeFromSuperview];
        [self.visuallState removeValue: self.visuallState.selectedVisualItem];  // TODO (Aug 16, 2016): add a callback here... e.g. use to confirm item was deleted from Firebase, otherwise maybe keep the item in view?
        //        [self.lastSelectedObject delete:nil];  // TODO: untested
        //        self.lastSelectedObject = nil;

        [self normalizeTrashButton];
    }
     */
}

- (void) trashButtonHelper: (id) vi
{
    if ([vi isPartiallyInBoundsOfView: self.BackgroundScrollView])
    {
        if ([vi isNoteItem])
        {
            NoteItem2 *ni = [vi getNoteItem];
            [self.visuallState.notesCollection deleteNoteGivenKey: ni.note.key];
        }
        
        else if ([vi isGroupItem])
        {
            GroupItem *gi = [vi getGroupItem];
            [[self.visuallState groupsCollection] deleteGroupGivenKey: gi.group.key];
        }
        
        else if ( [vi isArrowItem] )
        {
            ArrowItem *ai = [vi getArrowItem];
            [self.visuallState.arrowsCollection deleteItemGivenKey: ai.key];
        }
        
        else if ( [vi isDrawView] )
        {
            NSLog(@"\n TODO: delete PathItem");
            FDDrawView *dv = [vi getDrawView];
            [self.visuallState removeValue: dv];
            [dv deleteSelectedPath];
            return;  // return here because we don't want to delete DrawView, rather we delete the selected path as above
        }
        
        
        [vi removeFromSuperview];
        [self.visuallState removeValue: vi];  // TODO (Aug 16, 2016): add a callback here... e.g. use to confirm item was deleted from Firebase, otherwise maybe keep the item in view?
        //        [self.lastSelectedObject delete:nil];  // TODO: untested
        //        self.lastSelectedObject = nil;
        
        [self normalizeTrashButton];
    }
}


- (void) trashLongPress: (UILongPressGestureRecognizer*) gesture
{
    NSMutableArray *visualItemsInGroup = [[NSMutableArray alloc] init];  // array to hold visual items to be deleted to avoid for loop mutation
    NSMutableArray *pathsInGroup = [[NSMutableArray alloc] init];  // array to hold visual items to be deleted to avoid for loop mutation
    
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
        NSLog(@"Long Press");
        if ([self.visuallState.selectedVisualItem isGroupItem])
        {
            GroupItem *gi = [self.visuallState.selectedVisualItem getGroupItem];
            
            [[self.visuallState groupsCollection] myForIn:^(GroupItem *giIter)
             {
                 if ([gi isGroupInGroup:giIter])
                 {
                     [visualItemsInGroup addObject: giIter];
                 }
             }];
            
            [[self.visuallState notesCollection] myForIn:^(NoteItem2 *ni)
             {
                 if ( [gi isNoteInGroup:ni]) {
                     [visualItemsInGroup addObject: ni];
                 }
                 
             }];
            
            [[[[UserUtil sharedManager] getState] arrowsCollection] myForIn:^(ArrowItem *ai)
            {
                if ([gi isArrowInGroup: ai]) {
                    [visualItemsInGroup addObject: ai];
                }
            }];

            [[[[UserUtil sharedManager] getState] pathsCollection] myForIn:^(PathItem *pi) {
                if ([gi isPathInGroup: pi])
                {
                    [pathsInGroup addObject:pi];
                }
            }];
            
            while (visualItemsInGroup.count > 0 )
            {
                VisualItem *giIter = visualItemsInGroup[0];
                [self trashButtonHelper: giIter];
                [visualItemsInGroup removeObjectAtIndex: 0];
            }
            
            FDDrawView *dv =  [[[UserUtil sharedManager] getState] DrawView];
            while (pathsInGroup.count > 0 )
            {
                PathItem *pi = pathsInGroup[0];
                dv.selectedPath = pi;
                [self trashButtonHelper: (VisualItem *) dv];
                [pathsInGroup removeObjectAtIndex: 0];
            }
            
            [self trashButtonHelper: gi];
            
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self findChildandTitleNotes];  // TODO: move this message elsewhere?
        UIView *view = [self getViewHit: gestureRecognizer];
        if (!view) {
            return;
        }
        [self.visuallState handleDoubleTapToZoom: gestureRecognizer andTargetView: view];
    }
}
 
- (void) findChildandTitleNotes
{

    [self.visuallState.notesCollection myForIn:^(NoteItem2 *ni)
     {
         [self.visuallState.groupsCollection myForIn:^(GroupItem *gi){
            if( [gi isNoteInGroup:ni] )  // note is within group bounds
            {
                if (![ni.note parentGroupKey]) {
                    [ni.note setParentGroupKey: gi.group.key];
                } else if ( [gi.group getArea] < [self.visuallState.groupsCollection getGroupAreaFromKey:[ni.note parentGroupKey]] )  // current group is smaller than previously assigned parent
                {
                    [ni.note setParentGroupKey: gi.group.key];  // set a note's most immediate parent
                }

                if ( !gi.group.titleNoteKey )
                {
                    [gi.group setTitleNoteKey: ni.note.key];
                    [ni.note setIsTitleOfParentGroup:YES];
                } else if ( ni.note.fontSize > [self.visuallState.notesCollection getNoteFontSizeFromKey: gi.group.titleNoteKey])
                {
                    Note2 *oldTitleNote = [self.visuallState.notesCollection getNoteFromKey:gi.group.titleNoteKey];
                    if (oldTitleNote) [oldTitleNote setIsTitleOfParentGroup:NO];
                    gi.group.titleNoteKey = ni.note.key;
                    [ni.note setIsTitleOfParentGroup: YES];
                    
                }
            }
         }];
     }];
}

- (void) fontSizeEditingChangedHandler: (UITextField *) textField
{
    NSLog(@"Font size: %@", self.fontSize.text);
    float fontSize = self.fontSize.text.floatValue;
    if (fontSize && [self.visuallState.selectedVisualItem isKindOfClass: [NoteItem2 class]])
    {
        NoteItem2 *ni = (NoteItem2 *) self.visuallState.selectedVisualItem;
        [ni setFontSize:fontSize];
        [self.visuallState transformVisualItem: ni];
    }
}

- (void) handleTouchDown:(TouchDownGestureRecognizer *) gestureRecognizer {
    UIView *viewHit = self.BoundsTiledLayerView.hitTestView;
    self.visuallState.touchDownPoint = [gestureRecognizer locationInView: self.visuallState.VisualItemsView];
//    NSLog(@"\n handleTouchDown viewHit %@", [viewHit class]);
    
    if ( [viewHit isEqual: self.scrollViewButtonList] )
    {
        return;
    }
    else if ( [viewHit isNoteItem] )
    {
        NoteItem2 *nv = [viewHit getNoteItem];
//        [self setActivelySelectedObjectDuringPan: nv];
        [self.visuallState setSelectedVisualItemDuringPan: nv];
        // [[self.view window] endEditing:YES];  // hide keyboard when dragging a note
    }
    else if ( [self isEditModeOn] && [viewHit isGroupItem])
    {
        UIView *handleSelected = [[viewHit getGroupItem] hitTestOnHandles:gestureRecognizer];
        if ( handleSelected )
        {
            [self.visuallState setSelectedVisualItemDuringPan: handleSelected];
            [[viewHit getGroupItem] setHandleSelected: handleSelected];
        }
//        else if ([viewHit isInBoundsOfView: self.BackgroundScrollView])
        else
        {
            GroupItem  *gi = [viewHit getGroupItem];
            [self.visuallState setSelectedVisualItemDuringPan: gi];
        }
    }
    else if ( [viewHit isArrowItem] )
    {
        [self.visuallState setSelectedVisualItemDuringPan: viewHit];
        [self.visuallState setSelectedVisualItemSubview: viewHit];
    }
    else if ( [viewHit isDrawView] )
    {
        [self.visuallState setSelectedVisualItemDuringPan: viewHit];
        [self.visuallState setSelectedVisualItemSubview: nil];
    }
    else
    {
        [self.visuallState setSelectedVisualItemDuringPan: nil];
    }
    
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass: [UIPinchGestureRecognizer class]])
    {
        return NO;
    }
    
    if( [gestureRecognizer isKindOfClass: [TouchDownGestureRecognizer class]])
    {
        return YES;
    }
    
    if ( [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
    {
        return YES;
    }
    
    if ([self isEditModeOn] && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] && [self.BoundsTiledLayerView.hitTestView isNoteItem])
    {
        return YES;  // NOTE: YES --> manually added gestureRecognizer receives the touch (not the UIScrollView)
    }
    
    if ( [self isEditModeOn]
        && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]]
        && ( [[self.BoundsTiledLayerView.hitTestView getGroupItem] isEqual: [self.visuallState.selectedVisualItem getGroupItem]] )
//        && [self.BoundsTiledLayerView.hitTestView isInBoundsOfView: self.BackgroundScrollView ])
//        && [self.BoundsTiledLayerView.hitTestView isPartiallyInBoundsOfView: self.BackgroundScrollView ]
        )
    {
        return YES;  // A group will receive a pan gesture only if it's has already been selected and fully in view
    }
    if ([self isEditModeOn] && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] && [self.BoundsTiledLayerView.hitTestView isArrowItem])
    {
        return YES;  // NOTE: YES --> manually added gestureRecognizer receives the touch (not the UIScrollView)
    }
    if ([self isEditModeOn] && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] && [self.BoundsTiledLayerView.hitTestView isDrawView])
    {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]])
    {
        return YES;
    }
    if( [self isDrawGroupButtonSelected] )
    {
        return YES;
    }
    if( [self isArrowButtonSelected] )
    {
        return YES;
    }
    
    /*
    CGSize boundsSize = self.BackgroundScrollView.bounds.size;
    CGRect contentsFrame = self.BoundsTiledLayerView.frame;
    if ([gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] && (contentsFrame.size.width < boundsSize.width || contentsFrame.size.height < boundsSize.height) )
    {
        return YES;
    }
    */
    
    return NO;
}


- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if( [gestureRecognizer isKindOfClass: [TouchDownGestureRecognizer class]] )
    {
        return YES;
    }
    return NO;
}

/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer: (UIGestureRecognizer *)otherGestureRecognizer{

    if ( ([gestureRecognizer.view isGroupItem] || [gestureRecognizer.view isNoteItem] ) && gestureRecognizer.numberOfTouches == 1)
    {
        if ( otherGestureRecognizer.view == self.BackgroundScrollView && otherGestureRecognizer.numberOfTouches == 1)
        {
            return NO;  // e.g. if panning on a group with 1 finger and panning on the scrollView with the same finger simultaneously, then actually don't allow the scroll to pan
        }
    }
    if ( [gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]] )
    {
        return NO;  // e.g. don't allow a simultaneous tap on a buried layer
    }

//    if ( [gestureRecognizer.view isGroupItem]  )
//    {
//        return  NO;  // e.g. avoid simultanous pan gesture on group handle and rest of group
//    }
    
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    if ( ([gestureRecognizer.view isGroupItem] || [gestureRecognizer.view isNoteItem] ) && (gestureRecognizer.numberOfTouches > 1 || otherGestureRecognizer.numberOfTouches > 1 ) )
    {
        return YES;  // e.g. if 2 fingers are making a gesture then don't allow a groupItem to move
    }
    
    return NO;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch
{

    UIView *view = gestureRecognizer.view;
    if ( ![self isEditModeOn] ) {
        if ([view isGroupItem] || [view isNoteItem])
        {
            if ([gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]] )
            {
                return YES;  // When edit mode if off, notes and groups can still receive tap gestures
            }
            return NO; // When edit mode if off, notes and groups can NOT receive pan or pinch gestures 
        }
    }

    
//    if ([view isGroupItem] && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] )
//    {
//        if ( ![view isInBoundsOfView:self.BackgroundScrollView] )
//        {
//            return NO;  // Only groups in view can receive a pan gesture
//        }
//    }
    
    return YES;
}

*/

- (void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    
    NSLog(@"Here is handlePinchBackground");
    [[self.view window] endEditing:YES];
    
//    self.BackgroundScrollView.maximumZoomScale = 1.0;
//    self.BackgroundScrollView.minimumZoomScale = 1.0;
//    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection andGroups: self.groupsCollection];
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        [self setTransformFirebase];
//    }
//    if ([[TransformUtil sharedManager] zoom] > 1.0){
//        [self.Background removeGestureRecognizer: self.panBackground];
//    } else if ( ![self.Background.gestureRecognizers containsObject:self.panBackground] ){
//        [self.Background addGestureRecognizer: self.panBackground];
//    }
}


/*
- (void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
{
    
    
    // HACKS
//    CGPoint location = [gestureRecognizer locationInView: gestureRecognizer.view];
    
//    CGPoint location = [gestureRecognizer locationInView: self.GestureView];
//    UIView *viewHit = [self.NotesView hitTest:location withEvent:NULL];
    
    UIView *viewHit = [self getViewHit:gestureRecognizer];
    
    NSLog(@"handlePanBackground viewHit %@", [viewHit class]);
    NSLog(@"gestureRecognizer %@", [gestureRecognizer.view class]);
    
    if ( [viewHit.superview isKindOfClass: [GroupItem class]] )
    {
        viewHit = viewHit.superview;
    }
    
//    if ( [viewHit respondsToSelector:@selector(handlePan2:)] ) {
    if ( [viewHit isKindOfClass:[ NoteItem2 class]] ) {
        NoteItem2 *nv = (NoteItem2 *) viewHit;
        [nv handlePan:gestureRecognizer];
        [self setSelectedObject:nv];
        return;
    } else if ( [viewHit isKindOfClass: [GroupItem class]] &&  self.modeControl.selectedSegmentIndex != 2) {
        GroupItem  *gi = (GroupItem *) viewHit;
        [self handlePanGroup:gestureRecognizer andGroupItem:gi];
        return;
    }
    // END HACKS
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Handle pan background began");
    }
    
    
    if (self.modeControl.selectedSegmentIndex == 1)
    {
        //noop
    }
    else if (self.modeControl.selectedSegmentIndex == 2)
    {
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            self.drawGroupViewStart = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            [self.GroupsView addSubview:self.drawGroupView];
        }
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
        }
        
        // State ended
//        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
//            ![self.lastSelectedObject isKindOfClass:[ NoteItem class]]
//            ) {
         if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
            
            // Make a copy of the current group view and add it to our list of group views
            float zoom = [[StateUtil sharedManager] zoom];
            GroupItem *currentGroupItem = [[GroupItem alloc]
                                           initWithPoint:[[StateUtil sharedManager] getGlobalCoordinate: self.drawGroupView.frame.origin]
                                            andWidth:self.drawGroupView.frame.size.width / zoom
                                            andHeight:self.drawGroupView.frame.size.height / zoom];
            
            [currentGroupItem saveToCoreData];
            [self addGestureRecognizersToGroup: currentGroupItem];
            
//            [self.groupsCollection addGroup:currentGroupItem];
            
            [self refreshGroupView];

            // set currentGroupItem as lastSelectedObject
            [self setSelectedObject:currentGroupItem];
        }
    }
    else
    {
        [[StateUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection withGroups: self.groupsCollection];
    }
}
*/

- (void) handleTapGroup: (UITapGestureRecognizer *) gestureRecognizer
{
    if (self.modeControl.selectedSegmentIndex == 2 || self.modeControl.selectedSegmentIndex == 3) {
        [self setSelectedObject:gestureRecognizer.view];
    }
    
    [self tapHandler: gestureRecognizer];  // tap group --> check to see if we should add a note
}

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem
{
    noteItem.noteTextView.delegate = self;
    noteItem.noteTextView.editable = NO;
    [noteItem transformVisualItem];
    [self.NotesView addSubview:noteItem];
    [self calculateTotalBounds: noteItem];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *) textView
{
    NSLog(@"textFieldShouldBeginEditing");
    if ( [textView getNoteItem] == self.visuallState.selectedVisualItem) {
        return YES;
    }
    return NO;
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
        if ([textView.text isEqualToString: @"text..."])
        {
            [[textView getNoteItem] becomeFirstResponder];
            [textView selectAll: nil];  // selects all text
        }
}

- (void) textViewDidChange:(UITextView *) textView
{
    NoteItem2 *ni = (NoteItem2 *) textView.superview;
    [ni resizeToFit: textView.text];
    ni.note.title = textView.text;
    [self.visuallState updateChildValue:ni Property:@"title"];
    [ni transformVisualItem];
}

- (void) textViewDidChangeSelection:(UITextView *)textView
{
    NoteItem2 *ni = [textView getNoteItem];
    if (self.visuallState.selectedVisualItem != ni)
    {
        [self setSelectedObject: ni];
    }
}

- (IBAction)onDeletePressed:(UIBarButtonItem *)sender {
    
    
    
//    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    
    //define cancel action
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        // noop
//    }];

    NSLog(@"Kill all humans");
    if (self.visuallState.selectedVisualItem) {
        NSLog(@"%@", self.visuallState.selectedVisualItem);
        NSManagedObject *objectToDelete;
        NSString *modalText;
        if ([self.visuallState.selectedVisualItem isKindOfClass:[NoteItem2 class]]) {
            NSLog(@"puplet");
//            NoteItem2 *noteToDelete = (NoteItem2 *)self.lastSelectedObject;
//            objectToDelete = [self.moc existingObjectWithID:noteToDelete.note.objectID error:nil];
            modalText = @"this note";
        } else if ([self.visuallState.selectedVisualItem isKindOfClass:[GroupItem class]]) {
            NSLog(@"woofarf");
            GroupItem *groupToDelete = (GroupItem *)self.visuallState.selectedVisualItem;
            
//            objectToDelete = [self.moc existingObjectWithID:groupToDelete.group.objectID error:nil];
            
            modalText = @"this group";
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", modalText] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self.visuallState.selectedVisualItem isKindOfClass:[NoteItem2 class]]) {
                    NoteItem2 *ni = (NoteItem2 *)self.visuallState.selectedVisualItem;
//                    [self removeValue:ni];
                    [self.visuallState.notesCollection deleteNoteGivenKey: ni.note.key];
                } else if ([self.visuallState.selectedVisualItem isKindOfClass:[GroupItem class]]) {
                    GroupItem *gi = (GroupItem *)self.visuallState.selectedVisualItem;
//                    [self removeValue:gi];
                    [self.visuallState.groupsCollection deleteGroupGivenKey: gi.group.key];

                }
                [self.visuallState.selectedVisualItem removeFromSuperview];
                self.visuallState.selectedVisualItem = nil;
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // noop
        }];
        
        [alertController addAction:alertAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL) setSelectedObject:(UIView *) object
{
    if (self.visuallState.selectedVisualItem) {
        if ([self.visuallState.selectedVisualItem isKindOfClass:[NoteItem2 class]])
        {
            NoteItem2 *ni = [self.visuallState.selectedVisualItem getNoteItem];
            ni.noteTextView.editable = NO;
            ni.noteTextView.selectable = NO;
            ni.layer.borderWidth = 0;
            self.visuallState.selectedVisualItem.layer.borderWidth = 0;
        } else if ([self.visuallState.selectedVisualItem isGroupItem])
        {
            [[self.visuallState.selectedVisualItem getGroupItem] setViewAsNotSelected];
        } else if ( [self.visuallState.selectedVisualItem isArrowItem] )
        {
            [[self.visuallState.selectedVisualItem getArrowItem] setViewAsNotSelected];
        }
        else if ( [self.visuallState.selectedVisualItem isDrawView] )
        {
            FDDrawView *dv = (FDDrawView *) self.visuallState.selectedVisualItem;
            [dv removeHighlightFromPreviouslySelectedPath];
        }
    }
    
    UIView *visualObject = [[UIView alloc] init];

    if ( [object isNoteItem] )
    {
        NoteItem2 *noteToSet = [object getNoteItem];
        visualObject = noteToSet;
        if ( [self isEditModeOn] )
        {
            noteToSet.noteTextView.editable = YES;
            noteToSet.noteTextView.selectable = YES;
        }
        visualObject.layer.borderColor = SELECTED_VIEW_BORDER_COLOR;
        visualObject.layer.borderWidth = SELECTED_VIEW_BORDER_WIDTH;
        self.visuallState.selectedVisualItem = noteToSet;
    }
    else if ( [object isGroupItem] )
    {
        GroupItem *gi = [object getGroupItem];
        [gi setViewAsSelectedForEditModeOn:[self.visuallState editModeOn] andZoomScale:[self.visuallState getZoomScale]];
        [[self.view window] endEditing:YES];
        self.visuallState.selectedVisualItem = gi;
    }
    else if ( [object isArrowItem] )
    {
        ArrowItem *ai = [object getArrowItem];
        self.visuallState.selectedVisualItem = ai;
        [ai setViewAsSelected];
    }
    else if ( [object isDrawView] )
    {
        FDDrawView *dv = (FDDrawView *) object;
        [dv setSelectedPathFromHitTestPath];
        [dv highlightSelectedPath];
        self.visuallState.selectedVisualItem = dv;
    }
    else
    {
        self.visuallState.selectedVisualItem = nil;
        self.visuallState.selectedVisualItem = nil;
        [[self.view window] endEditing:YES];
    }

    [self updateSecondSubmenuStateFromSelectedVisualItem];
    return YES;
}

- (void) addGestureRecognizersToGroup: (GroupItem *) gi
{
    //        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
    //                                       initWithTarget:self
    //                                       action:@selector(myWrapper:)];
    //        [groupItem addGestureRecognizer: pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapHandler:)];
//    tap.delegate = self;
    
//    [gi addGestureRecognizer: tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
//                                   action:@selector(myWrapper:)];
                                   action:@selector(panHandler:)];
//    pan.delegate = self;
//    pan.delaysTouchesBegan = YES;
//    [gi addGestureRecognizer: pan];

//    UIView *groupHandle = [gi viewWithTag:777];
//    UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(panHandler:)];
//    [groupHandle addGestureRecognizer: pan2];

     UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(testPinch:)];
//    pinch.cancelsTouchesInView = YES;
//    pinch.delegate = self;
//    [gi addGestureRecognizer:pinch];
    
//    [pan requireGestureRecognizerToFail: pinch];
//    [pan requireGestureRecognizerToFail: self.BackgroundScrollView.pinchGestureRecognizer];
    

//    TouchDownGestureRecognizer *touchDown = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchDown:)];
//    [gi addGestureRecognizer:touchDown];
    
}

- (void) testPinch: (UIPinchGestureRecognizer *) gestureRecognizer
{
    NSLog(@"Group(s) being pinched");
}

-(void)myWrapper:(UIPanGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizer state: %ld", (long)gestureRecognizer.state);
    
    [self handlePanGroup:gestureRecognizer andGroupItem:nil];
}

//- (void)loadGroupsFromCoreData
//{
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
//    
//    NSArray *groupsCD = [self.moc executeFetchRequest:request error:nil];
//    NSLog(@"Fetching Groups from Core Data...found %d groups", groupsCD.count);
//    
//    for (Group *group in groupsCD)
//    {
//        [self.groupsCollection.groups addObject:[[GroupItem alloc] initGroup: group]];
//    }
//    
//}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
