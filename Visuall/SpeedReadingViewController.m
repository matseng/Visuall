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

NSMutableArray *__notesToRead;
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
    
    if( [self.visuallState selectedVisualItem] != nil
       && [[self.visuallState selectedVisualItem] isGroupItem] )
    {
        GroupItem *gi = [[self.visuallState selectedVisualItem] getGroupItem];
        __notesToRead = [[NSMutableArray alloc] init];
        [[self.visuallState notesCollection] myForIn:^(NoteItem2 *ni)
         {
             if ( [gi isNoteInGroup:ni])
             {
                 [__notesToRead addObject: ni];
             }
         }];
        
    }
    if (__notesToRead == nil || __notesToRead.count == 0)
    {
        return NO;
    }
    else
    {
        // TODO (Mar 28, 2017): Sort list of notes by Y-coordinate
        for (NoteItem2 *ni in __notesToRead)
        {
//            NSString *noteString = ni.note.title;
            NSArray *words = [ni.note.title componentsSeparatedByString: @" "];
            for (NSString *word in words)
            {
                [__wordsToRead addObject:word];
                NSLog(@"\n setupSpeedReading %@:", word);
            }
        }
    }
    return YES;
    
}



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
