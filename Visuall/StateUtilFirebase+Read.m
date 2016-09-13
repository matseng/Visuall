//
//  StateUtilFirebase+Read.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 9/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtilFirebase+Read.h"

@implementation StateUtilFirebase (Read)


-(void) loadGroupFromRef: (FIRDatabaseReference *) groupRef
{    
    [groupRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [snapshot.value[@"data"][@"image"] boolValue] )
         {
             GroupItemImage *newGroup = [[GroupItemImage alloc] initGroup:snapshot.key andValue:snapshot.value];
             [self.groupsCollection addGroup: newGroup withKey:snapshot.key];
             self.callbackGroupItem(newGroup); // TODO (Sep 12, 2016):
//                 [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(addGroupItemToMVC:) name:@"refreshGroupsView" object:nil];
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshGroupsView" object: nil];
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
             self.callbackGroupItem(newGroup);
         }
         
         if (++self.numberOfGroupsLoaded == self.numberOfGroupsToBeLoaded)
         {
             [self allGroupsLoaded];
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

@end
