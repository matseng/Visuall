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
    for (UIView *view in self.NotesCollection.Notes) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        [view addGestureRecognizer: pan];
        [self.view addSubview:view];
    }
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection.Notes];
}

- (void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection.Notes];
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

- (IBAction)handeTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint gesturePoint = [sender locationInView:sender.view];
        if (self.modeControl.selectedSegmentIndex == 0) {
            NSLog(@"we in note mode beeeetches %f %f", gesturePoint.x, gesturePoint.y);
        }
        if (self.modeControl.selectedSegmentIndex == 1) {
            NSLog(@"we in arrow mode beeeetches %f %f", gesturePoint.x, gesturePoint.y);
        }
        if (self.modeControl.selectedSegmentIndex == 2) {
            NSLog(@"we in group mode beeeetches %f %f", gesturePoint.x, gesturePoint.y);
        }
    }
}


//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
