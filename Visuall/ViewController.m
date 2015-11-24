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
#import "TransformUtil.h"
#import "GroupItem.h"
#import "AppDelegate.h"

@interface ViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *Background;
@property (weak, nonatomic) IBOutlet UIView *GroupsView;
@property (weak, nonatomic) IBOutlet UIView *NotesView;
@property (strong, nonatomic) NSMutableArray *helloWorlds;
@property (strong, nonatomic) NotesCollection *NotesCollection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property UIView *currentGroupView;
@property NSMutableArray *groupViews;
@property CGPoint currentGroupViewStart;
@property UIView *lastSelectedObject;
@property UIGestureRecognizer *panBackground;
@property NSManagedObjectContext *moc;
@end

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.moc = appDelegate.managedObjectContext;
    
    UIPanGestureRecognizer *panBackground = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(handlePanBackground:)];
    self.panBackground = panBackground;
    [self.Background addGestureRecognizer: panBackground];
    
    
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handlePinchBackground:)];
    [self.Background addGestureRecognizer:pinchBackground];
    
    self.NotesCollection = [[NotesCollection alloc] init];
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
    self.groupViews = [[NSMutableArray alloc] init];
    
    self.NotesView.opaque = NO;
    self.NotesView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection.Notes andGroups: self.groupViews];
    
    if ([[TransformUtil sharedManager] zoom] > 1.0){
        [self.Background removeGestureRecognizer: self.panBackground];
    } else if ( ![self.Background.gestureRecognizers containsObject:self.panBackground] ){
        [self.Background addGestureRecognizer: self.panBackground];
    }
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
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            self.currentGroupView.frame = [self createGroupViewRect:self.currentGroupViewStart withEnd:currentGroupViewEnd];
            
            // Make a copy of the current group view and add it to our list of group views
            float zoom = [[TransformUtil sharedManager] zoom];
            GroupItem *currentGroupItem = [[GroupItem alloc]
                                           initWithPoint:[[TransformUtil sharedManager] getGlobalCoordinate: self.currentGroupView.frame.origin]
                                            andWidth:self.currentGroupView.frame.size.width / zoom
                                            andHeight:self.currentGroupView.frame.size.height / zoom];
            
            [self.groupViews addObject:currentGroupItem];
            
            // Sort by area of group view
            NSArray *sortedArray;

            sortedArray = [self.groupViews sortedArrayUsingComparator:^NSComparisonResult(GroupItem *first, GroupItem *second) {
                float firstArea = first.frame.size.height * first.frame.size.width;
                float secondArea = second.frame.size.height * second.frame.size.width;
                return firstArea < secondArea;
            }];

            // Render all the group views
            for (GroupItem *groupItem in sortedArray) {
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handlePanGroup:)];
                [groupItem addGestureRecognizer: pan];
                [self.GroupsView addSubview:groupItem];
            }
            
            [self.currentGroupView setFrame:(CGRect){0,0,0,0}];
            [self.currentGroupView removeFromSuperview];
            // set currentGroupItem as lastSelectedObject
            [self setSelectedObject:currentGroupItem];
        }
    }
    else
    {
        [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection.Notes withGroups: self.groupViews];
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

- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
    // TODO: at start of pan, find all children. Then during pan update the child coordinates
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        GroupItem *groupItem = (GroupItem *)gestureRecognizer.view;
        NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
        for (NoteItem *ni in self.NotesCollection.Notes) {
            if ([groupItem isNoteInGroup:ni]) {
                NSLog(@"Note name in group: %@", ni.note.title);
                [notesInGroup addObject:ni];
            }
        }
        [groupItem setNotesInGroup: notesInGroup];
    }
    if ( [gestureRecognizer.view respondsToSelector:@selector(handlePanGroup2:)] ) {
        GroupItem *groupItem = (GroupItem *)gestureRecognizer.view;
        [groupItem handlePanGroup2:gestureRecognizer];
        [self setSelectedObject:groupItem];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Should remove keyboard here again");
    [textField resignFirstResponder];
    return YES;
}


- (void) attachAllNotes
{
    for (NoteItem *ni in self.NotesCollection.Notes) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        [ni addGestureRecognizer: pan];
        [self.NotesView addSubview:ni];
        ni.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self                                                 selector:@selector(textFieldDidEndEditing:)
                                                     name:@"UITextFieldTextDidEndEditingNotification"
                                                   object:nil];

    }
}

- (void) addNoteToViewWithHandlers:(NoteItem *)note
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    [note addGestureRecognizer: pan];
    [self.NotesView addSubview:note];
    self.lastSelectedObject = note;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditing:)
                                                 name:@"UITextFieldTextDidEndEditingNotification"
                                               object:nil];

}

- (void)textFieldDidEndEditing:(NSNotification *)notification
{
    if ([notification.self isKindOfClass:[NoteItem class]]) {
        NoteItem *editedNote = (NoteItem *)notification.self;
        editedNote.note.title = editedNote.text;
        [self setSelectedObject:editedNote];
    }
}


- (IBAction) handeTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        if (self.modeControl.selectedSegmentIndex == 0) {
            
            // grab coordinates
            CGPoint gesturePoint = [sender locationInView:sender.view];
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
                //create a new note
                CGPoint point = [[TransformUtil sharedManager] getGlobalCoordinate:gesturePoint];
                NoteItem *newNote = [[NoteItem alloc] initNote:titleTextField.text andPoint:point andText:paragraphTextField.text];
                //stick it with the other notes
                [self.NotesCollection addNote:newNote];
                [self addNoteToViewWithHandlers:newNote];
            }];
            
            //define cancel action
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // noop
            }];
            
            [alertController addAction:alertAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
           

        }
    }
}

- (IBAction)onDeletePressed:(UIBarButtonItem *)sender {
    NSLog(@"Kill all humans");
    if (self.lastSelectedObject) {
        NSLog(@"%@", self.lastSelectedObject);
        NSManagedObject *objectToDelete;
        if ([self.lastSelectedObject isKindOfClass:[NoteItem class]]) {
            NSLog(@"puplet");
            NoteItem *noteToDelete = (NoteItem *)self.lastSelectedObject;
            objectToDelete = [self.moc existingObjectWithID:noteToDelete.note.objectID error:nil];
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]]) {
            NSLog(@"woofarf");
            GroupItem *groupToDelete = (GroupItem *)self.lastSelectedObject;
            objectToDelete = [self.moc existingObjectWithID:groupToDelete.group.objectID error:nil];
        }
        //remove view from the view
        [self.moc deleteObject:objectToDelete];
        [self.lastSelectedObject removeFromSuperview];
        self.lastSelectedObject = nil;
    }
}


- (void)setSelectedObject:(UIView *)object
{
    if ([object isKindOfClass:[NoteItem class]]) {
        NoteItem *noteToSet = (NoteItem *)object;
        [noteToSet saveToCoreData];
        self.lastSelectedObject = noteToSet;
    } else if ([object isKindOfClass:[GroupItem class]]) {
        NSLog(@"schnickelfritz");
        GroupItem *groupToSet = (GroupItem *)object;
        [groupToSet saveToCoreData];
        self.lastSelectedObject = groupToSet;
        [self.groupViews removeObjectIdenticalTo:groupToSet];
    }
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
