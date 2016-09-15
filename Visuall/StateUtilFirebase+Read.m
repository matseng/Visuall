//
//  StateUtilFirebase+Read.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtilFirebase+Read.h"

@implementation StateUtilFirebase (Read)


- (void) loadNoteFromRef: (FIRDatabaseReference *) noteRef
{
    [noteRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( self.allNotesLoadedBOOL && ![self isSnapshotFromLocalDevice: snapshot] && [self.notesCollection getNoteFromKey: snapshot.key])  // If the note already exists in the collection then update it
         {
             NoteItem2 *ni = [self.notesCollection getNoteItemFromKey: snapshot.key];
             [ni updateNoteItem: snapshot.key andValue: snapshot.value];
         }
         else
         {
             NoteItem2 *newNote = [[NoteItem2 alloc] initNoteFromFirebase: noteRef.key andValue:snapshot.value];
             [self.notesCollection addNote:newNote withKey:snapshot.key];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"addNoteToViewWithHandlers" object: nil userInfo: @{@"data": newNote}];
             
             if (++self.numberOfNotesLoaded == self.numberOfNotesToBeLoaded)
             {
                 [self allNotesDidLoad];
             }
         }
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadNoteFromRef %@", error.description);
     }];
}

- (void) loadGroupFromRef: (FIRDatabaseReference *) groupRef
{
    [groupRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( self.allGroupsLoadedBOOL && ![self isSnapshotFromLocalDevice: snapshot] && [self.groupsCollection getGroupItemFromKey: snapshot.key])  // If the note already exists in the collection then update it
         {
             GroupItem *gi = [self.groupsCollection getGroupItemFromKey: snapshot.key];
             [gi updateGroupItem: snapshot.key andValue: snapshot.value];
             return;
         }

         if( [snapshot.value[@"image"] boolValue] )
         {
             GroupItemImage *newGroup = [[GroupItemImage alloc] initGroup:snapshot.key andValue:snapshot.value];
             [self.groupsCollection addGroup: newGroup withKey:snapshot.key];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"addGroupToViewWithHandlers" object: nil userInfo: @{@"data": newGroup}];
             NSString *fileName = [snapshot.key stringByAppendingString: @".jpg"];
             FIRStorageReference *islandRef = [self.storageImagesRef child: fileName];
             [islandRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
                 if (error != nil) {
                     NSLog(@"\n loadGroupFromRef: error loading an image: %@", error.description);
                 } else {
                     UIImage *islandImage = [UIImage imageWithData:data];
                     [newGroup addImage: islandImage];
                 }
             }];
         }
         else
         {
             GroupItem *newGroup = [[GroupItem alloc] initGroup:snapshot.key andValue:snapshot.value];
             [self.groupsCollection addGroup: newGroup withKey:snapshot.key];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"addGroupToViewWithHandlers" object: nil userInfo: @{@"data": newGroup}];
         }
         
         if (++self.numberOfGroupsLoaded == self.numberOfGroupsToBeLoaded)
         {
             [self allGroupDidLoad];
         }
         
         //         [groupRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
         //          {
         //              if ( [self isSnapshotFromLocalDevice: snapshot] )
         //              {
         //                  return;
         //              }
         //              else if( [self.groupsCollection getGroupItemFromKey: snapshot.key] )  // If the group already exists in the collection
         //              {
         //                  GroupItem *gi = [self.groupsCollection getGroupItemFromKey: snapshot.key];
         //                  [gi updateGroupItem: snapshot.key andValue: snapshot.value];
         //                  return;
         //              }
         //          }];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadGroupFromRef: %@", error.description);
     }];
    
}

/*
 * Name:
 * Description:
 */
- (void) loadArrowFromRef: (FIRDatabaseReference *) arrowRef
{
    [arrowRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( self.allArrowsLoadedBOOL && ![self isSnapshotFromLocalDevice: snapshot] && [self.arrowsCollection getItemFromKey: snapshot.key])  // If the note already exists in the collection then update it
         {
             ArrowItem *ai = (ArrowItem *)[self.arrowsCollection getItemFromKey: snapshot.key];
             [ai updateArrowFromFirebase: snapshot.key andValue: snapshot.value];
             return;
         }
         
         ArrowItem *ai = [[ArrowItem alloc] initArrowFromFirebase: arrowRef.key andValue:snapshot.value];
         [self.arrowsCollection addItem: ai withKey: arrowRef.key];
         [self.ArrowsView addSubview: ai];
         
         if (++self.numberOfArrowsLoaded == self.numberOfArrowsToBeLoaded)
         {
             NSLog(@"\n loadArrowFromRef all arrows loaded");
             self.allArrowsLoadedBOOL = YES;
         }
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadArrowFromRef %@", error.description);
     }];
}

- (void) allNotesDidLoad
{
    self.allNotesLoadedBOOL = YES;
    NSLog(@"\n All notes loaded: %i", self.numberOfNotesLoaded);
}

- (void) allGroupDidLoad
{
    self.allGroupsLoadedBOOL = YES;
    NSLog(@"\n allGroupsLoaded loaded: %i", self.numberOfGroupsLoaded);
    //    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(refreshGroupsView:) name:@"refreshGroupsView" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshGroupsView" object: nil];
}

@end
