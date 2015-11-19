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
    NoteItem *utf = [[NoteItem alloc] initWithFrame:CGRectMake(100, 100, 300, 25)];
    utf.text = @"Hello World 1";
    
    
    [self.Notes addObject:utf];
}



@end
