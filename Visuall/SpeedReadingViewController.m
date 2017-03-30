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

@end

@implementation SpeedReadingViewController

NSMutableArray *__notesInGroup;
NSMutableArray *__notesSorted;
NSMutableArray *__arrowsInGroup;
NSMutableArray *__wordsToRead;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"\n SpeedReadingViewController.h");
    
    UILabel *label = [[UILabel alloc] init];
    
    if( [self setupSpeedReading] )
    {
        label.text = @"Will speed read here";
    }
    else
    {
        label.text = @"Select a group that contains text \n to proceed with Speed Reading";
    }
    
    label.numberOfLines = 0;
    [label setFont: [UIFont fontWithName:@"Arial Rounded MT Bold" size:14.0f]];
    [label sizeToFit];
    label.center = CGPointMake(self.preferredContentSize.width / 2, self.preferredContentSize.height / 2);
    
    [self.view addSubview: label];
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
        [self depthFirstTraverse: ni];
    }
    
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

- (void) depthFirstTraverse: (NoteItem2 *) ni
{
    [__notesInGroup removeObject: ni];
    [__notesSorted addObject: ni];
    NSArray *targetNotesSorted = [self getTargetNotes: ni];
    for (NoteItem2 *niTarget in targetNotesSorted)
    {
        [self depthFirstTraverse: niTarget];
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
         float x2 = ai2.endPoint.y;
         
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
