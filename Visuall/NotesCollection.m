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
#import "AppDelegate.h"

@interface NotesCollection () <UIGestureRecognizerDelegate>
@end


@implementation NotesCollection


- (void) initializeNotes
{
//<<<<<<< HEAD
    self.Notes = [NSMutableArray new];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Note"];
    
    NSArray *notesCD = [moc executeFetchRequest:request error:nil];
    NSLog(@"Fetching Notes from Core Data...found %lu notes", (unsigned long)notesCD.count);
    for (Note *note in notesCD) {
        [self.Notes addObject:[[NoteItem alloc] initNote:note]];
    }
//=======
//    self.Notes = [[NSMutableArray alloc] init];
//    NoteItem *ni = [[NoteItem alloc] initNote:@"Hello World 0 asdfasdfasdfasdf" andPoint:(CGPoint){ 150, 150 } andText:@""];
//    NoteItem *ni2 = [[NoteItem alloc] initNote:@"Hello World 1" andPoint:(CGPoint){ 200, 300 } andText:@""];
//    [self.Notes addObject:ni];
//    [self.Notes addObject:ni2];
//>>>>>>> improved editting of notes - width increases as you type
}

//method to add single note dynamically from main view
- (void) addNote:(NoteItem *)newNote
{
    [self.Notes addObject:newNote];
}

@end
