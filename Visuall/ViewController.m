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
@property UIView *drawGroupView;
@property GroupsCollection *groupsCollection;
@property CGPoint drawGroupViewStart;
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
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;  // double-tap
    [self.Background addGestureRecognizer:tapGesture];
    
    
    /*
    self.NotesCollection = [NotesCollection new];
    [self.NotesCollection initializeNotes];
    [self attachAllNotes];
     */
    
//    UIPanGestureRecognizer *panNotesView = [[UIPanGestureRecognizer alloc]
//                                             initWithTarget:self
//                                             action:@selector(handlePanNotesView:)];
//    [panNotesView setCancelsTouchesInView:NO];
    
    
    // Initialize the rectangle group selection view
    self.drawGroupView = [[UIView alloc] init];
    self.drawGroupView.backgroundColor = GROUP_VIEW_BACKGROUND_COLOR;
    self.drawGroupView.layer.borderColor = GROUP_VIEW_BORDER_COLOR;
    self.drawGroupView.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
  /*
    // Initlialize the mutable array that holds our group UIViews
    self.groupsCollection = [GroupsCollection new];
    [self.groupsCollection initializeGroups];
    [self loadGroupsFromCoreData];
   
    
    for ( GroupItem *gi in self.groupsCollection.groups){
        [self addGestureRecognizersToGroup: gi];
    }

    [self refreshGroupView];
    */
    
    self.NotesView.opaque = NO;
    self.NotesView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
    self.fontSize.delegate = self;
    [self.fontSize addTarget:self
                    action:@selector(fontSizeEditingChangedHandler:)
//            forControlEvents:UIControlEventEditingDidEnd];
                    forControlEvents:UIControlEventEditingChanged];
    self.modeControl.selectedSegmentIndex = 3;
    
    [Firebase defaultConfig].persistenceEnabled = YES;
    [self loadFirebaseTransform];

}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self findChildandTitleNotes];
    }
}

- (void) loadFirebaseGroups
{
    Firebase *refGroups = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/groups2"];
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
         [[TransformUtil sharedManager] transformGroupItem: newGroup];
        
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
    
}

- (void) loadFirebase
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/notes2"];
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

    } withCancelBlock:^(NSError *error)
    {
        NSLog(@"%@", error.description);
    }];
}

- (void) loadFirebaseTransform
{
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/transform"];
    if (ref)
    {
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
         {
             float zoom = [snapshot.value[@"zoom"] floatValue];
             float tx = [snapshot.value[@"tx"] floatValue];
             float ty = [snapshot.value[@"ty"] floatValue];
             [[TransformUtil sharedManager] setZoom:zoom];
             [[TransformUtil sharedManager] setPan:(CGPointMake(tx, ty))];
             [self loadFirebase];
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
    
    NSLog(@"panHandler pan began, viewHit: %@", [viewHit class]);
    NSLog(@"viewHit.tag %li", (long) viewHit.tag);

    if ( [viewHit isKindOfClass: [NoteItem2 class]])
    {
        return viewHit;
    } else if ( [[viewHit superview] isKindOfClass: [NoteItem2 class]] )
    {
        return [viewHit superview];
    }
    
    CGPoint location = [gestureRecognizer locationInView: gestureRecognizer.view];
    viewHit = [self.NotesView hitTest:location withEvent:NULL];
    
    if ( [viewHit isKindOfClass: [NoteItem2 class]])  // Hack to detect notes when zoomed in
    {
        return viewHit;
    } else if ( [[viewHit superview] isKindOfClass: [NoteItem2 class]] )
    {
        return [viewHit superview];
    }
    
    return gestureRecognizer.view;
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
        for (NoteItem2 *ni in self.NotesCollection.Notes) {
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

    //    for (NoteItem *ni in self.NotesCollection.Notes) {
//        if ([groupItem isNoteInGroup:ni]) {
//            //                NSLog(@"Note name in group: %@", ni.note.title);
//            [notesInGroup addObject:ni];
//        }
//    }
//    for (GroupItem *gi in self.groupsCollection.groups) {
//        if ([groupItem isGroupInGroup:gi]) {
//            [groupsInGroup addObject:gi];
//        }
//    }
    [self.NotesCollection myForIn:^(NoteItem2 *ni)
    {
        if ([groupItem isNoteInGroup:ni]) {
          [notesInGroup addObject:ni];
        }
    }];
    
    [self.groupsCollection myForIn:^(GroupItem *gi){
        if ([groupItem isGroupInGroup:gi]) {
            [groupsInGroup addObject:gi];
        }
    }];
    
    [groupItem setNotesInGroup: notesInGroup];
    [groupItem setGroupsInGroup:groupsInGroup];
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

- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer {
    
   
    
    if (self.modeControl.selectedSegmentIndex == 2)
    {
        [self drawGroup: gestureRecognizer];
        return;
    }
    
    UIView *viewHit  = [self getViewHit:gestureRecognizer];
//    NSLog(@"panHandler pan began, viewHit: %@", [viewHit class]);
//    NSLog(@"viewHit.tag %li", (long) viewHit.tag);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if ( [viewHit isKindOfClass: [NoteItem2 class]] ) {
            NoteItem2 *nv = (NoteItem2 *) viewHit;
            [self setSelectedObject:nv];
            [nv handlePan:gestureRecognizer];
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
        if ([self.lastSelectedObject isKindOfClass: [NoteItem2 class]])
        {
            NoteItem2 *ni = (NoteItem2 *) self.lastSelectedObject;
            [ni handlePan:gestureRecognizer];
            [self updateChildValues:ni Property1:@"x" Property2:@"y"];
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]])
        {
            GroupItem *gi = (GroupItem *) self.lastSelectedObject;
            [self handlePanGroup: gestureRecognizer andGroupItem:gi];
            [self updateChildValues:gi Property1:@"x" Property2:@"y"];
        } else if ( self.lastSelectedObject.tag == 777)
        {
            GroupItem *gi = (GroupItem *) [self.lastSelectedObject superview];
            [gi resizeGroup:gestureRecognizer];
            [self refreshGroupView];
            [self updateChildValues:gi Property1:@"width" Property2:@"height"];
        } else
        {
//            [self handlePanBackground:gestureRecognizer];
            [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection withGroups: self.groupsCollection];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if ([viewHit isEqual:self.Background])
        {
            [self setTransformFirebase];
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
                                   action:@selector(panHandler:)];
    [noteItem.noteTextView addGestureRecognizer: pan];
    
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

/*
 Handle tap gesture on background AND other objects especially Groups (and Notes?)
 TODO: refactor as a hard coded gesture recognizer for the background
 */

- (IBAction) handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        UIView *viewHit = [self getViewHit:sender];
//        NSLog(@"My viewHit %@", [viewHit class]);
//        NSLog(@"tag %ld", (long)viewHit.tag);
//        NSLog(@"gestureRecognizer %@", [sender.view class]);
        
        if ( [viewHit isKindOfClass: [NoteItem2 class]])
        {
            NoteItem2 *nv = (NoteItem2 *) viewHit;
            [self setSelectedObject:nv];
            NSLog(@"Note key: %@", nv.note.key);
            NSLog(@"Parent group key: %@", nv.note.parentGroupKey);
            NSLog(@"Is a title note?: %@", nv.note.isTitleOfParentGroup ? @"YES" : @"NO");
            NSLog(@"Note width: %f", nv.frame.size.width);
            return;
        }
        
        if (self.modeControl.selectedSegmentIndex == 0) {  // new note button
            CGPoint gesturePoint = [sender locationInView: self.Background];
            CGPoint point = [[TransformUtil sharedManager] getGlobalCoordinate:gesturePoint];
            NoteItem2 *newNote = [[NoteItem2 alloc] initNote:@"text..." withPoint:point];
            [self setInitialNote:newNote];
            [self.NotesCollection addNote:newNote withKey:newNote.note.key];  // TODO: set key after saving to firebase
            
            [self addNoteToViewWithHandlers:newNote];
            [self setSelectedObject:newNote];
            [newNote becomeFirstResponder];  // puts cursor on text field
            [newNote.noteTextView selectAll:nil];  // highlights text
        } else
        {
            [self setSelectedObject: viewHit];
//            if ([viewHit isKindOfClass: [GroupItem class]])
            if (viewHit.tag == 100)
            {
                GroupItem *gi = (GroupItem *) [viewHit superview];
                NSString *titleNoteString = [self.NotesCollection getNoteTitleFromKey: [gi.group titleNoteKey]];
                NSLog(@"Group title: %@", titleNoteString);
                NSLog(@"Group key: %@", [gi.group key]);
            }
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
    
    sortedArray = [self.groupsCollection.groups2 keysSortedByValueUsingComparator: ^(GroupItem *group1, GroupItem *group2) {

        float firstArea = group1.group.width * group1.group.height;
        float secondArea = group2.group.width * group2.group.height;
        
        if ( firstArea > secondArea ) {
            
            return (NSComparisonResult) NSOrderedAscending;
        }
        if ( firstArea < secondArea ) {
            
            return (NSComparisonResult) NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];

    for (NSString *key in sortedArray) {
        float area = [self.groupsCollection getGroupAreaFromKey:key];
        NSLog(@"Group area: %f", area);
        [self.groupsCollection.groups2[key] removeFromSuperview];
        [self.GroupsView addSubview:self.groupsCollection.groups2[key]];
    }
    
    [self.drawGroupView setFrame:(CGRect){0,0,0,0}];
    [self.drawGroupView removeFromSuperview];

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
