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

@interface StateUtilFirebase()

@property FIRDatabaseReference *version01TableRef;

@end


@implementation StateUtilFirebase
{
    FIRStorage *__storage;
    FIRStorageReference *__storageImagesRef;
    NSString *__userID;
    FIRDatabaseReference *_usersTableCurrentUser;
    NSString *_currentVisuallKey;
    FIRDatabaseReference *_visuallsTableRef;
    FIRDatabaseReference *_visuallsTable_currentVisuallRef;
    FIRDatabaseReference *_notesTableRef;
    FIRDatabaseReference *_groupsTableRef;
    FIRDatabaseReference *__arrowsTableRef;
    FIRDatabaseReference *__publicVisuallsTableRef;
    void (^_callbackNoteItem)(NoteItem2 *ni);
    void (^_callbackGroupItem)(GroupItem *gi);
    void (^_callbackPublicVisuallLoaded)(void);
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
    
//    [FIRDatabaseReference goOffline];  // TODO (Sep 1, 2016): TEMP
    
    if ( __userID )
    {
        _usersTableCurrentUser = [[self.version01TableRef child:@"users"] child: __userID];
    }
    _visuallsTableRef = [self.version01TableRef child: @"visualls"];
    _notesTableRef = [self.version01TableRef child: @"notes"];
    _groupsTableRef = [self.version01TableRef child: @"groups"];
    __arrowsTableRef = [self.version01TableRef child: @"arrows"];
    __publicVisuallsTableRef = [self.version01TableRef child: @"public"];
    __storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [__storage referenceForURL:@"gs://visuall-2f878.appspot.com"];
    __storageImagesRef = [storageRef child:@"images"];
    

    
}

- (void) loadVisuallsListForCurrentUser
{
    [_usersTableCurrentUser observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ( ![snapshot exists] )  // we have a new user
         {
             [self setNewUser];
         } else {
             NSLog(@"%@", snapshot.value );
             [[[self.version01TableRef child:@"users"] child: __userID] updateChildValues:@{@"date_last_visit": [FIRServerValue timestamp]}];
         }
         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
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
    
    FIRDatabaseReference *visuallsPersonalRef =  [_usersTableCurrentUser child: @"visualls/personal"];
    
    [visuallsPersonalRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ( ![snapshot exists] ) //create first Visuall for current user
         {
             NSDictionary *visuallDictionary = @{
                                                 @"title": @"My First Visuall",
                                                 @"date-created": [FIRServerValue timestamp],
                                                 @"created-by": [FIRAuth auth].currentUser.uid,
                                                 @"write-permission" : @{ [FIRAuth auth].currentUser.uid : @"1" }
                                                 };
             _visuallsTable_currentVisuallRef = [_visuallsTableRef childByAutoId];
             _currentVisuallKey = _visuallsTable_currentVisuallRef.key;
             [_visuallsTable_currentVisuallRef updateChildValues: visuallDictionary];
             [visuallsPersonalRef updateChildValues: @{_visuallsTable_currentVisuallRef.key: @"1"} ];
             
         } else
         {  // run thru list of Visualls
             NSDictionary *visuallPersonalKeys = (NSDictionary *) snapshot.value;
             for (NSString *key in visuallPersonalKeys) {
                 _currentVisuallKey = key;
                 _visuallsTable_currentVisuallRef = [_visuallsTableRef child: key];
                 [self loadVisuallFromKey: key];
                 return; // TODO: early termination here only loading the 1st and only visuall
             }
         }
     }];
}

- (void) loadPublicVisuallsList
{
    
    [__publicVisuallsTableRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
         if ( ![snapshot exists] )  // we need to create first public visual
         {
             NSDictionary *visuallDictionary = @{
                                                 @"title": @"My First Global Visuall",
                                                 @"date-created": [FIRServerValue timestamp],
                                                 @"created-by-userID": [FIRAuth auth].currentUser.uid,
                                                 @"admin" : @{ [FIRAuth auth].currentUser.uid : @"1" },
                                                 @"public": @"1"
                                                 };
             _visuallsTable_currentVisuallRef = [_visuallsTableRef childByAutoId];
             _currentVisuallKey = _visuallsTable_currentVisuallRef.key;
             [_visuallsTable_currentVisuallRef updateChildValues: visuallDictionary];
             [__publicVisuallsTableRef updateChildValues: @{_visuallsTable_currentVisuallRef.key: @"1"}];
         }
         else {
             NSLog(@"loadPublicVisuallsList: no snapshot");
         }
//         {  // run thru list of Visualls
             NSDictionary *visuallKeys = (NSDictionary *) snapshot.value;
             for (NSString *key in visuallKeys) {
                 _currentVisuallKey = key;
                 _visuallsTable_currentVisuallRef = [_visuallsTableRef child: key];
                 [self loadVisuallFromKey: key];
                 _callbackPublicVisuallLoaded();
                 return; // TODO: early termination here only loading the 1st and only visuall
             }
//         }
        
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

- (void) setCallbackNoteItem: (void (^)(NoteItem2 *ni)) callbackNoteItem
{
    _callbackNoteItem = [callbackNoteItem copy];
};

- (void) setCallbackGroupItem: (void (^)(GroupItem *gi)) callbackGroupItem
{
    _callbackGroupItem = [callbackGroupItem copy];
};

- (void) setCallbackPublicVisuallLoaded:(void (^)(void)) callback
{
    _callbackPublicVisuallLoaded = [callback copy];
};

- (void) loadVisuallFromKey: (NSString *) key
{
    FIRDatabaseReference *listOfNoteKeysRef = [[_visuallsTableRef child:key] child: @"notes"];
    FIRDatabaseReference *listOfGroupKeysRef = [[_visuallsTableRef child:key] child: @"groups"];
    FIRDatabaseReference *listOfArrowKeysRef = [[_visuallsTableRef child:key] child: @"arrows"];
    [self loadListOfNotesFromRef: listOfNoteKeysRef];
    [self loadListOfGroupsFromRef: listOfGroupKeysRef];
    [self loadListOfArrowsFromRef: listOfArrowKeysRef];
}

- (void) loadListOfNotesFromRef: (FIRDatabaseReference *) listOfNoteKeysRef
{
    self.notesCollection = [NotesCollection new];
    [listOfNoteKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         NSString *key = snapshot.key;
         
         if([self.notesCollection getNoteFromKey: key])  // If the note already exists in the collection
         {
             return;
         }
         self.childrenCountNotes = snapshot.childrenCount;
         [self loadNoteFromRef: [_notesTableRef child:key]];
//         [self removeNoteGivenKey: key];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadListOfNotesFromRef: %@", error.description);
     }];
}

- (void) loadListOfGroupsFromRef: (FIRDatabaseReference *) listOfGroupKeysRef
{
    self.groupsCollection = [GroupsCollection new];
    
    [listOfGroupKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [self.groupsCollection getGroupItemFromKey: listOfGroupKeysRef.key] )  // If the group already exists in the collection
         {
             return;
         }
         
         [self loadGroupFromRef: [_groupsTableRef child:snapshot.key]];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"\n Ignore the following error if deleting a group.");
         NSLog(@"loadListOfGroupsFromRef: %@", error.description);
     }];
}

- (void) loadListOfArrowsFromRef: (FIRDatabaseReference *) listOfArrowKeysRef
{
    self.arrowsCollection = [Collection new];
    
    [listOfArrowKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [self.arrowsCollection getItemFromKey: listOfArrowKeysRef.key] )  // If the group already exists in the collection
         {
             return;
         }
         
         [self loadArrowFromRef: [__arrowsTableRef child:snapshot.key]];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"\n Ignore the following error if deleting an arrow.");
         NSLog(@"loadListOfArrowsFromRef: %@", error.description);
     }];
}

-(void) loadNoteFromRef: (FIRDatabaseReference *) noteRef
{
    [noteRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         
         if([self.notesCollection getNoteFromKey: snapshot.key])  // If the note already exists in the collection
         {
             return;
         }
         
         NoteItem2 *newNote = [[NoteItem2 alloc] initNoteFromFirebase: noteRef.key andValue:snapshot.value];
         [self.notesCollection addNote:newNote withKey:snapshot.key];
         _callbackNoteItem(newNote);
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadNoteFromRef %@", error.description);
     }];
}

-(void) loadGroupFromRef: (FIRDatabaseReference *) groupRef
{
    [groupRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [self.groupsCollection getGroupItemFromKey: snapshot.key] )  // If the group already exists in the collection
         {
             return;
         }

        if( [snapshot.value[@"data"][@"image"] boolValue] )
        {
            GroupItemImage *newGroup = [[GroupItemImage alloc] initGroup:snapshot.key andValue:snapshot.value];
            [self.groupsCollection addGroup: newGroup withKey:snapshot.key];
            _callbackGroupItem(newGroup);
            NSString *fileName = [snapshot.key stringByAppendingString: @".jpg"];
            FIRStorageReference *islandRef = [__storageImagesRef child: fileName];
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
            _callbackGroupItem(newGroup);
        }
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadGroupFromRef: %@", error.description);
     }];
}

/*
 * Name:
 * Description:
 */
-(void) loadArrowFromRef: (FIRDatabaseReference *) arrowRef
{
    [arrowRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         
         if([self.arrowsCollection getItemFromKey: snapshot.key])  // If the note already exists in the collection
         {
             return;
         }
         
         ArrowItem *ai = [[ArrowItem alloc] initArrowFromFirebase: arrowRef.key andValue:snapshot.value];
         [self.arrowsCollection addItem: ai withKey: arrowRef.key];
//         _callbackNoteItem(newNote);
         [self.ArrowsView addSubview: ai];
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"loadArrowFromRef %@", error.description);
     }];
}

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
//                                             @"data/font-size": [NSString stringWithFormat:@"%.1f", ni.note.fontSize],
                                             @"data/fontSize": [ni.note valueForKey: @"fontSize"],
                                             @"metadata/parent-visuall": _currentVisuallKey,
                                             @"metadata/date-created": [FIRServerValue timestamp],
                                             @"metadata/created-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
                                             @"metadata/created-by-uid": [FIRAuth auth].currentUser.uid,
                                             @"parent-visuall": _currentVisuallKey,
                                             } mutableCopy];
    [noteDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    FIRDatabaseReference *newNoteRef = [_notesTableRef childByAutoId];
    //    NSLog(@"setValueNote, new note key: %@", newNoteRef.key);
    //    NSLog(@"setValueNote, parent-visuall: %@", _currentVisuallKey);
    ni.note.key = newNoteRef.key;
    [self.notesCollection addNote:ni withKey:newNoteRef.key];
    [newNoteRef updateChildValues: noteDictionary];
//    [[_visuallsTable_currentVisuallRef child: @"notes"] updateChildValues: @{newNoteRef.key: @"1"}];
    [[_visuallsTable_currentVisuallRef child: @"notes"] updateChildValues:@{newNoteRef.key: @"1"} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Note could NOT be saved.");
        } else {
            NSLog(@"Note saved successfully.");
        }
    }];
    FIRDatabaseReference *notesCounterRef = [_visuallsTable_currentVisuallRef child: @"notes_counter"];
    [self increaseOrDecreaseCounter: notesCounterRef byAmount:1];
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
    if ( !_currentVisuallKey )
    {
        return;
    }
    NSMutableDictionary *groupDictionary = [@{
                                              @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                              @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                              @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                              @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height],
                                              @"data/image": ([vi isImage]) ? @"1" : @"0",
                                              @"metadata/parent-visuall": _currentVisuallKey,
                                              @"metadata/date-created": [FIRServerValue timestamp],
                                              @"metadata/created-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
                                              @"metadata/created-by-uid": [FIRAuth auth].currentUser.uid,
                                              } mutableCopy];
    [groupDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    [self.groupsCollection addGroup: gi withKey: newGroupRef.key]; // TODO (Aug 23, 2016): Redundant?
    [newGroupRef updateChildValues: groupDictionary];
    [[_visuallsTable_currentVisuallRef child: @"groups"] updateChildValues: @{newGroupRef.key: @"1"}];
    if ( [vi isImage] )
    {
        [[_visuallsTable_currentVisuallRef child: @"images"] updateChildValues: @{newGroupRef.key: @"1"}];
        [self uploadImage: [vi getGroupItemImage]];

    }
    FIRDatabaseReference *groupsCounterRef = [_visuallsTable_currentVisuallRef child: @"groups_counter"];
    [self increaseOrDecreaseCounter: groupsCounterRef byAmount:1];
}

- (void) setValueArrow: (VisualItem *) vi
{
    ArrowItem *ai = (ArrowItem *) vi;
    FIRDatabaseReference *arrowsRef = [self.version01TableRef child: @"arrows"];
    FIRDatabaseReference *newArrowRef = [arrowsRef childByAutoId];
    ai.key = newArrowRef.key;
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
    [newArrowRef updateChildValues: arrowDictionary];
    [[_visuallsTable_currentVisuallRef child: @"arrows"] updateChildValues: @{newArrowRef.key: @"1"}];
    FIRDatabaseReference *arrowsCounterRef = [_visuallsTable_currentVisuallRef child: @"arrows_counter"];
    [self increaseOrDecreaseCounter: arrowsCounterRef byAmount:1];
}

/*
 * Name:
 * Description:
 // TODO (Aug 23, 2016): "You can also put this code inside a GCD block and execute in another thread, showing an UIActivityIndicatorView during the process[...]"
 */

- (void) uploadImage: (GroupItemImage *) gii
{
    FIRStorageReference *riversRef = [__storageImagesRef child: [gii.group.key stringByAppendingString:@".jpg"]];
    NSData *data = UIImageJPEGRepresentation(gii.thumbnail, 1.0);
    FIRStorageUploadTask *uploadTask = [riversRef putData:data metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            NSLog(@"\n Uh-oh, an error occurred!");
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            NSURL *downloadURL = metadata.downloadURL;
        }
    }];
    
}

- (NSMutableDictionary  *) getGenericSetValueParameters
    {
        return [@{

                  @"metadata/parent-visuall": _currentVisuallKey,
                  @"metadata/date-created": [FIRServerValue timestamp],
                  @"metadata/created-by-username": [FIRAuth auth].currentUser.displayName,
                  @"metadata/created-by-uid": [FIRAuth auth].currentUser.uid,
                  } mutableCopy];
    }
     
- (NSMutableDictionary *) getCommonUpdateParameters
{
    return [@{
              @"data/selected-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
              @"data/selected-by-uid": [FIRAuth auth].currentUser.uid,
              @"metadata/date-last-modified": [FIRServerValue timestamp],
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
        NSString *localKey = [@"data/" stringByAppendingString: propertyName];
        NSMutableDictionary *noteDict = [@{
                                           localKey : [ni.note valueForKey:propertyName]
                                           } mutableCopy];
        [noteDict addEntriesFromDictionary: [self getCommonUpdateParameters]];
        [notesDataRef updateChildValues: noteDict];
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
            [groupDataRef updateChildValues: groupDictionary];
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
        FIRDatabaseReference *notesDataRef = [[self.version01TableRef child: @"notes"] child: [ni.note.key stringByAppendingString:@"/data"]];
        [notesDataRef updateChildValues: @{
                                           propertyName1 : [ni.note valueForKey:propertyName1],
                                           propertyName2 : [ni.note valueForKey:propertyName2],
                                           }];
    }
    else if ( [visualObject isGroupItem] )
    {
        GroupItem *gi = (GroupItem *) visualObject;
        NSString *groupUrl = [[@"groups/" stringByAppendingString: gi.group.key] stringByAppendingString:@"/data/"];
        [self.version01TableRef updateChildValues: @{
                                                     [groupUrl stringByAppendingString:propertyName1] : [gi.group valueForKey:propertyName1],
                                                     [groupUrl stringByAppendingString:propertyName2] : [gi.group valueForKey:propertyName2],
                                                     }];
    }
    else if ( [visualObject isArrowItem] )
    {
        ArrowItem *ai = [visualObject getArrowItem];
        FIRDatabaseReference *arrowsDataRef = [[self.version01TableRef child: @"arrows"] child: [ai.key stringByAppendingString:@"/data"]];
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
        FIRDatabaseReference *deleteNoteRef = [_notesTableRef child: ni.note.key];
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
        FIRDatabaseReference *deleteNoteKeyFromVisuallRef = [[_visuallsTable_currentVisuallRef child: @"notes"] child: ni.note.key];
        [deleteNoteKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Note key could not be removed.");
            } else {
                NSLog(@"Note key removed successfully.");
            }
        }];
        
        // Step 3 of 3: Decrement notes counter in visuall table
        FIRDatabaseReference *notesCounterRef = [_visuallsTable_currentVisuallRef child: @"notes_counter"];
        [self increaseOrDecreaseCounter: notesCounterRef byAmount:-1];
        
    }
    else if([view isGroupItem])
    {
        // Step 1 of 3: Delete group from groups table
        GroupItem *gi = [view getGroupItem];
        FIRDatabaseReference *deleteGroupRef = [_groupsTableRef child: gi.group.key];
        [deleteGroupRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group could not be removed.");
            } else {
                NSLog(@"Group removed successfully.");
                [gi removeFromSuperview];
            }
        }];
        
        // Step 2 of 3: Delete group key from current visuall table
        FIRDatabaseReference *deleteGroupKeyFromVisuallRef = [[_visuallsTable_currentVisuallRef child: @"groups"] child: gi.group.key];
        [deleteGroupKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group key could not be removed.");
            } else {
                NSLog(@"Group key removed successfully.");
            }
        }];
        
        // Step 3 of 3: Decrement groups counter in visuall table
        FIRDatabaseReference *groupsCounterRef = [_visuallsTable_currentVisuallRef child: @"groups_counter"];
        [self increaseOrDecreaseCounter: groupsCounterRef byAmount:-1];
        
        // Step 4: Delete an image if group contains an image)
        if ( [gi isImage] )
        {
            NSString *fileName = [gi.group.key stringByAppendingString: @".jpg"];
            FIRStorageReference *deleteImageRef = [__storageImagesRef child: fileName];
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
        FIRDatabaseReference *deleteItemRef = [__arrowsTableRef child: ai.key];
        [deleteItemRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group could not be removed.");
            } else {
                NSLog(@"Group removed successfully.");
                [ai removeFromSuperview];
            }
        }];
        
        // Step 2 of 3: Delete group key from current visuall table
        FIRDatabaseReference *deleteItemKeyFromVisuallRef = [[_visuallsTable_currentVisuallRef child: @"arrows"] child: ai.key];
        [deleteItemKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group key could not be removed.");
            } else {
                NSLog(@"Group key removed successfully.");
            }
        }];
        
        // Step 3 of 3: Decrement groups counter in visuall table
        FIRDatabaseReference *itemsCounterRef = [_visuallsTable_currentVisuallRef child: @"arrows_counter"];
        [self increaseOrDecreaseCounter: itemsCounterRef byAmount:-1];
    }
    
}

- (void) removeNoteGivenKey: (NSString *) key
{
    // TODO (Aug 11, 2016): Consider changing operations below to nested callbacks or promises.
    // Also need to delete note from NotesCollection and set note to nil via [ni delete:nil];
    // Step 1 of 3: Delete note from notes table
    FIRDatabaseReference *deleteNoteRef = [_notesTableRef child: key];
    [deleteNoteRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        NSLog(@"error: %@", error);
        NSLog(@"key: %@", ref.key);
        if (error) {
            NSLog(@"Note could NOT be removed.");
        } else {
            NSLog(@"Note removed successfully.");
//            [ni removeFromSuperview];
        }
    }];
    
    // Step 2 of 3: Delete note key from current visuall table
    FIRDatabaseReference *deleteNoteKeyFromVisuallRef = [[_visuallsTable_currentVisuallRef child: @"notes"] child: key];
    [deleteNoteKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if (error) {
            NSLog(@"Note key could not be removed.");
        } else {
            NSLog(@"Note key removed successfully.");
        }
    }];
    
    // Step 3 of 3: Decrement notes counter in visuall table
    FIRDatabaseReference *notesCounterRef = [_visuallsTable_currentVisuallRef child: @"notes_counter"];
    [self increaseOrDecreaseCounter: notesCounterRef byAmount:-1];
    
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

