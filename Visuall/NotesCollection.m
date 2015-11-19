//
//  NotesCollection.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NotesCollection.h"
#import "Note.h"
#import "NoteItem.h"

@interface NotesCollection () <UIGestureRecognizerDelegate>
@end


@implementation NotesCollection


- (void) initializeNotes
{
    self.Notes = [[NSMutableArray alloc] init];
    NoteItem *ni = [[NoteItem alloc] initNote:@"Hello World 4" andPoint:(CGPoint){ 150, 150 }];
    [self.Notes addObject:ni];
}



@end
