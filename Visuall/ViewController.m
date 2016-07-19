//
//  ViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import "ViewController.h"
#import "Note.h"
#import "NoteItem.h"
#import "NoteItem2.h"
#import "UIView+VisualItem.h"
#import "TransformUtil.h"
#import "AppDelegate.h"
#import "TouchDownGestureRecognizer.h"
#import "SevenSwitch.h"
#import "UIImage+Extras.h"
#import "ViewController+Menus.h"
#import "ViewController+ViewHit.h"
#import "ViewController+panHandler.h"
#import "ViewController+TapHandler.h"
#import "ViewController+Group.h"
#import "TiledLayerView.h"

@interface ViewController () <UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate> {
    UIPinchGestureRecognizer *pinchGestureRecognizer;
}
//@property (strong, nonatomic) IBOutlet UIView *Background;
@property (strong, nonatomic) TiledLayerView *BoundsTiledLayerView;
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
    self.BoundsTiledLayerView.frame = CGRectMake(0, 0, 1000, 1000);
    self.BoundsTiledLayerView.backgroundColor = [UIColor whiteColor];
    
//    UITapGestureRecognizer *singleTapBoundsView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
//    singleTapBoundsView.cancelsTouchesInView = YES;
//    singleTapBoundsView.delegate = self;
//    [self.BoundsTiledLayerView addGestureRecognizer:singleTapBoundsView];
    
    
    [self.BackgroundScrollView addSubview: self.BoundsTiledLayerView];
    [self.NotesView removeFromSuperview];
    [self.BoundsTiledLayerView addSubview: self.NotesView];
    
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
    
//    NSLog(@"My firebase config %d", [[NSNumber numberWithBool: [Firebase defaultConfig].persistenceEnabled] integerValue]);
    
    if ( [Firebase defaultConfig].persistenceEnabled == NO) {
        [Firebase defaultConfig].persistenceEnabled = YES;
    }

    [Firebase goOffline];
    
    Firebase *connectedRef = [[Firebase alloc] initWithUrl:@"https://brainspace-biz.firebaseio.com/.info/connected"];
    [connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if([snapshot.value boolValue]) {
            NSLog(@"connected");
        } else {
            NSLog(@"not connected");
        }
    }];
    
    [self loadFirebaseTransform];
    
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
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    singleTap.cancelsTouchesInView = NO;
//    singleTap.delegate = self;
    [self.BackgroundScrollView addGestureRecognizer:singleTap];
    
    self.NotesView.contentMode = UIViewContentModeRedraw;
    [self.NotesView setFrame: CGRectMake(0, 0, 600, 450)];
    
//    UITapGestureRecognizer *singleTapNotesView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
//    singleTapNotesView.cancelsTouchesInView = NO;
//    singleTapNotesView.delegate = self;
//    [self.NotesView addGestureRecognizer:singleTapNotesView];
    
    CGRect rect = self.NotesView.frame;
    rect = CGRectMake(-rect.size.width * 4, -rect.size.height * 3, rect.size.width * 8, rect.size.height * 6);
//    self.totalBoundsRect = rect;
    self.totalBoundsRect = self.BoundsTiledLayerView.frame;
    
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor clearColor].CGColor;
    sublayer.frame = rect;
    sublayer.borderColor = [UIColor blueColor].CGColor;
    sublayer.borderWidth = 100.0;
//    [self.NotesView.layer addSublayer:sublayer];
    NSLog(@"NoteView dimensions: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
//    self.BackgroundScrollView.contentSize = self.totalBoundsRect.size;
//    self.BackgroundScrollView.contentSize = CGSizeMake(self.totalBoundsRect.size.width / 2, self.totalBoundsRect.size.height / 2);
//    self.BackgroundScrollView.contentInset = UIEdgeInsetsMake(self.totalBoundsRect.size.height / 2, self.totalBoundsRect.size.width / 2, 0, 0);
//    self.BackgroundScrollView.contentSize = CGSizeMake(self.totalBoundsRect.size.width, self.totalBoundsRect.size.height);
    
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
    NSLog(@"Frame rect: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    rect = self.BackgroundScrollView.bounds;
    NSLog(@"Bounds rect: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    
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

- (void) calculateTotalBounds: (id) item
{
    if( [item isKindOfClass: [UIView class]] )
    {
//        float prevScale = self.BackgroundScrollView.zoomScale;
//        CGPoint prevOffset = self.BackgroundScrollView.contentOffset;
        self.BackgroundScrollView.zoomScale = 1.0;
        self.BackgroundScrollView.contentOffset = CGPointZero;
        
        UIView *itemView = (UIView *) item;
        self.totalBoundsRect = CGRectUnion(self.totalBoundsRect, itemView.frame);
        self.BoundsTiledLayerView.frame = CGRectMake(0, 0, self.totalBoundsRect.size.width, self.totalBoundsRect.size.height);
        self.BackgroundScrollView.contentSize = self.BoundsTiledLayerView.frame.size;
        self.NotesView.frame = CGRectMake(fabs(self.totalBoundsRect.origin.x), fabs(self.totalBoundsRect.origin.y), self.NotesView.frame.size.width, self.NotesView.frame.size.height);
        self.BackgroundScrollView.contentOffset = CGPointMake( fabs( self.totalBoundsRect.origin.x), fabs(self.totalBoundsRect.origin.y) );
        
//        self.BackgroundScrollView.zoomScale = prevScale;
//        self.BackgroundScrollView.contentOffset = prevOffset;
    }
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
}

- (void)handleTapGesture:(UITapGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self findChildandTitleNotes];  // TODO: move this message elsewhere?
        UIView *view = [self getViewHit: gestureRecognizer];
        if (!view) {
            return;
        }
        [[TransformUtil sharedManager] handleDoubleTapToZoom: gestureRecognizer andTargetView: view];
    }
}

- (void) loadFirebaseGroups
{

    Firebase *refGroups = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/groups2"];
    [Firebase goOffline];
    self.groupsCollection = [GroupsCollection new];
    [[TransformUtil sharedManager] setGroupsCollection: self.groupsCollection];
    [refGroups observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
     {
         if([self.groupsCollection getGroupItemFromKey: snapshot.key])  // If the note already exists in the collection
         {
             return;  // TODO: add functionality to update values during multiuser collaboration
         }
         
         GroupItem *newGroup = [[GroupItem alloc] initGroup:snapshot.key andValue:snapshot.value];
         [self addGestureRecognizersToGroup: newGroup];
         [self.groupsCollection addGroup: newGroup withKey: snapshot.key];
         [self.GroupsView addSubview:newGroup];
//         [[TransformUtil sharedManager] transformGroupItem: newGroup];
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
    
}

- (void) loadFirebaseNotes
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/notes2"];
    [Firebase goOffline];
    self.NotesCollection = [NotesCollection new];
    [[TransformUtil sharedManager] setNotesCollection: self.NotesCollection];
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
    {
        if([self.NotesCollection getNoteFromKey:snapshot.key])  // If the note already exists in the collection
        {
            return;  // TODO: add functionality to update values during multiuser collaboration
        }
        
        NoteItem2 *newNote = [[NoteItem2 alloc] initNoteFromFirebase:snapshot.key andValue:snapshot.value];
        [self.NotesCollection addNote:newNote withKey:snapshot.key];
        [self addNoteToViewWithHandlers:newNote];
        
        [self calculateTotalBounds: newNote];
        
        
    } withCancelBlock:^(NSError *error)
    {
        NSLog(@"%@", error.description);
    }];
}

- (void) loadFirebaseTransform
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/transform"];
    [Firebase goOffline];
    if (ref)
    {
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
         {
             
//             float zoom = [snapshot.value[@"zoom"] floatValue];
//             float tx = [snapshot.value[@"tx"] floatValue];
//             float ty = [snapshot.value[@"ty"] floatValue];
             
             float zoom = 1.0f;
             float tx = 0.0f;
             float ty = 0.0f;

             [[TransformUtil sharedManager] setZoom:zoom];
             [[TransformUtil sharedManager] setPan:(CGPointMake(tx, ty))];
             
             self.BackgroundScrollView.zoomScale = zoom;
             self.BackgroundScrollView.contentOffset = CGPointMake(tx, ty);
             
             [self loadFirebaseNotes];
             [self loadFirebaseGroups];
         } withCancelBlock:^(NSError *error)
         {
             NSLog(@"%@", error.description);
         }];
    }
}

- (void) updateChildValue: (id) visualObject andProperty: (NSString *) propertyName
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
    
    if ( [visualObject isKindOfClass: [NoteItem2 class]] ) {
        NoteItem2 *ni = (NoteItem2 *) visualObject;
        NSString *noteUrl = [[@"notes2/" stringByAppendingString: ni.note.key] stringByAppendingString:@"/data/"];
        [ref updateChildValues: @{
                                  [noteUrl stringByAppendingString:propertyName] : [ni.note valueForKey:propertyName]
                                  }];
    }
}

- (void) updateChildValues: (id) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
    
    if ( [visualObject isKindOfClass: [NoteItem2 class]] ) {  // TODO - simple method the check visualObject its a NoteItem2
        NoteItem2 *ni = (NoteItem2 *) visualObject;
        NSString *noteUrl = [[@"notes2/" stringByAppendingString: ni.note.key] stringByAppendingString:@"/data/"];
        [ref updateChildValues: @{
                                  [noteUrl stringByAppendingString:propertyName1] : [ni.note valueForKey:propertyName1],
                                  [noteUrl stringByAppendingString:propertyName2] : [ni.note valueForKey:propertyName2],
                                  }];
    } else if ([visualObject isKindOfClass: [GroupItem class]]) {  // TODO - simple method the check if it's a GroupItem
        GroupItem *gi = (GroupItem *) visualObject;
        NSString *groupUrl = [[@"groups2/" stringByAppendingString: gi.group.key] stringByAppendingString:@"/data/"];
        [ref updateChildValues: @{
                                  [groupUrl stringByAppendingString:propertyName1] : [gi.group valueForKey:propertyName1],
                                  [groupUrl stringByAppendingString:propertyName2] : [gi.group valueForKey:propertyName2],
                                  }];
    }
}

- (void) setInitialNote: (NoteItem2 *) ni
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
    Firebase *notesRef = [ref childByAppendingPath: @"notes2"];
    Firebase *newNoteRef = [notesRef childByAutoId];
    NSDictionary *noteDictionary = @{
                                    @"data/title": ni.note.title,
                                    @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
                                    @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
                                    @"style/font-size": [NSString stringWithFormat:@"%.3f", ni.note.fontSize]
                                  };
    [newNoteRef updateChildValues: noteDictionary];
    ni.note.key = newNoteRef.key;
}

- (void) setGroup: (GroupItem *) gi
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
    Firebase *groupsRef = [ref childByAppendingPath: @"groups2"];
    Firebase *newGroupRef = [groupsRef childByAutoId];
    NSDictionary *groupDictionary = @{
                                     @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                     @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                     @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                     @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height]
                                     };
    [newGroupRef updateChildValues: groupDictionary];
    gi.group.key = newGroupRef.key;
}

- (void) setTransformFirebase
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
    Firebase *transformRef = [ref childByAppendingPath: @"transform"];
    NSDictionary *transformDictionary = @{
                                      @"zoom": [NSString stringWithFormat:@"%.3f", [[TransformUtil sharedManager] zoom]],
                                      @"tx": [NSString stringWithFormat:@"%.3f", [[TransformUtil sharedManager] pan].x],
                                      @"ty": [NSString stringWithFormat:@"%.3f", [[TransformUtil sharedManager] pan].y]
                                      };
    [transformRef updateChildValues: transformDictionary];
}

- (void) removeValue: (id) object
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
    if([object isKindOfClass: [NoteItem2 class]]) {
        NoteItem2 *ni = (NoteItem2 *) object;
        Firebase *noteRef = [ref childByAppendingPath: [@"notes2/" stringByAppendingString:ni.note.key]];
        [noteRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                NSLog(@"Data could not be removed.");
            } else {
                NSLog(@"Data removed successfully.");
            }
        }];
        
    } else if([object isKindOfClass: [GroupItem class]]) {
        GroupItem *gi = (GroupItem *) object;
        Firebase *groupRef = [ref childByAppendingPath: [@"groups2/" stringByAppendingString:gi.group.key]];
        [groupRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                NSLog(@"Group could not be removed.");
            } else {
                NSLog(@"Group removed successfully.");
            }
        }];
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
        [[TransformUtil sharedManager] transformVisualItem: ni];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
//    if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
//        NSLog(@"My gesture.state Possible");
//    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"My gesture.state Changed");
//    }
    
    UIView *touchView = touch.view;
        if( touch.view == self.BoundsTiledLayerView || touch.view == self.BackgroundScrollView || touch.view == self.NotesView || touch.view == self.GroupsView ) {
            NSLog(@"NO, shouldReceiveTouch: %@", [touch.view class]);
            NSLog(@"NO, shouldReceiveTouch: %@", [gestureRecognizer.view class]);
            return NO;
        } else if ( [touch.view isNoteItem] )
        {
            NSLog(@"testing testing 123");
            return YES;
        }
    NSLog(@"YES, shouldReceiveTouch: %@", [touch.view class]);
    return YES;
    
    if (gestureRecognizer.state == 0) {
        
        [self setSelectedObject: gestureRecognizer.view];
        
        if ([gestureRecognizer.view isNoteItem] || [gestureRecognizer.view isGroupItem])
        {
            [self setActivelySelectedObjectDuringPan: gestureRecognizer.view];
        }
        
        NSLog(@"My gesture.state Possible");
    } else if (gestureRecognizer.state != 0) {
        NSLog(@"My gesture.state imPossible");
    }

    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])
    {
        return YES;
    }
    
    
    return NO;
}

//- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
////    NSLog(@"pinch state %li", pinchGestureRecognizer.state);
////    if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
////       pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
////    {
////        return NO;
////    }
////    else
////    {
////        return YES;
////    }
//    if (gestureRecognizer.view == self.GestureView)
//    {
//        NSLog(@"");
//    }
//    NSLog(@"1. pinch state %li", pinchGestureRecognizer.state);
//    NSLog(@"2. gesture state %@", [gestureRecognizer class]);
//    return YES;
//}

//
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    if (pinchGestureRecognizer.state != 0 )
    {
        NSLog(@"1. pinch state %li", pinchGestureRecognizer.state);
    }
    NSLog(@"1. pinch state %li", pinchGestureRecognizer.state);
    NSLog(@"2. gesture state %@", [gestureRecognizer class]);
    NSLog(@"3. other gesture state %@", [otherGestureRecognizer class]);
//
//    if ( [gestureRecognizer isKindOfClass: [UIPinchGestureRecognizer class]] ||
//          [otherGestureRecognizer isKindOfClass: [UIPinchGestureRecognizer class]] )
//    {
//        return YES;
//    }
    
    return NO;
}

- (void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection andGroups: self.groupsCollection];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setTransformFirebase];
    }
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
            float zoom = [[TransformUtil sharedManager] zoom];
            GroupItem *currentGroupItem = [[GroupItem alloc]
                                           initWithPoint:[[TransformUtil sharedManager] getGlobalCoordinate: self.drawGroupView.frame.origin]
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
        [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection withGroups: self.groupsCollection];
    }
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    if ( [gestureRecognizer.view respondsToSelector:@selector(handlePan2:)] ) {
        NoteItem *ni = (NoteItem *)gestureRecognizer.view;
        [ni handlePan2:gestureRecognizer];
        [self setSelectedObject:ni];
//        [ni saveToCoreData];
    }
}

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
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
            float zoom = [[TransformUtil sharedManager] zoom];
            GroupItem *currentGroupItem = [[GroupItem alloc]
                                           initWithPoint:[[TransformUtil sharedManager] getGlobalCoordinate: self.drawGroupView.frame.origin]
                                           andWidth:self.drawGroupView.frame.size.width / zoom
                                           andHeight:self.drawGroupView.frame.size.height / zoom];
            
//            [currentGroupItem saveToCoreData];
            [self setGroup: currentGroupItem];
            [self addGestureRecognizersToGroup: currentGroupItem];
            
            [self.groupsCollection addGroup:currentGroupItem withKey:currentGroupItem.group.key];
            
            [self refreshGroupView];
            
            // set currentGroupItem as lastSelectedObject
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

- (BOOL) textFieldShouldReturn:(UITextField *) textField
{
    NSLog(@"Should remove keyboard here again");
    [textField resignFirstResponder];
    return YES;
}


- (void) attachAllNotes
{
    for (NoteItem2 *ni in self.NotesCollection.Notes) {
        [self addNoteToViewWithHandlers:ni]; // TODO: re-enable
    }
}

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapHandler:)];
    
//    tap.delegate = self;
    [noteItem.noteTextView addGestureRecognizer: tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(panHandler:)];
//    [noteItem.noteTextView addGestureRecognizer: pan];
    
    [self.NotesView addSubview:noteItem];
    [[TransformUtil sharedManager] transformVisualItem: noteItem];
    self.lastSelectedObject = noteItem;
    
    noteItem.noteTextView.delegate = self;  // Enables delagte method textFieldShouldReturn
}


- (void) textViewDidChange:(UITextView *) textView
{
    NoteItem2 *ni = (NoteItem2 *) [textView superview];
    [ni resizeToFit: textView.text];
    ni.note.title = textView.text;
    [[TransformUtil sharedManager] transformVisualItem: ni];
//    [ni saveToCoreData];
    [self updateChildValue:ni andProperty:@"title"];
}

- (void) textViewDidChange_ARCHIVE:(NoteItem *)textView
{

//    textView.frame = CGRectZero;
    CGRect frame = textView.frame;
    
    CGSize tempSize = textView.bounds.size;
    tempSize.width = CGRectInfinite.size.width;
    
    frame.size = tempSize;
    [textView setFrame: frame];  //TODO: getting error here when zoomed out
    
    [textView setScrollEnabled:YES];
    NSLog(@"New text: %@", textView.text);
    [textView setText: textView.text];
    textView.note.title = textView.text;

    NSLog(@"Before resize: %f, %f", frame.size.width, frame.size.height);
    [textView sizeToFit];

    [textView setScrollEnabled:NO];
    frame = textView.frame;
    [textView.note setWidth:frame.size.width andHeight:frame.size.height];
    
//    frame = [[textView layoutManager] usedRectForTextContainer:[textView textContainer]];
    NSLog(@"After resize: %f, %f", frame.size.width, frame.size.height);
    
    [[TransformUtil sharedManager] transformNoteItem:textView];
    [textView saveToCoreData];
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
    if (self.lastSelectedObject) {
        if ([self.lastSelectedObject isKindOfClass:[NoteItem2 class]])
        {
            self.lastSelectedObject.layer.borderWidth = 0;
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]])
        {
            self.lastSelectedObject.layer.borderWidth = 0;
            self.lastSelectedObject.layer.borderColor = GROUP_VIEW_BORDER_COLOR;
//            self.lastSelectedObject.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
        } else if (self.lastSelectedObject.tag == 777)
        {
            [self.lastSelectedObject superview].layer.borderWidth = 0;
        }

    }
    
    UIView *visualObject = [[UIView alloc] init];


    if ( [object isNoteItem] )
    {
        NoteItem2 *noteToSet = [object getNoteItem];
        self.lastSelectedObject = noteToSet;
        visualObject = noteToSet;
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
        
    } else if (object.tag == 777)
    {
        self.lastSelectedObject = object;
        visualObject = (GroupItem *) [object superview];
        [[self.view window] endEditing:YES];
    } else
    {
        self.lastSelectedObject = nil;
        [[self.view window] endEditing:YES];
    }
    
    visualObject.layer.borderColor = SELECTED_VIEW_BORDER_COLOR;
    visualObject.layer.borderWidth = SELECTED_VIEW_BORDER_WIDTH;
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
    
    [gi addGestureRecognizer: tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
//                                   action:@selector(myWrapper:)];
                                   action:@selector(panHandler:)];
//    [gi addGestureRecognizer: pan];

//    pan.delegate = self;
 //    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
//                                       initWithTarget:self
//                                       action:@selector(testPinch:)];
//    [gi addGestureRecognizer:pinch];

//    TouchDownGestureRecognizer *touchDown = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchDown:)];
//    [gi addGestureRecognizer:touchDown];
    
}

-(void)handleTouchDown:(TouchDownGestureRecognizer *)touchDown{
    NSLog(@"Down");
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
