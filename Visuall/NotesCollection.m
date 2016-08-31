//
//  NotesCollection.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NotesCollection.h"
#import "Note+CoreDataProperties.h"
#import "NoteItem2.h"
#import "AppDelegate.h"

@interface NotesCollection () <UIGestureRecognizerDelegate>
@end


@implementation NotesCollection


//method to add single note dynamically from main view
- (void) addNote:(NoteItem2 *) newNote withKey: (NSString *) key
{
    if ( !self.Notes2) {
        self.Notes2 = [[NSMutableDictionary alloc] init];
    }
    newNote.key = key;
    self.Notes2[key] = newNote;
}

- (void) myForIn: (void (^)(NoteItem2 *ni)) myFunction
{
    for (NSString *key in self.Notes2) {
        NoteItem2 *ni = self.Notes2[key];
        myFunction(ni);
    }
}

- (float) getNoteFontSizeFromKey: (NSString *) key
{
    return [[self.Notes2[key] note] fontSize];
}

- (NSString *) getNoteTitleFromKey: (NSString *) key
{
    return [[self.Notes2[key] note] title];
}

- (NoteItem2 *) getNoteItemFromKey: (NSString *) key
{
    return self.Notes2[key];
}

- (Note2 *) getNoteFromKey: (NSString *) key
{
    NoteItem2 *ni = self.Notes2[key];
    return ni.note;
}

- (BOOL) deleteNoteGivenKey: (NSString *) key
{
    if([self.Notes2 objectForKey: key]) {
        [self.Notes2 removeObjectForKey: key];
        return YES;
    }
    return NO;
}

@end