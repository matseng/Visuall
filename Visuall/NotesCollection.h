//
//  NotesCollection.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteItem2.h"

@interface NotesCollection : NSObject

@property NSMutableArray *Notes;

@property NSMutableDictionary *Notes2;  // hold NoteItem2 instances

//- (void) initializeNotes;

- (void) addNote:(NoteItem2 *)newNote withKey: (NSString *) key;

- (void) myForIn: (void (^)(NoteItem2 *ni)) myFunction;

- (float) getNoteFontSizeFromKey: (NSString *) key;

- (NSString *) getNoteTitleFromKey: (NSString *) key;

- (NoteItem2 *) getNoteItemFromKey: (NSString *) key;

- (Note2 *) getNoteFromKey: (NSString *) key;

- (BOOL) deleteNoteGivenKey: (NSString *) key;

@end
