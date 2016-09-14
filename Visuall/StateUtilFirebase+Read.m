//
//  StateUtilFirebase+Read.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtilFirebase+Read.h"

@implementation StateUtilFirebase (Read)

-(void) loadNoteFromRef: (FIRDatabaseReference *) noteRef
{
    [noteRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if ( [self isSnapshotFromLocalDevice: snapshot] && self.allNotesLoadedBool )
         {
             return;
         }
         else if( [self.notesCollection getNoteFromKey: snapshot.key] && self.allNotesLoadedBool )  // If the note already exists in the collection
         {
             NoteItem2 *ni = [self.notesCollection getNoteItemFromKey: snapshot.key];
             [ni updateNoteItem: snapshot.key andValue: snapshot.value];
         }
         else {
             
             NoteItem2 *newNote = [[NoteItem2 alloc] initNoteFromFirebase: noteRef.key andValue:snapshot.value];
             [self.notesCollection addNote:newNote withKey:snapshot.key];
//             __callbackNoteItem(newNote);
//            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(addNoteToViewWithHandlers:) name:@"addNoteToViewWithHandlers" object:nil];
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
    [groupRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
//         if( [snapshot.value[@"data"][@"image"] boolValue] )
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

- (void) allNotesDidLoad
{
    self.allNotesLoadedBool = YES;
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
