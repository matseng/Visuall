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
#import "ScrollViewMod.h"
#import "StateUtil.h"
#import "TouchDownGestureRecognizer.h"

@interface ViewController () <UITextViewDelegate, UIGestureRecognizerDelegate> {
    UIPinchGestureRecognizer *pinchGestureRecognizer; UITapGestureRecognizer *BackgroundScrollViewTapGesture;
}
//@property (strong, nonatomic) IBOutlet UIView *Background;

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property CGPoint drawGroupViewStart;
@property UIGestureRecognizer *panBackground;
@property NSManagedObjectContext *moc;
//@property (strong, nonatomic) IBOutlet UIView *GestureView;
@property CGPoint panBeginPoint;
@property (strong, nonatomic) IBOutlet UITextField *fontSize;
@property CGRect totalBoundsRect;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.BoundsTiledLayerView = [[TiledLayerView alloc] init];
    self.BoundsTiledLayerView.frame = CGRectMake(0, 0, 1, 1);
    self.BoundsTiledLayerView.backgroundColor = [UIColor purpleColor];
    
//    UITapGestureRecognizer *singleTapBoundsView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
//    singleTapBoundsView.cancelsTouchesInView = YES;
//    singleTapBoundsView.delegate = self;
//    [self.BoundsTiledLayerView addGestureRecognizer:singleTapBoundsView];
    
    [self.BackgroundScrollView removeFromSuperview];
    self.BackgroundScrollView = [[ScrollViewMod alloc] init];
    [self.Background addSubview: self.BackgroundScrollView];
    
    [self.BackgroundScrollView addSubview: self.BoundsTiledLayerView];
//    [self.GroupsView removeFromSuperview];
    [self.VisualItemsView removeFromSuperview];
//    [self.BoundsTiledLayerView addSubview: self.GroupsView];
    [self.BoundsTiledLayerView addSubview: self.VisualItemsView];
    
    [self setBackgroundViewGestures];
    
    [self initializeBackgroundScrollView];
    
    self.GroupsView.tag = 999;
    self.drawGroupView = [self initializeDrawGroupView];
    
    self.NotesView.opaque = NO;
//    self.NotesView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
    self.fontSize.delegate = self;
    [self.fontSize addTarget:self
                    action:@selector(fontSizeEditingChangedHandler:)
                    forControlEvents:UIControlEventEditingChanged];
    [[StateUtil sharedManager] setCallbackNoteItem:^(NoteItem2 *ni) {
        [self addNoteToViewWithHandlers: ni];
        [self calculateTotalBounds: ni];  // TODO - update so doest move window
//        [self setSelectedObject: ni];
    }];
    [[StateUtil sharedManager] setCallbackGroupItem:^(GroupItem *gi) {
        [self addGestureRecognizersToGroup: gi];
        [self.GroupsView addSubview: gi];
        if ( !self.groupsCollection ) self.groupsCollection = [GroupsCollection new];
        [self.groupsCollection addGroup: gi withKey: gi.group.key];
        //        [self refreshGroupView];
        [self calculateTotalBounds: gi];
    }];
    [[StateUtil sharedManager] loadVisuallsForCurrentUser];
    /*
    [[StateUtil sharedManager] loadFirebaseNotes:^(NoteItem2 *ni) {
        [self addNoteToViewWithHandlers: ni];
        [self calculateTotalBounds: ni];
    }];

    [[StateUtil sharedManager] loadFirebaseGroups:^(GroupItem *gi) {
        [self addGestureRecognizersToGroup: gi];
        [self.GroupsView addSubview: gi];
        if ( !self.groupsCollection ) self.groupsCollection = [GroupsCollection new];
        [self.groupsCollection addGroup: gi withKey: gi.group.key];
//        [self refreshGroupView];
        [self calculateTotalBounds: gi];
    }];
     */
    
    [self createTopMenu];
    
    [self addHorizontalScrollingButtonList];
    
    NSLog(@"Firebase URL: %@", self.firebaseURL);
    
}

- (void) setBackgroundViewGestures
{
    UIPanGestureRecognizer *panBackground = [[UIPanGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(panHandler:)];
    self.panBackground = panBackground;
//    [self.Background addGestureRecognizer: panBackground];
    //    panBackground.delegate = self;  // NOTE: keep disabled for now
    
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handlePinchBackground:)];
//    [self.Background addGestureRecognizer:pinchBackground];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
//    tapGesture.numberOfTapsRequired = 1;
//    [self.Background addGestureRecognizer:tapGesture];
//    UITapGestureRecognizer *singleTapBackgroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
//    singleTapBackgroundView.cancelsTouchesInView = NO;
//    singleTapBackgroundView.delegate = self;
//    [self.Background addGestureRecognizer:singleTapBackgroundView];

    
    
    UITapGestureRecognizer *tapGestureDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureDoubleTap.numberOfTapsRequired = 2;
//    [self.Background addGestureRecognizer:tapGestureDoubleTap];
    
}

- (void) initializeBackgroundScrollView
{
    float x = 0;
//    float y = self.navigationController.navigationBar.frame.size.height;
    float y = 0;
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float h0 = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float h1 = self.navigationController.navigationBar.frame.size.height;
    float h2 = self.tabBarController.tabBar.frame.size.height;
    height = height - h0 - h1 - h2;
    self.BackgroundScrollView.frame = CGRectMake(x, y, width, height);
    
    TouchDownGestureRecognizer *touchDown = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchDown:)];
    touchDown.delegate = self;
    [self.BackgroundScrollView addGestureRecognizer:touchDown];
    
    BackgroundScrollViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    BackgroundScrollViewTapGesture.delegate = self;
    [self.BackgroundScrollView addGestureRecognizer:BackgroundScrollViewTapGesture];

    
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
    
    
    self.VisualItemsView.contentMode = UIViewContentModeRedraw;
//    [self.NotesView setFrame: CGRectMake(0, 0, 600, 450)];
    [self.VisualItemsView setFrame: CGRectMake(0, 0, 1, 1)];
    [self.GroupsView setFrame: CGRectMake(0, 0, 100, 100)];
    [self.ArrowsView setFrame: CGRectMake(0, 0, 200, 200)];
    [self.NotesView setFrame: CGRectMake(0, 0, 300, 300)];
    
//    UITapGestureRecognizer *singleTapNotesView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
//    singleTapNotesView.cancelsTouchesInView = NO;
//    singleTapNotesView.delegate = self;
//    [self.NotesView addGestureRecognizer:singleTapNotesView];
    
    CGRect rect = self.VisualItemsView.frame;
    rect = [[UIScreen mainScreen] bounds];
//    self.totalBoundsRect = self.BoundsTiledLayerView.frame;
    
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor clearColor].CGColor;
    sublayer.frame = rect;
    sublayer.borderColor = [UIColor blueColor].CGColor;
    sublayer.borderWidth = 100.0;
//    [self.NotesView.layer addSublayer:sublayer];
    NSLog(@"NoteView dimensions: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    self.BackgroundScrollView.contentSize = CGSizeMake(self.BoundsTiledLayerView.frame.size.width, self.BoundsTiledLayerView.frame.size.height);

    self.BackgroundScrollView.minimumZoomScale = 0.01;
    self.BackgroundScrollView.maximumZoomScale = 6.0;
    self.BackgroundScrollView.delegate = self;  // REQUIRED to enable pinch to zoom
    self.automaticallyAdjustsScrollViewInsets = NO;
//    NSLog(@"NoteView dimensions: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void) centerScrollViewContents {
    CGSize boundsSize = self.BackgroundScrollView.bounds.size;
    CGRect contentsFrame = self.BoundsTiledLayerView.frame;

    CGRect rect = self.BackgroundScrollView.frame;
//    NSLog(@"Frame rect: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    rect = self.BackgroundScrollView.bounds;
//    NSLog(@"Bounds rect: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = contentsFrame.origin.x - self.BackgroundScrollView.bounds.origin.x;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = contentsFrame.origin.y - self.BackgroundScrollView.bounds.origin.y;
    }
    self.BoundsTiledLayerView.frame = contentsFrame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
//    return self.NotesView;
    return self.BoundsTiledLayerView;
}

- (void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    NSLog(@"HERE in scrollViewWillBeginZooming");
}

- (void) __calculateTotalBounds: (UIView *) view
{
//    self.BackgroundScrollView.zoomScale = 1.0;
    self.BackgroundScrollView.contentOffset = CGPointZero;
    if ( self.totalBoundsRect.size.width == 0 )
    {
        self.totalBoundsRect = view.frame;
    }
    self.totalBoundsRect = CGRectUnion(self.totalBoundsRect, view.frame);
    self.BoundsTiledLayerView.frame = CGRectMake(0, 0, self.totalBoundsRect.size.width, self.totalBoundsRect.size.height);
    self.BackgroundScrollView.contentSize = self.BoundsTiledLayerView.frame.size;
    self.VisualItemsView.frame = CGRectMake(fabs(self.totalBoundsRect.origin.x), fabs(self.totalBoundsRect.origin.y), self.VisualItemsView.frame.size.width, self.VisualItemsView.frame.size.height); // TODO: do I have to set this frame size, why?
    self.BackgroundScrollView.contentOffset = CGPointMake( fabs( self.totalBoundsRect.origin.x), fabs(self.totalBoundsRect.origin.y) );
}

- (void) calculateTotalBounds: (UIView *) view
{
    float zoomScalePrevious = self.BackgroundScrollView.zoomScale;
    float contentsFrameOriginX = self.BoundsTiledLayerView.frame.origin.x;
    float contentsFrameOriginY = self.BoundsTiledLayerView.frame.origin.y;
    self.BackgroundScrollView.zoomScale = 1.0;
    self.BackgroundScrollView.contentOffset = CGPointZero;
    if ( self.totalBoundsRect.size.width == 0 )
    {
        self.totalBoundsRect = view.frame;
    }
    self.totalBoundsRect = [self.BoundsTiledLayerView convertRect: self.totalBoundsRect toView: self.BoundsTiledLayerView];
    CGRect viewRect = [self.BoundsTiledLayerView convertRect: view.frame toView: self.BoundsTiledLayerView];
    self.totalBoundsRect = CGRectUnion(self.totalBoundsRect, viewRect);
//    self.totalBoundsRect = [self.BoundsTiledLayerView convertRect: self.totalBoundsRect toView: self.BackgroundScrollView];
    self.BoundsTiledLayerView.frame = CGRectMake(0, 0, self.totalBoundsRect.size.width, self.totalBoundsRect.size.height);
    self.VisualItemsView.frame = CGRectMake(-self.totalBoundsRect.origin.x, -self.totalBoundsRect.origin.y, 5, 5);
    self.BackgroundScrollView.contentSize = self.BoundsTiledLayerView.frame.size;
    self.BackgroundScrollView.zoomScale = zoomScalePrevious;
//    self.BackgroundScrollView.contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
    self.BoundsTiledLayerView.frame = CGRectMake(contentsFrameOriginX, contentsFrameOriginY, self.BoundsTiledLayerView.frame.size.width, self.BoundsTiledLayerView.frame.size.height);
    
//    self.BackgroundScrollView.contentOffset = CGPointMake( fabs( self.totalBoundsRect.origin.x), fabs(self.totalBoundsRect.origin.y) );
}


- (void) backButtonHandler
{
    [self.navigationController popViewControllerAnimated:YES];
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
    if ([self.lastSelectedObject isInBoundsOfView: self.BackgroundScrollView])
    {
        if ([self.lastSelectedObject isNoteItem])
        {
            NoteItem2 *ni = [self.lastSelectedObject getNoteItem];
//            [self removeValue:ni];
            [self.NotesCollection deleteNoteGivenKey: ni.note.key];
        }
        
        else if ([self.lastSelectedObject isGroupItem])
        {
            GroupItem *gi = [self.lastSelectedObject getGroupItem];
            //        [self removeValue:gi];
            [self.groupsCollection deleteGroupGivenKey: gi.group.key];
        }
        
//        [self.lastSelectedObject removeFromSuperview];
        [[StateUtil sharedManager] removeValue: self.lastSelectedObject];  // TODO: add a callback here... e.g. use to confirm item was deleted from Firebase, otherwise maybe keep the item in view?
        //        [self.lastSelectedObject delete:nil];  // TODO: untested
        //        self.lastSelectedObject = nil;

        [self normalizeTrashButton];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self findChildandTitleNotes];  // TODO: move this message elsewhere?
        UIView *view = [self getViewHit: gestureRecognizer];
        if (!view) {
            return;
        }
        [[StateUtil sharedManager] handleDoubleTapToZoom: gestureRecognizer andTargetView: view];
    }
}
 
- (void) findChildandTitleNotes
{

    [self.NotesCollection myForIn:^(NoteItem2 *ni)
     {
         [self.groupsCollection myForIn:^(GroupItem *gi){
            if( [gi isNoteInGroup:ni] )
            {
                if (![ni.note parentGroupKey]) {
                    [ni.note setParentGroupKey: gi.group.key];
                } else if ( [gi.group getArea] < [self.groupsCollection getGroupAreaFromKey:[ni.note parentGroupKey]] )  // current group is smaller than previously assigned parent
                {
                    [ni.note setParentGroupKey: gi.group.key];
                }

                if ( !gi.group.titleNoteKey )
                {
                    [gi.group setTitleNoteKey: ni.note.key];
                    [ni.note setIsTitleOfParentGroup:YES];
                } else if ( ni.note.fontSize > [self.NotesCollection getNoteFontSizeFromKey:gi.group.titleNoteKey])
                {
                    Note2 *oldTitleNote = [self.NotesCollection getNoteFromKey:gi.group.titleNoteKey];
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
    if (fontSize && [self.lastSelectedObject isKindOfClass: [NoteItem2 class]])
    {
        NoteItem2 *ni = (NoteItem2 *) self.lastSelectedObject;
        [ni setFontSize:fontSize];
        [[StateUtil sharedManager] transformVisualItem: ni];
    }
}

-(void) handleTouchDown:(TouchDownGestureRecognizer *) gestureRecognizer {
    UIView *viewHit = self.BoundsTiledLayerView.hitTestView;
    NSLog(@"handleTouchDown viewHit %@", [viewHit class]);
    
    if ( [viewHit isEqual: self.scrollViewButtonList] )
    {
        return;
    }
    else if ( [viewHit isNoteItem] )
    {
        NoteItem2 *nv = [viewHit getNoteItem];
        //            [self setSelectedObject:nv];
        [self setActivelySelectedObjectDuringPan: nv];
        //            [[self.view window] endEditing:YES];  // hide keyboard when dragging a note
    }
    else if ( [self isEditModeOn] && [self isPointerButtonSelected] && [viewHit isGroupItem])
    {
        UIView *handleSelected = [[viewHit getGroupItem] hitTestOnHandles:gestureRecognizer];
        if ( handleSelected )
        {
            //                [self setSelectedObject:handleSelected];  // TODO, still should highlight current group
            [self setActivelySelectedObjectDuringPan: handleSelected];
            [[viewHit getGroupItem] setHandleSelected: handleSelected];
        } else if ([viewHit isInBoundsOfView:self.BackgroundScrollView])
        {
            GroupItem  *gi = [viewHit getGroupItem];
            [self setActivelySelectedObjectDuringPan: gi];
            //                [self setSelectedObject:gi];
            //                [self setItemsInGroup:gi];
        }
        
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
    
    if ([self isEditModeOn] && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] && [self.BoundsTiledLayerView.hitTestView isNoteItem])
    {
        return YES;  // NOTE: YES --> manually added gestureRecognizer receives the touch (not the UIScrollView)
    }
    if ([self isEditModeOn] && [gestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]] &&
        [self.BoundsTiledLayerView.hitTestView isGroupItem] && [self.BoundsTiledLayerView.hitTestView isInBoundsOfView: self.BackgroundScrollView ])
    {
        return YES;  // NOTE: YES --> manually added gestureRecognizer receives the touch (not the UIScrollView)
    }
    if ([gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]])
    {
        return YES;
    }
    if( [self isDrawGroupButtonSelected] )
    {
        return YES;
    }

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


- (CGRect) createGroupViewRect:(CGPoint)start withEnd:(CGPoint)end {
    float x1 = start.x < end.x ? start.x : end.x;
    float y1 = start.y < end.y ? start.y : end.y;
    
    float x2 = start.x < end.x ? end.x : start.x;
    float y2 = start.y < end.y ? end.y : start.y;
    
    float width = x2 - x1;
    float height = y2 - y1;
    
    return CGRectMake(x1, y1, width, height);
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

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
    {
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            self.drawGroupViewStart = [gestureRecognizer locationInView: self.GroupsView];
            
            [self.GroupsView addSubview: self.drawGroupView];
        }
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
        }
        
        // State ended
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
            GroupItem *currentGroupItem = [[GroupItem alloc] initWithRect: self.drawGroupView.frame];
            [[StateUtil sharedManager] setValueGroup: currentGroupItem];
            [self addGestureRecognizersToGroup: currentGroupItem];
            [self.GroupsView addSubview: currentGroupItem];
//            if ( !self.groupsCollection ) self.groupsCollection = [GroupsCollection new];
//            [self.groupsCollection addGroup:currentGroupItem withKey:currentGroupItem.group.key];
            [self refreshGroupView];
            [self setSelectedObject:currentGroupItem];
        }
    }
}

- (void) handleTapGroup: (UITapGestureRecognizer *) gestureRecognizer
{
    if (self.modeControl.selectedSegmentIndex == 2 || self.modeControl.selectedSegmentIndex == 3) {
        [self setSelectedObject:gestureRecognizer.view];
    }
    
    [self tapHandler: gestureRecognizer];  // tap group --> check to see if we should add a note
}

//- (void) attachAllNotes
//{
//    for (NoteItem2 *ni in self.NotesCollection.Notes) {
//        [self addNoteToViewWithHandlers:ni]; // TODO: re-enable
//    }
//}

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapHandler:)];
//    tap.delegate = self;
//    [noteItem.noteTextView addGestureRecognizer: tap];
//    [noteItem addGestureRecognizer: tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panHandler:)];
//    pan.delegate = self;
//    [noteItem.noteTextView addGestureRecognizer: pan];
    noteItem.noteTextView.delegate = self;
    noteItem.noteTextView.editable = NO;
    
    [self.NotesView addSubview:noteItem];
    [[StateUtil sharedManager] transformVisualItem: noteItem];
//    self.lastSelectedObject = noteItem;

}

//- (BOOL) textFieldShouldReturn:(UITextField *) textField
//{
//    NSLog(@"Should remove keyboard here again");
//    [textField resignFirstResponder];
//    return YES;
//}
//
- (BOOL) textViewShouldBeginEditing:(UITextView *) textView
{
    NSLog(@"textFieldShouldBeginEditing");
    if ( [textView getNoteItem] == self.lastSelectedObject) {
        return YES;
    }
    return NO;
}

- (void) textViewDidChange:(UITextView *) textView
{
    NoteItem2 *ni = (NoteItem2 *) textView.superview;
    [ni resizeToFit: textView.text];
    ni.note.title = textView.text;
//    [[TransformUtil sharedManager] transformVisualItem: ni];
    [[StateUtil sharedManager] updateChildValue:ni Property:@"title"];
}

-(void) textViewDidChangeSelection:(UITextView *)textView
{
    NoteItem2 *ni = [textView getNoteItem];
    [self setSelectedObject: ni];
}

- (IBAction)onDeletePressed:(UIBarButtonItem *)sender {
    
    
    
//    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    
    //define cancel action
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        // noop
//    }];

    NSLog(@"Kill all humans");
    if (self.lastSelectedObject) {
        NSLog(@"%@", self.lastSelectedObject);
        NSManagedObject *objectToDelete;
        NSString *modalText;
        if ([self.lastSelectedObject isKindOfClass:[NoteItem2 class]]) {
            NSLog(@"puplet");
//            NoteItem2 *noteToDelete = (NoteItem2 *)self.lastSelectedObject;
//            objectToDelete = [self.moc existingObjectWithID:noteToDelete.note.objectID error:nil];
            modalText = @"this note";
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]]) {
            NSLog(@"woofarf");
            GroupItem *groupToDelete = (GroupItem *)self.lastSelectedObject;
            
//            objectToDelete = [self.moc existingObjectWithID:groupToDelete.group.objectID error:nil];
            
            modalText = @"this group";
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", modalText] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self.lastSelectedObject isKindOfClass:[NoteItem2 class]]) {
                    NoteItem2 *ni = (NoteItem2 *)self.lastSelectedObject;
                    [self removeValue:ni];
                    [self.NotesCollection deleteNoteGivenKey: ni.note.key];
                } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]]) {
                    GroupItem *gi = (GroupItem *)self.lastSelectedObject;
                    [self removeValue:gi];
                    [self.groupsCollection deleteGroupGivenKey: gi.group.key];
                }
                [self.lastSelectedObject removeFromSuperview];
                self.lastSelectedObject = nil;
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // noop
        }];
        
        [alertController addAction:alertAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)setSelectedObject:(UIView *) object
{
    if (self.lastSelectedObject == object)
    {
        return NO;
    }
    if (self.lastSelectedObject) {
        if ([self.lastSelectedObject isKindOfClass:[NoteItem2 class]])
        {
            NoteItem2 *ni = [self.lastSelectedObject getNoteItem];
            ni.noteTextView.editable = NO;
            ni.noteTextView.selectable = NO;
            self.lastSelectedObject.layer.borderWidth = 0;
        } else if ([self.lastSelectedObject isGroupItem])
        {
            [[self.lastSelectedObject getGroupItem] setViewAsNotSelected];
        }
    }
    
    UIView *visualObject = [[UIView alloc] init];

    if ( [object isNoteItem] )
    {
        NoteItem2 *noteToSet = [object getNoteItem];
        self.lastSelectedObject = noteToSet;
        visualObject = noteToSet;
        if ( [self isEditModeOn] )
        {
            noteToSet.noteTextView.editable = YES;
            noteToSet.noteTextView.selectable = YES;
        }
        
    } else if ([object isKindOfClass:[GroupItem class]]) {
        GroupItem *groupToSet = (GroupItem *)object;
        self.lastSelectedObject = groupToSet;
        visualObject = groupToSet;
        [[self.view window] endEditing:YES];
    } else if (object.tag == 100)
    {
        self.lastSelectedObject = [object superview];
        visualObject = (GroupItem *) [object superview];
        [[self.view window] endEditing:YES];
        
    } else if ([object isGroupItemSubview])
    {
        self.lastSelectedObject = object;
        visualObject = [object getGroupItem];
        [[self.view window] endEditing:YES];
    } else
    {
        self.lastSelectedObject = nil;
        [[self.view window] endEditing:YES];
    }
    
    if ( [visualObject isGroupItem] )
    {
        // check and swap negative lengths
    }
    
    if ([visualObject isGroupItem])
    {
        [[visualObject getGroupItem] setViewAsSelected];
    } else
    {
        visualObject.layer.borderColor = SELECTED_VIEW_BORDER_COLOR;
        visualObject.layer.borderWidth = SELECTED_VIEW_BORDER_WIDTH;
    }
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
