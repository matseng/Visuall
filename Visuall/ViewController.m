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

@interface ViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *Background;
@property (strong, nonatomic) NSMutableArray *helloWorlds;
@property (strong, nonatomic) NotesCollection *NotesCollection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property UIView *currentGroupView;
@property NSMutableArray *groupViews;
@property CGPoint currentGroupViewStart;
@end

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor clearColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panBackground = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(handlePanBackground:)];
    
//    panBackground.cancelsTouchesInView = NO;
    
    [self.Background addGestureRecognizer: panBackground];
    
    
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handlePinchBackground:)];
    [self.Background addGestureRecognizer:pinchBackground];
    
    self.NotesCollection = [[NotesCollection alloc] init];
    [self.NotesCollection initializeNotes];
    [self attachAllNotes];
    
    // Initialize the rectangle group selection view
    self.currentGroupView = [[UIView alloc] init];
    self.currentGroupView.backgroundColor = GROUP_VIEW_BACKGROUND_COLOR;
    self.currentGroupView.layer.borderColor = GROUP_VIEW_BORDER_COLOR;
    self.currentGroupView.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
    
    // Initlialize the mutable array that holds our group UIViews
    self.groupViews = [[NSMutableArray alloc] init];
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection.Notes];
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
        NSLog(@"sucka");
    }
    else if (self.modeControl.selectedSegmentIndex == 2)
    {
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            self.currentGroupViewStart = [gestureRecognizer locationInView:gestureRecognizer.view];
            
            [self.view addSubview:self.currentGroupView];
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
            id copyOfView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.currentGroupView]];
            [self.groupViews addObject:copyOfView];
            
            // Render all the group views
            for (UIView *groupView in self.groupViews) {
                groupView.backgroundColor = GROUP_VIEW_BACKGROUND_COLOR;
                groupView.layer.borderColor = GROUP_VIEW_BORDER_COLOR;
                groupView.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
                
                [self.view addSubview:groupView];
            }
        }
    }
    else
    {
        [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection.Notes];
    }
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    if ( [gestureRecognizer.view respondsToSelector:@selector(handlePan2:)] ) {
        NoteItem *nv = (NoteItem *)gestureRecognizer.view;
        [nv handlePan2:gestureRecognizer];
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
    for (UIView *view in self.NotesCollection.Notes) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        [view addGestureRecognizer: pan];
        [self.view addSubview:view];
    }
}

- (void) addNoteToViewWithHandlers:(NoteItem *)note
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    [note addGestureRecognizer: pan];
    [self.view addSubview:note];

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
                NoteItem *newNote = [[NoteItem alloc] initNote:titleTextField.text andPoint:gesturePoint];
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



//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
