//
//  ViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import "ViewController.h"
#import "Note.h"
#import "NotesCollection.h"
#import "NoteItem.h"
#import "NoteItem2.h"
#import "TransformUtil.h"
#import "GroupItem.h"
#import "GroupsCollection.h"
#import "AppDelegate.h"
#import "TouchDownGestureRecognizer.h"

@interface ViewController () <UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate> {
    UIPinchGestureRecognizer *pinchGestureRecognizer;
}
@property (strong, nonatomic) IBOutlet UIView *Background;
@property (weak, nonatomic) IBOutlet UIView *GroupsView;
@property (weak, nonatomic) IBOutlet UIView *NotesView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property UIView *currentGroupView;
@property GroupsCollection *groupsCollection;
@property CGPoint currentGroupViewStart;
@property NotesCollection *NotesCollection;
@property UIView *lastSelectedObject;
@property UIGestureRecognizer *panBackground;
@property NSManagedObjectContext *moc;
@property (strong, nonatomic) IBOutlet UIView *GestureView;
@property CGPoint panBeginPoint;
@property (strong, nonatomic) IBOutlet UITextField *fontSize;
@end

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0
#define SELECTED_VIEW_BORDER_COLOR [[UIColor blueColor] CGColor]
#define SELECTED_VIEW_BORDER_WIDTH 2.0

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.moc = appDelegate.managedObjectContext;
    
//    [self addGestureRecognizers];
    self.GestureView.userInteractionEnabled = NO;
    
    UIPanGestureRecognizer *panBackground = [[UIPanGestureRecognizer alloc]
                                             initWithTarget:self
//                                  action:@selector(handlePanBackground:)];
                                             action:@selector(panHandler:)];
    self.panBackground = panBackground;
    [self.Background addGestureRecognizer: panBackground];
//    panBackground.delegate = self;
    
    
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handlePinchBackground:)];
    [self.Background addGestureRecognizer:pinchBackground];
    
    
    self.NotesCollection = [NotesCollection new];
    [self.NotesCollection initializeNotes];
    [self attachAllNotes];
//    UIPanGestureRecognizer *panNotesView = [[UIPanGestureRecognizer alloc]
//                                             initWithTarget:self
//                                             action:@selector(handlePanNotesView:)];
//    [panNotesView setCancelsTouchesInView:NO];
    
    
    // Initialize the rectangle group selection view
    self.currentGroupView = [[UIView alloc] init];
    self.currentGroupView.backgroundColor = GROUP_VIEW_BACKGROUND_COLOR;
    self.currentGroupView.layer.borderColor = GROUP_VIEW_BORDER_COLOR;
    self.currentGroupView.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
    
    // Initlialize the mutable array that holds our group UIViews
    self.groupsCollection = [GroupsCollection new];
    [self.groupsCollection initializeGroups];
//    [self loadGroupsFromCoreData];
    
    for ( GroupItem *gi in self.groupsCollection.groups){
        [self addGestureRecognizersToGroup: gi];
    }

    [self refreshGroupView];
    self.NotesView.opaque = NO;
    self.NotesView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
    self.fontSize.delegate = self;
    [self.fontSize addTarget:self
                    action:@selector(fontSizeEditingChangedHandler:)
//            forControlEvents:UIControlEventEditingDidEnd];
                    forControlEvents:UIControlEventEditingChanged];
    self.modeControl.selectedSegmentIndex = 3;
    
//    [self loadFirebase];

}

- (void) loadFirebase
{
    // Get a reference to our posts
//    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://docs-examples.firebaseio.com/web/saving-data/fireblog/posts"];
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/notes2"];
    
    // Attach a block to read the data at our posts reference
//    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"%@", snapshot.value);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
    // Read data and react to changes
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
    }];
    
}

- (void) fontSizeEditingChangedHandler: (UITextField *) textField
{
    NSLog(@"Font size: %@", self.fontSize.text);
    if (self.fontSize.text.floatValue && [self.lastSelectedObject isKindOfClass: [NoteItem class]])
    {
        NoteItem *ni = (NoteItem *) self.lastSelectedObject;
        [ni setFont: [UIFont systemFontOfSize:self.fontSize.text.floatValue]];
        [ni renderToAutosizeWidth];
//        [[TransformUtil sharedManager] transformNoteItem:ni];
    }
}

- (void) addGestureRecognizers
{
    self.GestureView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(handlePanGestureView:)];
    [self.GestureView addGestureRecognizer: pan];
    pan.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                   action: @selector(handleTap:)];
    
    [self.GestureView addGestureRecognizer: tap];
    tap.delegate = self;
    
//    [self.GestureView addGestureRecognizer: [UITapGestureRecognizer alloc] init:];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
//    [self.GestureView addGestureRecognizer: tap];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handlePinchBackground:)];
    [self.GestureView addGestureRecognizer: pinch];
    pinch.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
//    if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
//        NSLog(@"My gesture.state Possible");
//    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"My gesture.state Changed");
//    }
    
    if (gestureRecognizer.state == 0) {
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


- (UIView *) getViewHit: (UIGestureRecognizer *) gestureRecognizer
{
    UIView *viewHit = gestureRecognizer.view;
    if ( [viewHit isKindOfClass: [NoteItem2 class]])
    {
        return viewHit;
    } else if ( [[viewHit superview] isKindOfClass: [NoteItem2 class]] )
    {
        return [viewHit superview];
    }
    CGPoint location = [gestureRecognizer locationInView: gestureRecognizer.view];
    viewHit = [self.NotesView hitTest:location withEvent:NULL];
    return viewHit;
}

- (void) handlePanGestureView:(UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        UIView *viewHit = [self getViewHit:gestureRecognizer];
//        NSLog(@"viewHit %@", [viewHit class]);
//        NSLog(@"tag %ld", (long)viewHit.tag);
//        NSLog(@"gestureRecognizer %@", [gestureRecognizer.view class]);
        if ( [viewHit isKindOfClass: [NoteItem class]] ) {
            NoteItem *nv = (NoteItem *) viewHit;
            [self setSelectedObject:nv];
            [nv handlePan2:gestureRecognizer];
//        } else if ( [[viewHit superview] isKindOfClass: [GroupItem class]] &&
        } else if ( viewHit.tag == 100 &&
                   self.modeControl.selectedSegmentIndex != 2) {
            GroupItem  *gi = (GroupItem *) [viewHit superview];
            [self setSelectedObject:gi];
            [self handlePanGroup:gestureRecognizer andGroupItem:gi];
        } else if ( viewHit.tag == 777 &&
                  self.modeControl.selectedSegmentIndex != 2) {
//            GroupItem  *gi = (GroupItem *) [viewHit superview];
            
            [self setSelectedObject:viewHit];  // TODO, still should highlight current group
        } else {
            [self handlePanBackground:gestureRecognizer];
            [self setSelectedObject:nil];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if ([self.lastSelectedObject isKindOfClass:[ NoteItem class]])
        {
            NoteItem *ni = (NoteItem*) self.lastSelectedObject;
            [ni handlePan2:gestureRecognizer];
            [ni saveToCoreData];
            
        } else if ( [self.lastSelectedObject isKindOfClass: [GroupItem class]] &&
                   self.modeControl.selectedSegmentIndex != 2)
        {
            GroupItem *gi = (GroupItem*) self.lastSelectedObject;
            [self handlePanGroup:gestureRecognizer andGroupItem:gi];
            [gi saveToCoreData];
        } else if (self.lastSelectedObject.tag == 777)
        {
            GroupItem  *gi = (GroupItem *) [self.lastSelectedObject superview];
            [gi resizeGroup: gestureRecognizer];
        }
        else {
            [self handlePanBackground:gestureRecognizer];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self handlePanBackground:gestureRecognizer];
    } else
    {
//        [self setSelectedObject:nil];
    }
}

- (void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection.Notes andGroups: self.groupsCollection.groups];
    
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
    CGPoint location = [gestureRecognizer locationInView: self.GestureView];
    UIView *viewHit = [self.NotesView hitTest:location withEvent:NULL];
    
    NSLog(@"handlePanBackground viewHit %@", [viewHit class]);
    NSLog(@"gestureRecognizer %@", [gestureRecognizer.view class]);
    
    if ( [viewHit.superview isKindOfClass: [GroupItem class]] )
    {
        viewHit = viewHit.superview;
    }
    
    if ( [viewHit respondsToSelector:@selector(handlePan2:)] ) {
        NoteItem *nv = (NoteItem *) viewHit;
        [nv handlePan2:gestureRecognizer];
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
            self.currentGroupViewStart = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            [self.GroupsView addSubview:self.currentGroupView];
        }
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            self.currentGroupView.frame = [self createGroupViewRect:self.currentGroupViewStart withEnd:currentGroupViewEnd];
        }
        
        // State ended
//        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
//            ![self.lastSelectedObject isKindOfClass:[ NoteItem class]]
//            ) {
         if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            self.currentGroupView.frame = [self createGroupViewRect:self.currentGroupViewStart withEnd:currentGroupViewEnd];
            
            // Make a copy of the current group view and add it to our list of group views
            float zoom = [[TransformUtil sharedManager] zoom];
            GroupItem *currentGroupItem = [[GroupItem alloc]
                                           initWithPoint:[[TransformUtil sharedManager] getGlobalCoordinate: self.currentGroupView.frame.origin]
                                            andWidth:self.currentGroupView.frame.size.width / zoom
                                            andHeight:self.currentGroupView.frame.size.height / zoom];
            
            [currentGroupItem saveToCoreData];
            [self addGestureRecognizersToGroup: currentGroupItem];
            
            [self.groupsCollection addGroup:currentGroupItem];
            
            [self refreshGroupView];

            // set currentGroupItem as lastSelectedObject
            [self setSelectedObject:currentGroupItem];
        }
    }
    else
    {
        [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection.Notes withGroups: self.groupsCollection.groups];
    }
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    if ( [gestureRecognizer.view respondsToSelector:@selector(handlePan2:)] ) {
        NoteItem *nv = (NoteItem *)gestureRecognizer.view;
        [nv handlePan2:gestureRecognizer];
        [self setSelectedObject:nv];
    }
}

- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Handle pan group began");
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"Handle pan group ended");
    }
    
    if (gestureRecognizer.state == 0)
    {
        NSLog(@"Pan possible");
    } else if (gestureRecognizer.state == 1)
    {
        NSLog(@"Pan began");
    } else if (gestureRecognizer.state == 2)
    {
        NSLog(@"Pan changed I think");
    }
    
    if (self.modeControl.selectedSegmentIndex == 2)
    {
        return;
    }
    
    if (!groupItem) {
        groupItem = (GroupItem *)gestureRecognizer.view;
    }


    CGPoint location = [gestureRecognizer locationInView: self.Background];
    UIView *viewHit = [self.NotesView hitTest:location withEvent:NULL];
//    NSLog(@"viewHit tag %li", viewHit.tag);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {

        if (viewHit.tag == 777)
        {
//            self.lastSelectedObject = viewHit;
            [self setLastSelectedObject:viewHit];
            return;
        }

        [self setSelectedObject:groupItem];
        NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
        NSMutableArray *groupsInGroup = [[NSMutableArray alloc]init];
        for (NoteItem *ni in self.NotesCollection.Notes) {
            if ([groupItem isNoteInGroup:ni]) {
//                NSLog(@"Note name in group: %@", ni.note.title);
                [notesInGroup addObject:ni];
            }
        }
        for (GroupItem *gi in self.groupsCollection.groups) {
            if ([groupItem isGroupInGroup:gi]) {
                [groupsInGroup addObject:gi];
            }
        }
        [groupItem setNotesInGroup: notesInGroup];
        [groupItem setGroupsInGroup:groupsInGroup];
    }
    
    if (self.lastSelectedObject.tag == 777)
    {
        GroupItem *gi = (id) self.lastSelectedObject.superview;
        [gi resizeGroup:gestureRecognizer];
    } else if ( [groupItem respondsToSelector:@selector(handlePanGroup2:)] )
    {
//        GroupItem *groupItem = (GroupItem *)gestureRecognizer.view;
        [groupItem handlePanGroup2:gestureRecognizer];
//        [self setSelectedObject:groupItem];
    }
}

- (void) setItemsInGroup: (GroupItem *) groupItem
{
    NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
    NSMutableArray *groupsInGroup = [[NSMutableArray alloc]init];
    for (NoteItem *ni in self.NotesCollection.Notes) {
        if ([groupItem isNoteInGroup:ni]) {
            //                NSLog(@"Note name in group: %@", ni.note.title);
            [notesInGroup addObject:ni];
        }
    }
    for (GroupItem *gi in self.groupsCollection.groups) {
        if ([groupItem isGroupInGroup:gi]) {
            [groupsInGroup addObject:gi];
        }
    }
    [groupItem setNotesInGroup: notesInGroup];
    [groupItem setGroupsInGroup:groupsInGroup];
}

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
    {
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            self.currentGroupViewStart = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            [self.GroupsView addSubview:self.currentGroupView];
        }
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            self.currentGroupView.frame = [self createGroupViewRect:self.currentGroupViewStart withEnd:currentGroupViewEnd];
        }
        
        // State ended
        //        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
        //            ![self.lastSelectedObject isKindOfClass:[ NoteItem class]]
        //            ) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            self.currentGroupView.frame = [self createGroupViewRect:self.currentGroupViewStart withEnd:currentGroupViewEnd];
            
            // Make a copy of the current group view and add it to our list of group views
            float zoom = [[TransformUtil sharedManager] zoom];
            GroupItem *currentGroupItem = [[GroupItem alloc]
                                           initWithPoint:[[TransformUtil sharedManager] getGlobalCoordinate: self.currentGroupView.frame.origin]
                                           andWidth:self.currentGroupView.frame.size.width / zoom
                                           andHeight:self.currentGroupView.frame.size.height / zoom];
            
            [currentGroupItem saveToCoreData];
            [self addGestureRecognizersToGroup: currentGroupItem];
            
            [self.groupsCollection addGroup:currentGroupItem];
            
            [self refreshGroupView];
            
            // set currentGroupItem as lastSelectedObject
            [self setSelectedObject:currentGroupItem];
        }
    }
}

- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer {
    
   
    
    if (self.modeControl.selectedSegmentIndex == 2)
    {
        [self drawGroup: gestureRecognizer];
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {

//        [self.fontSize resignFirstResponder];
//        [self.lastSelectedObject resignFirstResponder];
//        [[self.view window] endEditing:YES];
        
        UIView *viewHit = [self getViewHit:gestureRecognizer];
        NSLog(@"panHandler pan began, viewHit: %@", [viewHit class]);
        if ( [viewHit isKindOfClass: [NoteItem class]] ) {
            NoteItem *nv = (NoteItem *) viewHit;
            [self setSelectedObject:nv];
            [nv handlePan2:gestureRecognizer];
            [[self.view window] endEditing:YES];  // hide keyboard when dragging a note
            return;
        } else if ( viewHit.tag == 100 && self.modeControl.selectedSegmentIndex != 2)
        {
            GroupItem  *gi = (GroupItem *) [viewHit superview];
            [self setSelectedObject:gi];
            [self setItemsInGroup:gi];
        } else if ( viewHit.tag == 777 && self.modeControl.selectedSegmentIndex != 2)
        {
            [self setSelectedObject:viewHit];  // TODO, still should highlight current group
        } else
        {
            [self setSelectedObject:nil];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if ([self.lastSelectedObject isKindOfClass: [NoteItem class]])
        {
            NoteItem *ni = (NoteItem *) self.lastSelectedObject;
            [ni handlePan2:gestureRecognizer];
            [ni saveToCoreData];
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]])
        {
            GroupItem *gi = (GroupItem *) self.lastSelectedObject;
            [self handlePanGroup: gestureRecognizer andGroupItem:gi];
        } else if ( self.lastSelectedObject.tag == 777)
        {
            GroupItem *gi = (GroupItem *) [self.lastSelectedObject superview];
            [gi resizeGroup:gestureRecognizer];
            [self refreshGroupView];
        } else
        {
//            [self handlePanBackground:gestureRecognizer];
            [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection.Notes withGroups: self.groupsCollection.groups];
        }
    }
    
//    else if (gestureRecognizer.state == 1)
//    {
//        NSLog(@"Tap began");
//    } else if (gestureRecognizer.state == 2)
//    {
//        NSLog(@"Tap ended or canceled I think");
//    }
}

- (void) handleTapGroup: (UITapGestureRecognizer *) gestureRecognizer
{
    if (self.modeControl.selectedSegmentIndex == 2 || self.modeControl.selectedSegmentIndex == 3) {
        [self setSelectedObject:gestureRecognizer.view];
    }
    
    [self handleTap: gestureRecognizer];  // tap group --> check to see if we should add a note
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
//        [self.NotesView addSubview:ni];  // TODO: delete this line
    }
}

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTap:)];
    [noteItem.noteTextView addGestureRecognizer: tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
//                                   action:@selector(handlePan:)];
                                   action:@selector(panHandler:)];
    [noteItem addGestureRecognizer: pan];
    
    [self.NotesView addSubview:noteItem];
    self.lastSelectedObject = noteItem;
//    note.userInteractionEnabled = YES;
    
    noteItem.noteTextView.delegate = self;  // Enables delagte method textFieldShouldReturn
    
//    [note addTarget:self
//             action:@selector(textFieldDidChangeHandler:)
//            forControlEvents:UIControlEventEditingChanged];
//    [note addTarget:self
//             action:@selector(textFieldDidBeginEditingHandler:)
//            forControlEvents:UIControlEventEditingDidBegin];

}

- (void) textViewDidChange:(NoteItem *)textView
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



-(void) textFieldDidBeginEditingHandler:(UITextField *)textField
{
    [self setSelectedObject:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void) textFieldDidChangeHandler:(NoteItem *)textField
{
//    [textField sizeToFit];
    textField.note.title = textField.text;
    [textField renderToAutosizeWidth];
    [self setSelectedObject:textField];
}


- (IBAction) handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        UIView *viewHit = [self getViewHit:sender];
        NSLog(@"My viewHit %@", [viewHit class]);
        NSLog(@"tag %ld", (long)viewHit.tag);
        NSLog(@"gestureRecognizer %@", [sender.view class]);
        if ( [viewHit isKindOfClass: [NoteItem2 class]])
        {
            NoteItem2 *nv = (NoteItem2 *) viewHit;
            [self setSelectedObject:nv];
            return;
        }
        
        if (self.modeControl.selectedSegmentIndex == 0) {  // new note button
            
            // grab coordinates
            CGPoint gesturePoint = [sender locationInView: self.Background];
            NSLog(@"we in note mode beeeetches %f %f", gesturePoint.x, gesturePoint.y);
            
            //instantiate alert controller
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Note" message:nil preferredStyle:UIAlertControllerStyleAlert];

            //add text fields for title and paragraph
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Title";
            }];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Paragraph";
            }];
            
            //define add note action
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //grab text fields out of controller
                UITextField *titleTextField = [[alertController textFields] firstObject];
                UITextField *paragraphTextField = [[alertController textFields] lastObject];
                //create a new note  //TODO: Add note directly as a text field (skip modal)
                CGPoint point = [[TransformUtil sharedManager] getGlobalCoordinate:gesturePoint];
                NoteItem *newNote = [[NoteItem alloc] initNote:titleTextField.text andPoint:point andText:paragraphTextField.text];
                [newNote saveToCoreData];
                //stick it with the other notes
                [self.NotesCollection addNote:newNote];
                [self addNoteToViewWithHandlers:newNote];
                [self setSelectedObject:newNote];
            }];
            
            //define cancel action
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // noop
            }];
         
         
//            [alertController addAction:alertAction];
//            [alertController addAction:cancelAction];
//            [self presentViewController:alertController animated:YES completion:nil];
         
         CGPoint point = [[TransformUtil sharedManager] getGlobalCoordinate:gesturePoint];
         NoteItem *newNote = [[NoteItem alloc] initNote:@"text..." andPoint:point andText:@""];
         [newNote saveToCoreData];
         //stick it with the other notes
         [self.NotesCollection addNote:newNote];
         [self addNoteToViewWithHandlers:newNote];
         [self setSelectedObject:newNote];
         
         [newNote becomeFirstResponder]; //puts cursor on text field
         [newNote selectAll:nil];        //highlights text
//         [newNote selectAll:self];

        } else
        {
//            [[self.view window] endEditing:YES];
            [self setSelectedObject: viewHit];
        }
    }
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
        if ([self.lastSelectedObject isKindOfClass:[NoteItem class]]) {
            NSLog(@"puplet");
            NoteItem *noteToDelete = (NoteItem *)self.lastSelectedObject;
            objectToDelete = [self.moc existingObjectWithID:noteToDelete.note.objectID error:nil];
            modalText = @"this note";
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]]) {
            NSLog(@"woofarf");
            GroupItem *groupToDelete = (GroupItem *)self.lastSelectedObject;
            objectToDelete = [self.moc existingObjectWithID:groupToDelete.group.objectID error:nil];
            modalText = @"this group";
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", modalText] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.moc deleteObject:objectToDelete];
                [self.lastSelectedObject removeFromSuperview];
            
                if ([self.lastSelectedObject isKindOfClass:[NoteItem class]]) {
                    [self.NotesCollection.Notes removeObjectIdenticalTo:self.lastSelectedObject];
                } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]]) {
                    [self.groupsCollection.groups removeObjectIdenticalTo:self.lastSelectedObject];
                }
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


- (BOOL)setSelectedObject:(UIView *)object
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

    if ([object isKindOfClass:[NoteItem2 class]]) {
        NoteItem2 *noteToSet = (NoteItem2 *)object;
//        [noteToSet saveToCoreData];  // TODO
//        [noteToSet setBorderStyle:UITextBorderStyleRoundedRect];
        self.lastSelectedObject = noteToSet;
        visualObject = noteToSet;
    } else if ([object isKindOfClass:[GroupItem class]]) {
        GroupItem *groupToSet = (GroupItem *)object;
        [groupToSet saveToCoreData];
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
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(tapHandler:)];
//    [gi addGestureRecognizer: tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
//                                   action:@selector(myWrapper:)];
                                   action:@selector(panHandler:)];
    [gi addGestureRecognizer: pan];

    pan.delegate = self;
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

- (void) refreshGroupView
{
    // Sort by area of group view
    NSArray *sortedArray;
    
    sortedArray = [self.groupsCollection.groups sortedArrayUsingComparator:^NSComparisonResult(GroupItem *first, GroupItem *second) {
        float firstArea = first.frame.size.height * first.frame.size.width;
        float secondArea = second.frame.size.height * second.frame.size.width;
        return firstArea < secondArea;
    }];
    
    // Render all the group views
    for (GroupItem *groupItem in sortedArray) {
        [self.GroupsView addSubview:groupItem];
    }
    
    [self.currentGroupView setFrame:(CGRect){0,0,0,0}];
    [self.currentGroupView removeFromSuperview];

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
