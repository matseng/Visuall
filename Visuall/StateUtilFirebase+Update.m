//
//  StateUtilFirebase+Update.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtilFirebase+Update.h"

@implementation StateUtilFirebase (Update)

- (void) updateNoteFromRef: (FIRDatabaseReference *) noteRef
{
    [noteRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if ( [self isSnapshotFromLocalDevice: snapshot] || !self.allNotesLoadedBOOL)
         {
             return;
         }
         
         NoteItem2 *ni = [self.notesCollection getNoteItemFromKey: snapshot.key];
        [ni updateNoteItem: snapshot.key andValue: snapshot.value];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadGroupFromRef: %@", error.description);
         NSLog(@"\n ^^^ IGNORE the above error if it follows a remote delete event ^^^");
         NSLog(@"\n Delete operation is taken care of in loadListOfGroupsFromRef");
     }];
}

- (void) updateGroupFromRef: (FIRDatabaseReference *) groupRef
{
    [groupRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
    {
        if ( [self isSnapshotFromLocalDevice: snapshot] || !self.allGroupsLoadedBOOL)
        {
            return;
        }
        
        GroupItem *gi = [self.groupsCollection getGroupItemFromKey: snapshot.key];
        [gi updateGroupItem: snapshot.key andValue: snapshot.value];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadGroupFromRef: %@", error.description);
         NSLog(@"\n ^^^ IGNORE the above error if it follows a remote delete event ^^^");
         NSLog(@"\n Delete operation is taken care of in loadListOfGroupsFromRef");
     }];
    
}



@end
