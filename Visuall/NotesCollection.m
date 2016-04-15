//
//  NotesCollection.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/10/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NotesCollection.h"
#import "Note+CoreDataProperties.h"
#import "NoteItem.h"
#import "NoteItem2.h"
#import "AppDelegate.h"

@interface NotesCollection () <UIGestureRecognizerDelegate>
@end


@implementation NotesCollection


//method to add single note dynamically from main view
- (void) addNote:(NoteItem2 *)newNote withKey: (NSString *) key
{
    if ( !self.Notes2) {
        self.Notes2 = [[NSMutableDictionary alloc] init];
    }
    
    self.Notes2[key] = newNote;
}

@end
