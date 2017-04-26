//
//  StateUtilFirebase.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/18/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtilFirebase.h"
#import "UIView+VisualItem.h"
#import "UserUtil.h"
#import "GroupItemImage.h"
#import "ArrowItem.h"
#import "ViewController+Arrow.h"
#import "RegExCategories.h"
#import "StateUtilFirebase+Read.h"
#import "StateUtilFirebase+Update.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface StateUtilFirebase()

@property FIRDatabaseReference *version01TableRef;

@end


@implementation StateUtilFirebase
{
    FIRStorage *__storage;
    
    NSString *__userID;
    
    NSString *_currentVisuallKey;
    
//    void (^self.callbackNoteItem)(NoteItem2 *ni);
    //    void (^_callbackGroupItem)(GroupItem *gi);
    void (^_callbackPublicVisuallLoaded)(void);
//    __block int self.numberOfNotesToBeLoaded;
//    __block int self.numberOfNotesLoaded;
    //    __block int self.numberOfGroupsToBeLoaded;
    //    __block int self.numberOfGroupsLoaded;
    NSString *__localDeviceId;
//    BOOL self.allNotesLoadedBool;
    //    BOOL self.allGroupsLoaded;
}

//+(id)sharedManager {
//
//    static StateUtilFirebase *sharedMyManager = nil;
//
//    @synchronized(self) {
//        if (sharedMyManager == nil) {
//            sharedMyManager = [[self alloc] init];
//            sharedMyManager.zoom = 1.0;
//            sharedMyManager.pan = (CGPoint){0.0,0.0};
//            NSLog(@"RESET ZOOM and PAN");
//        }
//    }
//    return sharedMyManager;
//}

- (void) setUserID: (NSString *) userID
{
    __userID = userID;
    [self loadTableRefs];
}

- (void) loadTableRefs
{
    self.version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    
//        /* CAUTION */ [FIRDatabaseReference goOffline];  // TODO (Sep 1, 2016): TEMP
    
    if ( __userID )
    {
        self.usersTableCurrentUser = [[self.version01TableRef child:@"users"] child: __userID];
    }
    self.visuallsTableRef = [self.version01TableRef child: @"visualls"];
    self.notesTableRef = [self.version01TableRef child: @"notes"];
    self.groupsTableRef = [self.version01TableRef child: @"groups"];
    self.arrowsTableRef = [self.version01TableRef child: @"arrows"];
    self.pathsTableRef = [self.version01TableRef child: @"paths"];
    
    self.publicVisuallsTableRef = [self.version01TableRef child: @"public"];
    __storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [__storage referenceForURL:@"gs://visuall-2f878.appspot.com"];
    self.storageImagesRef = [storageRef child:@"images"];
    __localDeviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (void) loadVisuallsListForCurrentUser
{
    NSString *userID = [[UserUtil sharedManager] userID];
    FIRDatabaseReference *version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *usersTableCurrentUser = [[version01TableRef child:@"users"] child: userID];
    [usersTableCurrentUser keepSynced:YES]; // // TODO (Apr 24, 2017): not sure if this is helping keep data btw firebase and ipad/iphone in sync

    [usersTableCurrentUser observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ( ![snapshot exists] )  // we have a new user
         {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserWithNoVisualls" object: nil userInfo: nil];
         } else
         {
             NSLog(@"My user info: %@", snapshot.value );
             NSLog(@"Number of visualls: %lu", [[snapshot.value[@"visualls-personal"] allKeys] count] );
             // TODO (Apr 22, 2017): Similar to below, go to shared-visuall-invites and get list of shared visuall refs
             // [self getVisuallDetailsForRef: currentVisuallRef andSetToList: __personalVisuallList];

             for (NSString *key in snapshot.value[@"visualls-personal"])
             {
                 FIRDatabaseReference *currentVisuallRef = [[version01TableRef child: @"visualls"] child: key];
                 [self getVisuallDetailsForRef: currentVisuallRef];
             }
             [[[version01TableRef child:@"users"] child: userID] updateChildValues:@{@"date_last_visit": [FIRServerValue timestamp]}];
         }
         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
     }];
    [self loadSharedVisuallInvites];
}

+ (void) loadSharedVisuallInvites
{
    FIRDatabaseReference *version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    NSString *emailKey = [[[[GIDSignIn sharedInstance] currentUser] profile] email];
    emailKey = [emailKey stringByReplacingOccurrencesOfString: @"." withString:@"%2E"];
    FIRDatabaseReference *sharedVisuallInvites = [[version01TableRef child: @"shared-visuall-invites"] child: emailKey];
    [sharedVisuallInvites observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
        if ([snapshot exists])
        {
            for (NSString *key in [snapshot.value allKeys])
            {
                NSLog(@"Invite list: %@", key );
                FIRDatabaseReference *currentVisuallRef = [[version01TableRef child: @"visualls"] child: key];
                [self getVisuallDetailsForRef: currentVisuallRef];
//                [self updateWritePermissionForNewUser:currentVisuallRef.key];
            }
        }
    }];
}

/*
 * Name:
 * Description:
 */
+ (void) getVisuallDetailsForRef: (FIRDatabaseReference *) ref
{
    FIRDatabaseReference *metadataRef = [ref child: @"metadata"];
    
    [metadataRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
//         NSString *title = snapshot.value;
//         [list setValue: title forKey: snapshot.key];
         
         if (snapshot.value != [NSNull null])
         {
             NSMutableDictionary *dict = [snapshot.value mutableCopy];
            [dict setValuesForKeysWithDictionary:@{@"key": ref.key}];
//            [list setValue: snapshot.value[@"title"] forKey: snapshot.key];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"personalVisuallDidLoad" object: nil userInfo: dict];
         }
         else
         {
           [self getVisuallDetailsForRefOld: ref];
         }

         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"getVisuallDetailsForRef: %@", error.localizedDescription);
         NSLog(@"for key: %@", ref.key);
     }];
}

/*
 * Name:
 * Description:
 */
+ (void) getVisuallDetailsForRefOld: (FIRDatabaseReference *) ref
{
    FIRDatabaseReference *titleRef = [ref child: @"title"];
    
    [titleRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
        NSString *title = snapshot.value;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"personalVisuallDidLoad" object: nil userInfo: @{
                                                                                                                     @"key": ref.key,
                                                                                                                     @"title": title
                                                                                                                     }];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"getVisuallDetailsForRef: %@", error.localizedDescription);
        NSLog(@"for key: %@", ref.key);
    }];
}

- (void) setNewUser
{
    FIRUser *user = [[UserUtil sharedManager] firebaseUser];
    if ( user ) {
        NSDictionary *newUserBasicUserInfo = @{
                                               @"full_name" : user.displayName,
                                               @"email": user.email,
                                               @"date-joined": [FIRServerValue timestamp],
                                               @"date-last_visit": [FIRServerValue timestamp]
                                               };
        [[[self.version01TableRef child:@"users"] child: [FIRAuth auth].currentUser.uid] setValue: newUserBasicUserInfo];
    }
    else{
        [self userIsNotSignedInHandler];
    }
}



- (void) userIsNotSignedInHandler
{
    [self loadTableRefs];  // TODO (Aug 17, 2016): Store the userID locally ie not in firebase
}

- (void) loadVisuallsForCurrentUser
{
    
    FIRDatabaseReference *visuallsPersonalRef =  [self.usersTableCurrentUser child: @"visualls/personal"];
    
    [visuallsPersonalRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ( ![snapshot exists] ) //create first Visuall for current user
         {
             [self setValueVisuall: @"My First Visuall"];
         } else
         {  // run thru list of Visualls
             NSDictionary *visuallPersonalKeys = (NSDictionary *) snapshot.value;
             for (NSString *key in visuallPersonalKeys) {
//                 _currentVisuallKey = key;
//                 _visuallsTable_currentVisuallRef = [self.visuallsTableRef child: key];
                 [self loadVisuallFromKey: key];
                 return; // TODO: early termination here only loading the 1st and only visuall
             }
         }
     }];
}

- (void) setValueVisuall: (NSString *) title
{
    FIRDatabaseReference *visuallsPersonalRef =  [self.usersTableCurrentUser child: @"visualls-personal"];
    NSDictionary *visuallDictionary = @{
                                        @"title": title,
                                        @"date-created": [FIRServerValue timestamp],
                                        @"created-by": [FIRAuth auth].currentUser.uid,
                                        @"created-by-first-name": [[[[GIDSignIn sharedInstance] currentUser] profile] givenName],
                                        @"created-by-last-name": [[[[GIDSignIn sharedInstance] currentUser] profile] familyName],
                                        @"created-by-email": [[[[GIDSignIn sharedInstance] currentUser] profile] email],
                                        @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" }
                                        };
    _visuallsTable_currentVisuallRef = [self.visuallsTableRef childByAutoId];
    _currentVisuallKey = self.visuallsTable_currentVisuallRef.key;
    [self.visuallsTable_currentVisuallRef updateChildValues: visuallDictionary];
//    [visuallsPersonalRef updateChildValues: @{self.visuallsTable_currentVisuallRef.key: @"1"} ];
    [visuallsPersonalRef updateChildValues: @{_currentVisuallKey: @"1"} ];
}

/*
 * Name: setValueVisuall
 * Description: Class method to create a new Visuall and add it's key to the current user's list of Visualls
 */
+ (NSMutableDictionary *) setValueVisuall: (NSMutableDictionary *) metadata
{
    NSString *userID = [[UserUtil sharedManager] userID];
    FIRDatabaseReference *version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *usersTableCurrentUser = [[version01TableRef child:@"users"] child: userID];
    FIRDatabaseReference *visuallsPersonalRef =  [usersTableCurrentUser child: @"visualls-personal"];
    FIRDatabaseReference *visuallsTableRef = [version01TableRef child: @"visualls"];
    FIRDatabaseReference *currentVisuallRef = [visuallsTableRef childByAutoId];
    //    FIRDatabaseReference *currentVisuallMetatdataRef = [currentVisuallRef child: @"metadata"];
    
    NSDictionary *visuallDictionary = @{
                                        @"date-created": [FIRServerValue timestamp],
                                        @"created-by": [FIRAuth auth].currentUser.uid,
                                        @"created-by-first-name": [[[[GIDSignIn sharedInstance] currentUser] profile] givenName],
                                        @"created-by-last-name": [[[[GIDSignIn sharedInstance] currentUser] profile] familyName],
                                        @"created-by-email": [[[[GIDSignIn sharedInstance] currentUser] profile] email],
                                        @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" }
                                        };
    [metadata setValuesForKeysWithDictionary: visuallDictionary];
    NSMutableDictionary *dict = [@{@"metadata": metadata,
                                            @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" }} mutableCopy];
    [currentVisuallRef updateChildValues: dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
    {
        [visuallsPersonalRef updateChildValues: @{currentVisuallRef.key: @"1"} ];
    }];
    [metadata setObject: currentVisuallRef.key forKey:@"key"];
    return metadata;
}

+ (void) updateMetadataVisuall: (NSMutableDictionary *) dict
{
    NSString *userID = [[UserUtil sharedManager] userID];
    FIRDatabaseReference *version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *usersTableCurrentUser = [[version01TableRef child:@"users"] child: userID];
    FIRDatabaseReference *visuallsPersonalRef =  [usersTableCurrentUser child: @"visualls-personal"];
    FIRDatabaseReference *visuallsTableRef = [version01TableRef child: @"visualls"];
    FIRDatabaseReference *currentVisuallRef = [visuallsTableRef child: dict[@"key"]];
    FIRDatabaseReference *currentVisuallMetadataRef = [currentVisuallRef child: @"metadata"];
    [dict removeObjectForKey: @"key"];
    [currentVisuallMetadataRef updateChildValues: dict];
}

+ (void) updateWritePermissionForNewUser: (NSString *) visuallKey
{
    NSString *userID = [[UserUtil sharedManager] userID];
    FIRDatabaseReference *version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *usersTableCurrentUser = [[version01TableRef child:@"users"] child: userID];
    FIRDatabaseReference *visuallsPersonalRef =  [usersTableCurrentUser child: @"visualls-personal"];
    FIRDatabaseReference *visuallsTableRef = [version01TableRef child: @"visualls"];
//    FIRDatabaseReference *currentVisuallRef = [visuallsTableRef child: dict[@"key"]];
    FIRDatabaseReference *currentVisuallRef = [visuallsTableRef child: visuallKey];
    FIRDatabaseReference *currentVisuallWritePermissionRef = [currentVisuallRef child: @"write-permission"];
//    FIRDatabaseReference *currentVisuallWritePermissionCurrentUserIDRef = [currentVisuallWritePermissionRef child: [FIRAuth auth].currentUser.uid];
//    [dict removeObjectForKey: @"key"];
    [currentVisuallWritePermissionRef updateChildValues:@{[FIRAuth auth].currentUser.uid : @1}];
}

- (void) loadPublicVisuallsList
{
    
    [self.publicVisuallsTableRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ( ![snapshot exists] )  // we need to create over very first public visual
         {
             NSDictionary *visuallDictionary = @{
                                                 @"title": @"My First Global Visuall",
                                                 @"date-created": [FIRServerValue timestamp],
                                                 @"created-by-userID": [FIRAuth auth].currentUser.uid,
                                                 @"admin" : @{ [FIRAuth auth].currentUser.uid : @"1" },
                                                 @"public": @"1"
                                                 };
             _visuallsTable_currentVisuallRef = [self.visuallsTableRef childByAutoId];
             _currentVisuallKey = self.visuallsTable_currentVisuallRef.key;
             [self.visuallsTable_currentVisuallRef updateChildValues: visuallDictionary];
             [self.publicVisuallsTableRef updateChildValues: @{self.visuallsTable_currentVisuallRef.key: @"1"}];
         }
         else {  // run thru list of Visualls
             NSDictionary *visuallKeys = (NSDictionary *) snapshot.value;
             for (NSString *key in visuallKeys) {
                 _currentVisuallKey = key;
                 _visuallsTable_currentVisuallRef = [self.visuallsTableRef child: key];
                 [self loadVisuallFromKey: key];
                 _callbackPublicVisuallLoaded();
                 return; // TODO: early termination here only loading the 1st and only visuall
             }
         }
         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"loadPublicVisuallsList: %@", error.localizedDescription);
     }];
}

- (void) loadOrCreatePublicVisuall: (NSString *) publicKey
{
    /*
     //    _visuallsTable_currentVisuallRef = [_visuallsTableRef childByAutoId];
     
     //    FIRDatabaseReference *visuallsTable_globalRef = [_visuallsTableRef child: publicKey];
     [__publicTableRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
     if ( ![snapshot exists] )
     {
     NSDictionary *visuallDictionary = @{
     @"title": @"Global Visuall",
     @"date-created": [FIRServerValue timestamp],
     @"created-by": [FIRAuth auth].currentUser.uid,
     @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" },
     @"public": @"1"
     };
     [visuallsTable_globalRef updateChildValues: visuallDictionary];
     } else
     {
     // load public visuall
     }
     } withCancelBlock:^(NSError * _Nonnull error) {
     NSLog(@"loadOrCreateGlobalVisuall: %@", error);
     }];
     */
}

- (void) setCallbackNoteItemCopy: (void (^)(NoteItem2 *ni)) callbackNoteItem
{
    __callbackNoteItem = [callbackNoteItem copy];
};

- (void) setCallbackGroupItem: (void (^)(GroupItem *gi)) callbackGroupItem
{
    __callbackGroupItem = [callbackGroupItem copy];
};

- (void) setCallbackPublicVisuallLoaded:(void (^)(void)) callback
{
    _callbackPublicVisuallLoaded = [callback copy];
};

- (void) loadVisuallFromKey: (NSString *) key
{
    _currentVisuallKey = key;
    _visuallsTable_currentVisuallRef = [self.visuallsTableRef child: key];
    
    FIRDatabaseReference *listOfNoteKeysRef = [[self.visuallsTableRef child:key] child: @"notes"];
    FIRDatabaseReference *listOfGroupKeysRef = [[self.visuallsTableRef child:key] child: @"groups"];
    FIRDatabaseReference *listOfArrowKeysRef = [[self.visuallsTableRef child:key] child: @"arrows"];
    FIRDatabaseReference *listOfPathKeysRef = [[self.visuallsTableRef child:key] child: @"paths"];
    [self loadListOfNotesFromRef: listOfNoteKeysRef];
    [self loadListOfGroupsFromRef: listOfGroupKeysRef];
    [self loadListOfArrowsFromRef: listOfArrowKeysRef];
    [self loadListOfPathsFromRef: listOfPathKeysRef];
}

//if ( [self isSnapshotFromLocalDevice: snapshot] && self.allNotesLoadedBool )
//{
//    return;
//}
//else if( [self.notesCollection getNoteFromKey: snapshot.key] && self.allNotesLoadedBool )  // If the note already exists in the collection
//{
//    NoteItem2 *ni = [self.notesCollection getNoteItemFromKey: snapshot.key];
//    [ni updateNoteItem: snapshot.key andValue: snapshot.value];
//}
//else {

- (void) loadListOfNotesFromRef: (FIRDatabaseReference *) listOfNoteKeysRef
{
    self.notesCollection = [NotesCollection new];
    
    [listOfNoteKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         ++self.numberOfNotesToBeLoaded;
         [self loadNoteFromRef: [self.notesTableRef child: snapshot.key]];
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfNotesFromRef: %@", error.description);
     }];
    
    [listOfNoteKeysRef observeEventType: FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot)
     {
         NoteItem2 *ni = [self.notesCollection getNoteItemFromKey: snapshot.key];
         if (ni)
         {
             [ni removeFromSuperview];
             [self.notesCollection deleteNoteGivenKey: ni.note.key];
         }
         return;
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfGroupsFromRef: %@", error.description);
     }];
}

- (void) loadListOfGroupsFromRef: (FIRDatabaseReference *) listOfGroupKeysRef
{
    self.groupsCollection = [GroupsCollection new];
    
    [listOfGroupKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         ++self.numberOfGroupsToBeLoaded;
         [self loadGroupFromRef: [self.groupsTableRef child:snapshot.key]];  // 2. Adds a listener to READ a group
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"\n Ignore the following error if deleting a group.");
         NSLog(@"loadListOfGroupsFromRef: %@", error.description);
     }];
    
    [listOfGroupKeysRef observeEventType: FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot)  // 4. Adds a listener to DELETE a group
     {
         GroupItem *gi = [self.groupsCollection getGroupItemFromKey: snapshot.key];
         if (gi)
         {
             [gi removeFromSuperview];
             [self.groupsCollection deleteGroupGivenKey: gi.group.key];
         }
         return;
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfGroupsFromRef: %@", error.description);
     }];
}

- (void) loadListOfArrowsFromRef: (FIRDatabaseReference *) listOfArrowKeysRef
{
    self.arrowsCollection = [Collection new];
    
    [listOfArrowKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         ++self.numberOfArrowsToBeLoaded;
         [self loadArrowFromRef: [self.arrowsTableRef child: snapshot.key]];
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfArrowsFromRef: %@", error.description);
     }];
    
    [listOfArrowKeysRef observeEventType: FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot)
     {
         ArrowItem *ai = (ArrowItem *)[self.arrowsCollection getItemFromKey: snapshot.key];
         if (ai)
         {
             [ai removeFromSuperview];
             [self.arrowsCollection deleteItemGivenKey: ai.key];
         }
         return;
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfArrowsFromRef: %@", error.description);
     }];
}

- (void) loadListOfPathsFromRef: (FIRDatabaseReference *) listOfPathKeysRef
{
    self.pathsCollection = [Collection new];
    
    [listOfPathKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         ++self.numberOfPathsToBeLoaded;
         [self loadPathFromRef: [self.pathsTableRef child: snapshot.key]];
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfPathsFromRef: %@", error.description);
     }];
    
    [listOfPathKeysRef observeEventType: FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        PathItem *pi = (PathItem *) [self.pathsCollection getItemFromKey: snapshot.key];
        if (pi)
        {
//            [self.DrawView deletePath: pi]; // TODO (Apr 16, 2017): Investigate further - causing errors. Simple remove from model below.
            [pi removeFromSuperlayer];
            [self.pathsCollection deleteItemGivenKey: pi.key];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"loadListOfPathsFromRef: %@", error.description);
    }];
}

- (void) __loadListOfArrowsFromRef: (FIRDatabaseReference *) listOfArrowKeysRef
{
    self.arrowsCollection = [Collection new];
    
    //    [listOfArrowKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
    [listOfArrowKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [self.arrowsCollection getItemFromKey: listOfArrowKeysRef.key] )  // If the group already exists in the collection
         {
             return;
         }
         ++self.numberOfArrowsToBeLoaded;
         [self loadArrowFromRef: [self.arrowsTableRef child:snapshot.key]];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"\n Ignore the following error if deleting an arrow.");
         NSLog(@"loadListOfArrowsFromRef: %@", error.description);
     }];
}

//if ( [self isSnapshotFromLocalDevice: snapshot] && __allGroupsLoaded)
//{
//    return;
//}
//else if (snapshot.value == (id)[NSNull null])
//{
//    GroupItem *gi = [self.groupsCollection getGroupItemFromKey: snapshot.key];
//    if (gi)
//    {
//        [gi removeFromSuperview];
//        [self.groupsCollection deleteGroupGivenKey: gi.group.key];
//    }
//    return;
//}
//else if( [self.groupsCollection getGroupItemFromKey: snapshot.key] && __allGroupsLoaded)  // If the group already exists in the collection
//{
//    GroupItem *gi = [self.groupsCollection getGroupItemFromKey: snapshot.key];
//    [gi updateGroupItem: snapshot.key andValue: snapshot.value];
//    return;
//}



/*
 * Name: setValueNote
 * Description: Firebase setter for a brand new note. Updates should NOT use this method.
 */
- (void) setValueNote: (NoteItem2 *) ni
{
    if ( !_currentVisuallKey) {
        return;  // TODO (Aug 16, 2016): Unable to save a note bc user didn't log-in 2/2 no internet connection - possible to load data from local disk?
    }
    NSMutableDictionary *noteDictionary = [@{
                                             @"data/title": ni.note.title,
                                             @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
                                             @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
//                                             @"font-size": [NSString stringWithFormat:@"%.1f", ni.note.fontSize],
                                             @"data/fontSize": [ni.note valueForKey: @"fontSize"],
                                             } mutableCopy];
    [noteDictionary addEntriesFromDictionary: [self getGenericSetValueParameters]];
    [noteDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    FIRDatabaseReference *newNoteRef = [self.notesTableRef childByAutoId];
    ni.note.key = newNoteRef.key;
    [self.notesCollection addNote:ni withKey:newNoteRef.key];
    NSLog(@"\n setValueNote, loadNoteFromRef: %@", newNoteRef.key);
    [newNoteRef setValue: @{@"parent-visuall": _currentVisuallKey}];  // HACK to allow for offline, local storage and avoid permission errors
    [newNoteRef updateChildValues: noteDictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Note could NOT be saved.");
        } else {
            NSLog(@"Note saved successfully.");
        }
    }];
    
    [[self.visuallsTable_currentVisuallRef child: @"notes"] updateChildValues:@{newNoteRef.key: @"1"} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Note REF could NOT be saved.");
        } else {
            NSLog(@"Note REF saved successfully.");
            FIRDatabaseReference *notesCounterRef = [self.visuallsTable_currentVisuallRef child: @"notes_counter"];
            [self increaseOrDecreaseCounter: notesCounterRef byAmount:1];
        }
    }];
}

- (void) increaseOrDecreaseCounter: (FIRDatabaseReference *) ref byAmount: (int) i
{
    [ref runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        NSNumber *value = currentData.value;
        if (currentData.value == [NSNull null]) {
            value = 0;
        }
        [currentData setValue:[NSNumber numberWithInt:(i + [value intValue])]];
        return [FIRTransactionResult successWithValue: currentData];
    }];
}

- (void) setValueGroup: (VisualItem *) vi
{
    GroupItem *gi = (GroupItem *) vi;
    FIRDatabaseReference *groupsRef = [self.version01TableRef child: @"groups"];
    FIRDatabaseReference *newGroupRef = [groupsRef childByAutoId];
    gi.group.key = newGroupRef.key;
    [self.groupsCollection addGroup: gi withKey: newGroupRef.key];
    NSLog(@"\n setValueGroup: %@", newGroupRef.key);
    NSLog(@"\n setValueGroup, count: %lu", (unsigned long) self.groupsCollection.items.count);
    if ( !_currentVisuallKey )
    {
        return;
    }
    NSMutableDictionary *groupDictionary = [@{
                                              @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                              @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                              @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                              @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height],
                                              @"data/image": ([vi isImage]) ? @"1" : @"0"
                                              } mutableCopy];
    [groupDictionary addEntriesFromDictionary: [self getGenericSetValueParameters]];
    [groupDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    
    if ( [vi isImage] )
    {
        [self setValueGroupImageHelperForVisualItem:vi andGroupDictionary: groupDictionary andRef: newGroupRef];
    }
    else
    {
        [self setValueGroupHelper: groupDictionary andRef: newGroupRef];
    }
    
}

- (void) setValueGroupImageHelperForVisualItem: (VisualItem *) vi andGroupDictionary: (NSMutableDictionary *) groupDictionary andRef: (FIRDatabaseReference *) newGroupRef
{
    [[self.visuallsTable_currentVisuallRef child: @"images"] updateChildValues: @{newGroupRef.key: @"1"}];
    FIRStorageUploadTask *uploadTask = [self uploadImage: [vi getGroupItemImage]];
    [uploadTask observeStatus: FIRStorageTaskStatusSuccess
                      handler:^(FIRStorageTaskSnapshot *snapshot) {
                          NSLog(@"\n setValueGroup upload complete");
                          [self setValueGroupHelper: groupDictionary andRef: newGroupRef];
                      }];
}

- (void) setValueGroupHelper: (NSMutableDictionary *) groupDictionary andRef: (FIRDatabaseReference *) newGroupRef
{
    // Use setValue prior to updateChildValues for compatibility with local persistent storage:
    [newGroupRef setValue: @{@"parent-visuall": _currentVisuallKey} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error)
        {
            NSLog(@"\n setValueGroup, error: %@", error);
        }
        else{
            NSLog(@"\n Group set successfully.");
        }
    }];
    [newGroupRef updateChildValues: groupDictionary];
    [[self.visuallsTable_currentVisuallRef child: @"groups"] updateChildValues: @{newGroupRef.key: @"1"}];
}

- (void) setValueArrow: (VisualItem *) vi
{
    ArrowItem *ai = (ArrowItem *) vi;
    FIRDatabaseReference *arrowsRef = [self.version01TableRef child: @"arrows"];
    FIRDatabaseReference *newArrowRef = [arrowsRef childByAutoId];
    ai.key = newArrowRef.key;
    [self.arrowsCollection addItem: ai withKey: ai.key];
    NSLog(@"\n setValueArrow: %@", ai.key);
    NSLog(@"\n setValueArrow, count: %lu", (unsigned long) self.arrowsCollection.items.count);

    if ( !_currentVisuallKey )
    {
        return;
    }
    NSMutableDictionary *arrowDictionary = [@{
                                              @"data/startX": [NSString stringWithFormat:@"%.1f", ai.startPoint.x],
                                              @"data/startY": [NSString stringWithFormat:@"%.1f", ai.startPoint.y],
                                              @"data/endX": [NSString stringWithFormat:@"%.1f", ai.endPoint.x],
                                              @"data/endY": [NSString stringWithFormat:@"%.1f", ai.endPoint.y],
                                              @"data/startItemKey": (ai.startItem && ai.startItem.key) ? ai.startItem.key : @"0",
                                              @"data/endItemKey": (ai.endItem && ai.endItem.key) ? ai.endItem.key : @"0",
                                              @"data/tailWidth": [NSString stringWithFormat:@"%.0f", ai.tailWidth],
                                              @"data/headWidth": [NSString stringWithFormat:@"%.0f", ai.headWidth],
                                              @"data/headLength": [NSString stringWithFormat:@"%.0f", ai.headLength],
                                              } mutableCopy];
    [arrowDictionary addEntriesFromDictionary: [self getGenericSetValueParameters]];
    [arrowDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    [newArrowRef setValue: @{@"parent-visuall": _currentVisuallKey}];  // HACK to allow for offline, local storage and avoid permission errors
    [newArrowRef updateChildValues: arrowDictionary];
    [[self.visuallsTable_currentVisuallRef child: @"arrows"] updateChildValues: @{newArrowRef.key: @"1"}];
    FIRDatabaseReference *arrowsCounterRef = [self.visuallsTable_currentVisuallRef child: @"arrows_counter"];
    [self increaseOrDecreaseCounter: arrowsCounterRef byAmount:1];
}

- (void) setValuePath:(PathItem *) pi
{
    FIRDatabaseReference *pathsRef = [self.version01TableRef child: @"paths"];
    FIRDatabaseReference *newPathRef = [pathsRef childByAutoId];
    pi.key = newPathRef.key;
    [self.pathsCollection addItem: pi withKey: pi.key];
    NSLog(@"\n setValuePath: %@", pi.key);
    NSLog(@"\n setValuePath, count: %lu", (unsigned long) self.pathsCollection.items.count);
    if ( !_currentVisuallKey )
    {
        return;
    }
    NSMutableDictionary *pathDictionary = [@{
                                             @"data/path": [pi.fdpath serialize]
                                             } mutableCopy];
    [pathDictionary addEntriesFromDictionary: [self getGenericSetValueParameters]];
    [pathDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    [newPathRef setValue: @{@"parent-visuall": _currentVisuallKey}];  // HACK to allow for offline, local storage and avoid permission errors
    [newPathRef updateChildValues: pathDictionary];
    [[self.visuallsTable_currentVisuallRef child: @"paths"] updateChildValues: @{newPathRef.key: @"1"}];
}

- (void) updateValuePath: (PathItem *) pi
{
    FIRDatabaseReference *pathDathRef = [[self.version01TableRef child: @"paths"] child: pi.key];
    NSMutableDictionary *pathDictionary = [@{
                                             @"data/path": [pi.fdpath serialize]
                                             } mutableCopy];
    [pathDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    [pathDathRef updateChildValues: pathDictionary];
}

/*
 * Name:
 * Description:
 // TODO (Aug 23, 2016): "You can also put this code inside a GCD block and execute in another thread, showing an UIActivityIndicatorView during the process[...]"
 */

- (FIRStorageUploadTask *) uploadImage: (GroupItemImage *) gii
{
    FIRStorageReference *riversRef = [self.storageImagesRef child: [gii.group.key stringByAppendingString:@".jpg"]];
    NSData *data = UIImageJPEGRepresentation(gii.thumbnail, 1.0);
    FIRStorageUploadTask *uploadTask = [riversRef putData:data metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            NSLog(@"\n Uh-oh, an error occurred!");
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            NSURL *downloadURL = metadata.downloadURL;
        }
    }];
    return uploadTask;
}

- (NSMutableDictionary  *) getGenericSetValueParameters
{
    return [@{
              
              @"parent-visuall": _currentVisuallKey,
              @"data/date-created": [FIRServerValue timestamp],
              @"data/created-by-username": [FIRAuth auth].currentUser.displayName,
              @"data/created-by-uid": [FIRAuth auth].currentUser.uid,
              } mutableCopy];
}

- (NSMutableDictionary *) getCommonUpdateParameters
{
    return [@{
//              @"parent-visuall": _currentVisuallKey,
              @"data/selected-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
              @"data/selected-by-uid": [FIRAuth auth].currentUser.uid,
              @"data/date-last-modified": [FIRServerValue timestamp],
              @"data/local-device-id": __localDeviceId
              } mutableCopy];
}

- (void) updateChildValue: (UIView *) visualObject Property: (NSString *) propertyName
{
    if ( !_currentVisuallKey ) return;
    if ( [visualObject isNoteItem] )
    {
        NoteItem2 *ni = [visualObject getNoteItem];
        if( [ni.note.key isMatch:RX(@"[\\.\\#\\$\\[\\]]")] )
        {
            return;
        }
        
        FIRDatabaseReference *notesDataRef = [[self.version01TableRef child: @"notes"] child: ni.note.key];
        //        NSString *localKey = [@"" stringByAppendingString: propertyName];
        //        NSMutableDictionary *noteDict = [@{
        //                                           localKey : [ni.note valueForKey:propertyName]
        //                                           } mutableCopy];
        NSMutableDictionary *noteDict = [@{
                                           @"data/title": ni.note.title,
                                           @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
                                           @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
                                           @"data/fontSize": [ni.note valueForKey: @"fontSize"]
                                           } mutableCopy];
        [noteDict addEntriesFromDictionary: [self getCommonUpdateParameters]];
        [notesDataRef updateChildValues:noteDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            //            [__pendingChildIds addObject: ni.note.key];
        }];
    }
    else if ( [visualObject isGroupItem] )
    {
        if ( [propertyName isEqualToString:@"frame"] )
        {
            GroupItem *gi = [visualObject getGroupItem];
            FIRDatabaseReference *groupDataRef = [[self.version01TableRef child: @"groups"] child: gi.group.key];
            NSMutableDictionary *groupDictionary = [@{
                                                      @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                                      @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                                      @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                                      @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height],
                                                      } mutableCopy];
            [groupDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
            NSLog(@"\n Preparing to update group child values.");
            [groupDataRef updateChildValues: groupDictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
             {
                 if (error) {
                     NSLog(@"Group could not be updated.");
                 } else {
                     NSLog(@"Group updated successfully: %@", ref.key);
                 }
             }];
        }
    }
    else if ( [visualObject isArrowItem] )
    {
        ArrowItem *ai = [visualObject getArrowItem];
        FIRDatabaseReference *arrowDataRef = [[self.version01TableRef child: @"arrows"] child: ai.key];
        NSMutableDictionary *arrowDictionary = [@{
                                                  @"data/startX": [NSString stringWithFormat:@"%.1f", ai.startPoint.x],
                                                  @"data/startY": [NSString stringWithFormat:@"%.1f", ai.startPoint.y],
                                                  @"data/endX": [NSString stringWithFormat:@"%.1f", ai.endPoint.x],
                                                  @"data/endY": [NSString stringWithFormat:@"%.1f", ai.endPoint.y],
                                                  @"data/startItemKey": (ai.startItem && ai.startItem.key) ? ai.startItem.key : @"0",
                                                  @"data/endItemKey": (ai.endItem && ai.endItem.key) ? ai.endItem.key : @"0",
                                                  @"data/tailWidth": [NSString stringWithFormat:@"%.0f", ai.tailWidth],
                                                  @"data/headWidth": [NSString stringWithFormat:@"%.0f", ai.headWidth],
                                                  @"data/headLength": [NSString stringWithFormat:@"%.0f", ai.headLength],
                                                  } mutableCopy];
        [arrowDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
        [arrowDataRef updateChildValues: arrowDictionary];
    }
}

- (void) updateChildValues: (UIView *) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2
{
    
    if ( [visualObject isNoteItem] )
    {
        NoteItem2 *ni = [visualObject getNoteItem];
        FIRDatabaseReference *notesDataRef = [[self.version01TableRef child: @"notes"] child: ni.note.key];
        [notesDataRef updateChildValues: @{
                                           propertyName1 : [ni.note valueForKey:propertyName1],
                                           propertyName2 : [ni.note valueForKey:propertyName2],
                                           }];
    }
    else if ( [visualObject isGroupItem] )
    {
        GroupItem *gi = (GroupItem *) visualObject;
        NSString *groupUrl = [@"groups/" stringByAppendingString: gi.group.key];
        [self.version01TableRef updateChildValues: @{
                                                     [groupUrl stringByAppendingString:propertyName1] : [gi.group valueForKey:propertyName1],
                                                     [groupUrl stringByAppendingString:propertyName2] : [gi.group valueForKey:propertyName2],
                                                     }];
    }
    else if ( [visualObject isArrowItem] )
    {
        ArrowItem *ai = [visualObject getArrowItem];
        FIRDatabaseReference *arrowsDataRef = [[self.version01TableRef child: @"arrows"] child: ai.key];
        if ([propertyName1 isEqualToString:@"x"] && [propertyName2 isEqualToString:@"y"])
        {
            [arrowsDataRef updateChildValues: @{
                                                @"startX": [NSString stringWithFormat:@"%.1f", ai.startPoint.x],
                                                @"startY": [NSString stringWithFormat:@"%.1f", ai.startPoint.y],
                                                @"endX": [NSString stringWithFormat:@"%.1f", ai.endPoint.x],
                                                @"endY": [NSString stringWithFormat:@"%.1f", ai.endPoint.y],
                                                }];
        } else
        {
            [arrowsDataRef updateChildValues: @{
                                                propertyName1 : [ai valueForKey:propertyName1],
                                                propertyName2 : [ai valueForKey:propertyName2],
                                                }];
        }
    }
}

- (void) removeNoteKeyFromParentVisuall: (NSString *) key
{
    FIRDatabaseReference *deleteNoteKeyFromVisuallRef = [[self.visuallsTable_currentVisuallRef child: @"notes"] child: key];
    [deleteNoteKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error) {
            NSLog(@"Note key could not be removed.");
        } else {
            NSLog(@"Note key removed successfully.");
        }
    }];
    
    FIRDatabaseReference *notesCounterRef = [self.visuallsTable_currentVisuallRef child: @"notes_counter"];
    [self increaseOrDecreaseCounter: notesCounterRef byAmount:-1];
    
}

- (BOOL) isSnapshotFromLocalDevice: (FIRDataSnapshot*) snapshot
{
    if ( snapshot.value
        && snapshot.value != (id)[NSNull null]
        && snapshot.value[@"data"]
        && snapshot.value[@"data"][@"local-device-id"] )
    {
        NSString *foreignDeviceId = snapshot.value[@"data"][@"local-device-id"];
        if ( [__localDeviceId isEqualToString: foreignDeviceId] )
        {
            return YES;
        }
    }
    return NO;
}

/*
 
 - (void) loadFirebaseTransform
 {
 Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/transform"];
 [Firebase goOffline];
 if (ref)
 {
 [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
 {
 
 //             float zoom = [snapshot.value[@"zoom"] floatValue];
 //             float tx = [snapshot.value[@"tx"] floatValue];
 //             float ty = [snapshot.value[@"ty"] floatValue];
 
 float zoom = 1.0f;
 float tx = 0.0f;
 float ty = 0.0f;
 
 [[TransformUtil sharedManager] setZoom:zoom];
 [[TransformUtil sharedManager] setPan:(CGPointMake(tx, ty))];
 
 self.BackgroundScrollView.zoomScale = zoom;
 self.BackgroundScrollView.contentOffset = CGPointMake(tx, ty);
 
 [self loadFirebaseNotes];
 [self loadFirebaseGroups];
 } withCancelBlock:^(NSError *error)
 {
 NSLog(@"%@", error.description);
 }];
 }
 }
 
 - (void) setTransformFirebase
 {
 Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
 Firebase *transformRef = [ref childByAppendingPath: @"transform"];
 NSDictionary *transformDictionary = @{
 @"zoom": [NSString stringWithFormat:@"%.3f", [[TransformUtil sharedManager] zoom]],
 @"tx": [NSString stringWithFormat:@"%.3f", [[TransformUtil sharedManager] pan].x],
 @"ty": [NSString stringWithFormat:@"%.3f", [[TransformUtil sharedManager] pan].y]
 };
 [transformRef updateChildValues: transformDictionary];
 }
 
 - (void) removeValue: (id) object
 {
 Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
 if([object isKindOfClass: [NoteItem2 class]]) {
 NoteItem2 *ni = (NoteItem2 *) object;
 Firebase *noteRef = [ref childByAppendingPath: [@"notes2/" stringByAppendingString:ni.note.key]];
 [noteRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
 if (error) {
 NSLog(@"Data could not be removed.");
 } else {
 NSLog(@"Data removed successfully.");
 }
 }];
 
 } else if([object isKindOfClass: [GroupItem class]]) {
 GroupItem *gi = (GroupItem *) object;
 Firebase *groupRef = [ref childByAppendingPath: [@"groups2/" stringByAppendingString:gi.group.key]];
 [groupRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
 if (error) {
 NSLog(@"Group could not be removed.");
 } else {
 NSLog(@"Group removed successfully.");
 }
 }];
 }
 }
 
 
 */

@end

