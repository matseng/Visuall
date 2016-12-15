//
//  StateUtilFirebase+Delete.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtilFirebase+Delete.h"

@implementation StateUtilFirebase (Delete)


/*
 * Name: removeValue
 * Param: (UIView *) view that is a note or group item
 * Description: Removes the item from its corresponding firebase table, removes the item's key from its visuall table, and decrements its counter
 */


- (void) removeValue: (UIView *) view
{
    if( [view isNoteItem])
    {
        // TODO (Aug 11, 2016): Consider changing operations below to nested callbacks or promises.
        // Also need to delete note from NotesCollection and set note to nil via [ni delete:nil];
        // Step 1 of 3: Delete note from notes table
        NoteItem2 *ni = [view getNoteItem];
        FIRDatabaseReference *deleteNoteRef = [self.notesTableRef child: ni.note.key];
        [deleteNoteRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            NSLog(@"error: %@", error);
            NSLog(@"key: %@", ref.key);
            if (error) {
                NSLog(@"Note could NOT be removed.");
            } else {
                NSLog(@"Note removed successfully.");
                [ni removeFromSuperview];
            }
        }];
        
        // Step 2 of 3: Delete note key from current visuall table
        FIRDatabaseReference *deleteNoteKeyFromVisuallRef = [[self.visuallsTable_currentVisuallRef child: @"notes"] child: ni.note.key];
        [deleteNoteKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Note key could not be removed.");
            } else {
                NSLog(@"Note key removed successfully.");
            }
        }];
        
        // Step 3 of 3: Decrement notes counter in visuall table
//        FIRDatabaseReference *notesCounterRef = [self.visuallsTable_currentVisuallRef child: @"notes_counter"];
//        [self increaseOrDecreaseCounter: notesCounterRef byAmount:-1];
        
    }
    else if([view isGroupItem])
    {
        // Step 1 of 3: Delete group from groups table
        GroupItem *gi = [view getGroupItem];
        FIRDatabaseReference *deleteGroupRef = [self.groupsTableRef child: gi.group.key];
        [deleteGroupRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group could not be removed.");
            } else {
                NSLog(@"Group removed successfully.");
                [gi removeFromSuperview];
            }
        }];
        
        // Step 2 of 3: Delete group key from current visuall table
        FIRDatabaseReference *deleteGroupKeyFromVisuallRef = [[self.visuallsTable_currentVisuallRef child: @"groups"] child: gi.group.key];
        [deleteGroupKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group key could not be removed.");
            } else {
                NSLog(@"Group key removed successfully.");
            }
        }];
        
        // Step 3 of 3: Decrement groups counter in visuall table
//        FIRDatabaseReference *groupsCounterRef = [self.visuallsTable_currentVisuallRef child: @"groups_counter"];
//        [self increaseOrDecreaseCounter: groupsCounterRef byAmount:-1];
        
        // Step 4: Delete an image if group contains an image)
        if ( [gi isImage] )
        {
            NSString *fileName = [gi.group.key stringByAppendingString: @".jpg"];
            FIRStorageReference *deleteImageRef = [self.storageImagesRef child: fileName];
            [deleteImageRef deleteWithCompletion:^(NSError *error){
                if (error != nil) {
                    NSLog(@"Image could NOT be removed.");
                } else {
                    NSLog(@"Image removed successfully.");
                }
            }];
        }
    }
    else if( [view isArrowItem] )
    {
        // Step 1 of 3: Delete group from groups table
        ArrowItem *ai = [view getArrowItem];
        FIRDatabaseReference *deleteItemRef = [self.arrowsTableRef child: ai.key];
        [deleteItemRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group could not be removed.");
            } else {
                NSLog(@"Group removed successfully.");
                [ai removeFromSuperview];
            }
        }];
        
        // Step 2 of 3: Delete group key from current visuall table
        FIRDatabaseReference *deleteItemKeyFromVisuallRef = [[self.visuallsTable_currentVisuallRef child: @"arrows"] child: ai.key];
        [deleteItemKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group key could not be removed.");
            } else {
                NSLog(@"Group key removed successfully.");
            }
        }];
    }
    else if( [view isDrawView] )
    {
        // Step 1 of 2: Delete path from paths table
        PathItem *pi = [view getPathItem];
        FIRDatabaseReference *deleteItemRef = [self.pathsTableRef child: pi.key];
        [deleteItemRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Path could not be removed.");
            } else {
                NSLog(@"Path removed successfully.");
//                [ai removeFromSuperview]; // TODO (Dec 14, 2016):
            }
        }];
        
        // Step 2 of 2: Delete path key from current visuall table
        FIRDatabaseReference *deleteItemKeyFromVisuallRef = [[self.visuallsTable_currentVisuallRef child: @"paths"] child: pi.key];
        [deleteItemKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Path key could not be removed.");
            } else {
                NSLog(@"Path key removed successfully.");
            }
        }];
    }
    
}


@end
