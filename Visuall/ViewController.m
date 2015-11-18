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
#import "NavigationUtil.h"

@interface ViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *helloWorld;
@property (weak, nonatomic) IBOutlet UITextField *helloWorldTwo;
@property (weak, nonatomic) IBOutlet UITextField *helloWorldThree;
@property (strong, nonatomic) IBOutlet UIView *Background;
@property (strong, nonatomic) NSMutableArray *helloWorlds;
@property float scale;
@property NavigationUtil *Navigation;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.Navigation = [NavigationUtil sharedManager];
    NSLog(@"%f", self.Navigation.scale);
//    NSLog(@"%f", NavigationUtil._scale]);
//    float s = [[NavigationUtil sharedManager] get]
    
//    self.helloWorld.userInteractionEnabled = YES;  // not required?
//    NSArray *helloWorlds = @[self.helloWorld, self.helloWorldTwo, self.helloWorldThree];
//    self.helloWorlds = @[self.helloWorld, self.helloWorldTwo, self.helloWorldThree];
//    self.helloWorlds initWithObjects:<#(nonnull id), ...#>, ni
    self.helloWorlds = [[NSMutableArray alloc]
                        initWithObjects: self.helloWorld, self.helloWorldTwo, self.helloWorldThree, nil];

    
    for (UITextField* hw in self.helloWorlds) {
        hw.delegate = self;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        [hw addGestureRecognizer:pan];
    }
    
    UIPanGestureRecognizer *panBackground = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(handlePanBackground:)];
    [self.Background addGestureRecognizer: panBackground];
    
    // pinch background
    UIPinchGestureRecognizer *pinchBackground = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handlePinchBackground:)];
    [self.Background addGestureRecognizer:pinchBackground];
    
    self.scale = 1.0;

//    Note *myNote = [[Note alloc] initWithString:@"Hello world 4" andCenterX:100.0 andCenterY:100.0];
//    UIView *uiv = [myNote getView];
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(handlePan:)];
//    [uiv addGestureRecognizer:pan];
//    [self.view addSubview: uiv];
    
    NotesCollection *nc = [[NotesCollection alloc] init];
    [nc initializeNotes];
//    for (UITextField *view in [nc getNoteViews]) {
    for (UIView *view in nc.Notes) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handlePan:)];
        [view addGestureRecognizer: pan];
        [self.view addSubview:view];
    }
    
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer
{
    [self.Navigation handlePinchBackground:gestureRecognizer withNotes:self.helloWorlds];
}

- (void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
{
    [self.Navigation handlePanBackground:gestureRecognizer withNotes: self.helloWorlds];
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    
//    id *uiv = gestureRecognizer.view;
    if ( [gestureRecognizer.view respondsToSelector:@selector(handlePan2:)] ) {
        NoteItem *nv = (NoteItem *)gestureRecognizer.view;
        [nv handlePan2:gestureRecognizer];
    }
//    utf
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
//        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
//
//        [gestureRecognizer.view setTransform:
//            CGAffineTransformTranslate(gestureRecognizer.view.transform, translation.x, translation.y)];
//        [gestureRecognizer setTranslation: CGPointZero inView:gestureRecognizer.view];
//        NSLog(@"%f, %f", translation.x, translation.y);
//    }
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
