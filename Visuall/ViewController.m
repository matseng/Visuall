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

@end

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
    
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection.Notes];
}

- (void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (self.modeControl.selectedSegmentIndex == 2) {
//        hijack this instance to allow placing new groups

        NSLog(@"sucka");
    } else {
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
            
            [alertController addAction:alertAction];
            [self presentViewController:alertController animated:YES completion:nil];
           

        }
    }
}



//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
