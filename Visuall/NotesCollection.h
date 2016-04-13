//
//  NotesCollection.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteItem.h"
#import "NoteItem2.h"

@interface NotesCollection : NSObject

@property NSMutableArray *Notes;

- (void) initializeNotes;
- (void) addNote:(NoteItem2 *)newNote;


//- (NSMutableArray *) getNoteViews;

@end
