//
//  NotesCollection.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteItem.h"

@interface NotesCollection : NSObject

@property NSMutableArray *Notes;

- (void) initializeNotes;
- (void) addNote:(NoteItem *)newNote;


//- (NSMutableArray *) getNoteViews;

@end
