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
@property (weak, nonatomic) IBOutlet UITextField *helloWorld;
@property (weak, nonatomic) IBOutlet UITextField *helloWorldTwo;
@property (weak, nonatomic) IBOutlet UITextField *helloWorldThree;
@property (strong, nonatomic) IBOutlet UIView *Background;
@property (strong, nonatomic) IBOutlet UIView *GroupView;
@property (strong, nonatomic) IBOutlet UIView *NotesView;
@property (strong, nonatomic) NSMutableArray *helloWorlds;
@property (strong, nonatomic) NotesCollection *NotesCollection;
@property (strong, nonatomic) UIPanGestureRecognizer *panBackground;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panBackground = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePanBackground:)];
    self.panBackground = panBackground;
    
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePinchBackground:)];

    self.Background.gestureRecognizers = @[panBackground, pinchBackground];
    
    self.NotesCollection = [[NotesCollection alloc] init];
    [self.NotesCollection initializeNotes];
    for (UIView *view in self.NotesCollection.Notes) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        [view addGestureRecognizer:pan];
        [self.NotesView addSubview:view];
        view.userInteractionEnabled = YES;
    }
    self.NotesView.opaque = NO;
    self.NotesView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePinchBackground:gestureRecognizer withNotes:self.NotesCollection.Notes];
    
    if ([[TransformUtil sharedManager] zoom] > 1.0){
        [self.Background removeGestureRecognizer: self.panBackground];
    } else if ( ![self.Background.gestureRecognizers containsObject:self.panBackground] ){
        [self.Background addGestureRecognizer: self.panBackground];
    }
}

- (void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
{
    [[TransformUtil sharedManager] handlePanBackground2:gestureRecognizer withNotes: self.NotesCollection.Notes];
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

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
