//
//  SpeedReadingViewController.m
//  
//
//  Created by Michael Tseng MacBook on 3/27/17.
//
//

#import "SpeedReadingViewController.h"
#import "UserUtil.h"

@interface SpeedReadingViewController ()
@property (weak, nonatomic) IBOutlet UIView *squareOuterContainer;
@property (weak, nonatomic) IBOutlet UIView *topHalfContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomHalfContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewOfWordsRead;

@end

@implementation SpeedReadingViewController

NSMutableArray *__notesInGroup;
NSMutableArray *__notesSorted;
NSMutableArray *__arrowsInGroup;
NSMutableArray *__wordsToRead;
NSTimer *__timer;
BOOL __rewindOn;
BOOL __playOn;
BOOL __fastForwardOn;

NSMutableDictionary *__buttonState;

UIColor *__thumbTintColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"\n SpeedReadingViewController.h");
    
    __buttonState = [@{
                      @"rewind": @(NO),
                      @"play": @(NO),
                      @"paused": @(YES),
                      @"fastForward": @(NO)
                      } mutableCopy];
    
    __thumbTintColor = self.progressSlider.thumbTintColor;
    
//    self.labelForWordToRead = [[UILabel alloc] init];
    
    self.wordsPerMinute = 120.0f;
    self.index = 0;
    
    if( [self setupSpeedReading] )
    {
        self.labelForWordToRead.text = @"1 2 3 4 5 6";
        [self setTimerWithCurrentWordsPerMinute];
    }
    else
    {
        self.labelForWordToRead.text = @"Select a group that contains text \n to proceed with Speed Reading";
    }
    [self updateLabelStyle];
    [self updateProgressViewOfWordsRead];
    [self setPauseToOn];
    [self.topHalfContainer addSubview: self.labelForWordToRead];

    self.progressSlider.continuous = YES;
    [self.progressSlider addTarget:self
               action:@selector(progessSliderChanged)
     forControlEvents:UIControlEventValueChanged];
}

- (void) progessSliderChanged
{
    float percentage = self.progressSlider.value;
    self.index = (int) round(__wordsToRead.count * percentage);
    self.labelForWordToRead.text = __wordsToRead[self.index];
    [self setPauseToOn];
}

- (void) handleSingleTap:(UITapGestureRecognizer *) recognizer
{
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    //Do stuff here...
}

- (void) setTimerWithCurrentWordsPerMinute
{
    [self setTimerWithTimeInterval: (1 / self.wordsPerMinute * 60) ];
}

- (void) setTimerWithTimeInterval: (float) interval
{
    [__timer invalidate];
    __timer = [NSTimer scheduledTimerWithTimeInterval: interval
                                               target:self
                                             selector:@selector(actionTimer)userInfo:nil
                                              repeats:YES];
}

- (void) setButtonStateOnForKey: (NSString *) key
{
    for (NSString *k in __buttonState.allKeys)
    {
        [__buttonState setValue: @(NO) forKey: k];  // turn the rest of the button states to NO (off)
    }
    [__buttonState setValue: @(YES) forKey: key];
}


- (void) actionTimer
{
    if ( [__buttonState[@"paused"] boolValue] )
    {
        return;
    }
    
    if (self.index < 0 )  // Stop timer if fully rewound
    {
        self.index = 0;
        [self updateProgressViewOfWordsRead];
        [self setPauseToOn];
    }
    else if ( self.index >= __wordsToRead.count) // Finished reading all words
    {
        [self updateProgressViewOfWordsRead];
        [self setPauseToOn];
        [self.playPauseButton setTitle: @"Replay" forState: UIControlStateNormal];
    }
    else  // Play in progress, or step backward or forward
    {
        self.labelForWordToRead.text = __wordsToRead[self.index];
        [self updateLabelStyle];
        [self updateProgressViewOfWordsRead];
        if ( [__buttonState[@"play"] boolValue] )
        {
            self.index++;
        }
    }
}

- (void) updateProgressViewOfWordsRead
{
    float progress = (float) (self.index) / (__wordsToRead.count - 1);
//    self.progressViewOfWordsRead.progress = progress;
    [self.progressSlider setValue: progress animated: YES];
}

- (IBAction) rewindButtonTapped:(id)sender
{
    [self setPauseToOn];
    --self.index;
    [self updateLabelStyle];
    [self updateProgressViewOfWordsRead];
}

- (IBAction) playPauseButtonTapped:(id)sender
{
    if ( [__buttonState[@"paused"] boolValue] )  // change from paused to play
    {
        [self setPlayToOn];
    }
    else  // change from play to paused
    {
        --self.index;  // equivalent of rounding down so that index matches currently displaced word
        [self setPauseToOn];
    }
}

- (IBAction) fastForwardButtonTapped:(id)sender
{
        [self setPauseToOn];
        ++self.index;
        [self updateLabelStyle];
        [self updateProgressViewOfWordsRead];
}

- (void) setPlayToOn
{
    [self setButtonStateOnForKey: @"play"];
    [self.playPauseButton setTitle: @"Pause" forState: UIControlStateNormal];
    self.progressSlider.thumbTintColor = [UIColor clearColor];
    if (self.index >= __wordsToRead.count)
    {
        self.index = 0;
    }
}

- (void) setPauseToOn
{
    [self setButtonStateOnForKey: @"paused"];
    [self.playPauseButton setTitle: @"Play" forState: UIControlStateNormal];
    self.progressSlider.thumbTintColor = __thumbTintColor;
}

- (void) updateLabelStyle
{
    self.labelForWordToRead.text = __wordsToRead[self.index];
    CGRect frame = self.labelForWordToRead.frame;
    frame.size.width = CGRectInfinite.size.width;
    self.labelForWordToRead.frame = frame;
    [self.labelForWordToRead sizeToFit];
    self.labelForWordToRead.center = CGPointMake(self.topHalfContainer.frame.size.width / 2, self.topHalfContainer.frame.size.height / 2);
}

- (BOOL) setupSpeedReading
{
    GroupItem *gi;
    if( [self.visuallState selectedVisualItem] != nil
       && [[self.visuallState selectedVisualItem] isGroupItem] )
    {
        gi = [[self.visuallState selectedVisualItem] getGroupItem];
        __notesInGroup = [[NSMutableArray alloc] init];
        [[self.visuallState notesCollection] myForIn:^(NoteItem2 *ni)
         {
             if ( [gi isNoteInGroup:ni])
             {
                 [__notesInGroup addObject: ni];
             }
         }];
        
    }
    if (__notesInGroup == nil || __notesInGroup.count == 0)
    {
        return NO;  // given there are no notes to read
    }
    __arrowsInGroup = [[NSMutableArray alloc] init];
    [[self.visuallState arrowsCollection] myForIn:^(ArrowItem *ai)
     {
         if ( [gi isArrowInGroup: ai] )
         {
             [__arrowsInGroup addObject:ai];
         }
     }];

    /*
     Get all arrows in group
     Sort notes by Y coor as below
     Start at top note and add to result array.
     Find all outbound arrows (only need to check subset of arrows from list above).
        - If no outbound arrows, then go to next highest note and restart this step
     Sort each array of arrows by X coor of its head
     For each arrow, follow to next note
     Recusively
     */
    
    // Sort by notes by Y coordinate:
    [__notesInGroup sortUsingComparator: ^(NoteItem2 *ni1, NoteItem2 *ni2)
     {
         
         float y1 = ni1.note.y;
         float y2 = ni2.note.y;
         
         if ( y1 < y2 ) {
             
             return (NSComparisonResult) NSOrderedAscending;
         }
         if ( y1 > y2 ) {
             
             return (NSComparisonResult) NSOrderedDescending;
         }
         
         return (NSComparisonResult)NSOrderedSame;
     }];
    
    NoteItem2 *ni;
    __notesSorted = [[NSMutableArray alloc] init];
    while (__notesInGroup.count > 0)
    {
        ni = __notesInGroup[0];
        [self depthFirstTraverseAroundPerimeter: ni];
    }
    
    __wordsToRead = [[NSMutableArray alloc] init];
    for (NoteItem2 *ni in __notesSorted)
    {
        //            NSString *noteString = ni.note.title;
        NSArray *words = [ni.note.title componentsSeparatedByString: @" "];
        for (NSString *word in words)
        {
            [__wordsToRead addObject:word];
            NSLog(@"\n setupSpeedReading %@:", word);
        }
    }
    
    return YES;  // given there are notes to read
}

- (void) depthFirstTraverseNormalPattern: (NoteItem2 *) ni
{
    [__notesInGroup removeObject: ni];
    [__notesSorted addObject: ni];
    NSArray *targetNotesSorted = [self getTargetNotes: ni];
    for (NoteItem2 *niTarget in targetNotesSorted)
    {
        [self depthFirstTraverseNormalPattern: niTarget];
    }
}

/*
 * Name:
 * Description:
 */
- (void) depthFirstTraverseAroundPerimeter: (NoteItem2 *) ni
{
    [__notesInGroup removeObject: ni];
    NSArray *targetNotesSorted = [self getTargetNotes: ni];
    if (targetNotesSorted.count > 0 )
    {
        for (NoteItem2 *niTarget in targetNotesSorted)
        {
            [__notesSorted addObject: ni];
            [self depthFirstTraverseAroundPerimeter: niTarget];
        }
    }
    else
    {
        [__notesSorted addObject: ni];
    }
}


- (NSMutableArray *) getTargetNotes: (NoteItem2 *) ni
{
    NSMutableArray *notesSortedLeftToRight = [[NSMutableArray alloc] init];
    // Get outbound arrows of ni
    NSMutableArray *outboundArrows = [[NSMutableArray alloc] init];
    for (ArrowItem *ai in __arrowsInGroup)
    {
        if (CGRectContainsPoint(ni.frame, ai.startPoint))
        {
            [outboundArrows addObject: ai];
        }
    }
    
    // Return early if no outbound arrows
    if (outboundArrows.count == 0)
    {
        return notesSortedLeftToRight;  // will have count of zero?
    }
    
    // Sort by arrows by X coordinate:
    [outboundArrows sortUsingComparator: ^(ArrowItem *ai1, ArrowItem *ai2)
     {
         
         float x1 = ai1.endPoint.x;
         float x2 = ai2.endPoint.x;
         
         if ( x1 < x2 ) {
             
             return (NSComparisonResult) NSOrderedAscending;
         }
         if ( x1 > x2 ) {
             
             return (NSComparisonResult) NSOrderedDescending;
         }
         
         return (NSComparisonResult)NSOrderedSame;
     }];
    
    // Check each outbound arrow to see if it terminates on a note
    for (ArrowItem *ai in outboundArrows)
    {
        for (NoteItem2 *ni in __notesInGroup)
        {
            if (CGRectContainsPoint(ni.frame, ai.endPoint))
            {
                [notesSortedLeftToRight addObject: ni];
            }
        }
    }
    
    return notesSortedLeftToRight;
}

/*
 [[[[UserUtil sharedManager] getState] arrowsCollection] myForIn:^(ArrowItem *ai) {
 CGRect rect = self.frame;
 
 if ( CGRectContainsPoint(rect, ai.startPoint) )
 {
 [self.arrowTailsInGroup addObject: ai];  // add overlapping arrow TAILS to this note
 }
 
 if ( CGRectContainsPoint(rect, ai.endPoint) )
 {
 [self.arrowHeadsInGroup addObject: ai];  // add overlapping arrow HEADS to this note
 }
 }];
 */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
