//
//  StateUtil+FIrebase.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtil+Firebase.h"
#import "UIView+VisualItem.h"
#import <GoogleSignIn/GoogleSignIn.h>

@implementation StateUtil (Firebase)

FIRDatabaseReference *_version01TableRef;
FIRDatabaseReference *_usersTableCurrentUser;
NSString *_currentVisuallKey;
FIRDatabaseReference *_visuallsTableRef;
FIRDatabaseReference *_visuallsTableCurrentVisuallRef;
FIRDatabaseReference *_notesTableRef;
FIRDatabaseReference *_groupsTableRef;
void (^_callbackNoteItem)(NoteItem2 *ni);
void (^_callbackGroupItem)(GroupItem *gi);

- (void) GIDdisconnect
{
//    [[GIDSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];
}

-(void) userIsSignedInHandler: (FIRUser *) user
{
    _version01TableRef = [[[FIRDatabase database] reference] child:@"version_01"];
    _notesTableRef = [_version01TableRef child: @"notes"];
    _groupsTableRef = [_version01TableRef child: @"groups"];

    NSString *userID = [FIRAuth auth].currentUser.uid;
    NSString *name;
    NSString *email;
    NSString *provider;
    for ( id <FIRUserInfo> profile in user.providerData) {
        NSString *providerID = profile.providerID;
        NSString *uid = profile.uid;  // Provider-specific UID
        name = profile.displayName;
        email = profile.email;
        //        provider = profile.email;
        NSURL *photoURL = profile.photoURL;
        NSLog(@"userID: %@", userID);
        NSLog(@"uid: %@", uid);
    }
    
    _usersTableCurrentUser = [[_version01TableRef child:@"users"] child:userID];
    [_usersTableCurrentUser observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
        if ( ![snapshot exists] )  // we have a new user
        {
            NSString *myUserName = snapshot.value[@"username"];
            NSLog(@"username: %@", myUserName);
            NSDictionary *newUserBasicUserInfo = @{
                                                   @"full_name" : name,
                                                   @"email": email,
                                                   @"date-joined": [FIRServerValue timestamp],
                                                   @"date-last_visit": [FIRServerValue timestamp]
                                                   };
            [[[_version01TableRef child:@"users"] child: userID] setValue: newUserBasicUserInfo];
        } else {
            NSLog(@"%@", snapshot.value );
            [[[_version01TableRef child:@"users"] child: userID] updateChildValues:@{@"date_last_visit": [FIRServerValue timestamp]}];
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void) loadVisuallsForCurrentUser
{
    _visuallsTableRef = [_version01TableRef child: @"visualls"];
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
             _visuallsTableCurrentVisuallRef = [_visuallsTableRef childByAutoId];
             _currentVisuallKey = _visuallsTableCurrentVisuallRef.key;
             [_visuallsTableCurrentVisuallRef updateChildValues: visuallDictionary];
             [visuallsPersonalRef updateChildValues: @{_visuallsTableCurrentVisuallRef.key: @"1"} ];
         
         } else {  // run thru list of Visualls
            NSDictionary *visuallPersonalKeys = (NSDictionary *) snapshot.value;
             for (NSString *key in visuallPersonalKeys) {
                 _currentVisuallKey = key;
                 _visuallsTableCurrentVisuallRef = [_visuallsTableRef child: key];
                 [self loadVisuallFromKey: key];
                 return; // TODO: early termination here only loading the 1st and only visuall
             }
         }
//        [[FIRAuth auth].currentUser setValuesForKeysWithDictionary:@{@"currentVisuallKey" : _visuallKey}];

     }];
    
}

- (void) setCallbackNoteItem: (void (^)(NoteItem2 *ni)) callbackNoteItem
{
    _callbackNoteItem = [callbackNoteItem copy];
};

- (void) setCallbackGroupItem: (void (^)(GroupItem *gi)) callbackGroupItem
{
    _callbackGroupItem = [callbackGroupItem copy];
};

- (void) loadVisuallFromKey: (NSString *) key
{
    FIRDatabaseReference *listOfNoteKeysRef = [[_visuallsTableRef child:key] child: @"notes"];
    FIRDatabaseReference *listOfGroupKeysRef = [[_visuallsTableRef child:key] child: @"groups"];
    [self loadListOfNotesFromRef: listOfNoteKeysRef];
    [self loadListOfGroupsFromRef: listOfGroupKeysRef];
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
         
         [self loadNoteFromRef: [_notesTableRef child:key]];
         
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
         NSLog(@"loadListOfGroupsFromRef: %@", error.description);
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
         NSLog(@"%@", error.description);
     }];
}

-(void) loadGroupFromRef: (FIRDatabaseReference *) groupRef
{
    [groupRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [self.groupsCollection getGroupItemFromKey: snapshot.key] )  // If the group already exists in the collection
         {
             return;
         }
         GroupItem *newGroup = [[GroupItem alloc] initGroup:snapshot.key andValue:snapshot.value];
         [self.groupsCollection addGroup: newGroup withKey:snapshot.key];
         _callbackGroupItem(newGroup);
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
}


/*
 * Name: setValueNote
 * Description: Firebase setter for a brand new note. Updates should NOT use this method.
 */
- (void) setValueNote: (NoteItem2 *) ni
{
    NSMutableDictionary *noteDictionary = [@{
                                     @"data/title": ni.note.title,
                                     @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
                                     @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
                                     @"data/font-size": [NSString stringWithFormat:@"%.3f", ni.note.fontSize],
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
    [[_visuallsTableCurrentVisuallRef child: @"notes"] updateChildValues: @{newNoteRef.key: @"1"}];
}

- (void) setValueGroup: (GroupItem *) gi
{
    FIRDatabaseReference *groupsRef = [_version01TableRef child: @"groups"];
    NSMutableDictionary *groupDictionary = [@{
                                      @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                      @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                      @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                      @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height],
                                      @"metadata/parent-visuall": _currentVisuallKey,
                                      @"metadata/date-created": [FIRServerValue timestamp],
                                      @"metadata/created-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
                                      @"metadata/created-by-uid": [FIRAuth auth].currentUser.uid,
                                      } mutableCopy];
    [groupDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    FIRDatabaseReference *newGroupRef = [groupsRef childByAutoId];
    gi.group.key = newGroupRef.key;
    [self.groupsCollection addGroup: gi withKey: newGroupRef.key];
    [newGroupRef updateChildValues: groupDictionary];
    [[_visuallsTableCurrentVisuallRef child: @"groups"] updateChildValues: @{newGroupRef.key: @"1"}];
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
    if ( [visualObject isNoteItem] )
    {
        NoteItem2 *ni = [visualObject getNoteItem];
        FIRDatabaseReference *notesDataRef = [[_version01TableRef child: @"notes"] child: ni.note.key];
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
            FIRDatabaseReference *groupDataRef = [[_version01TableRef child: @"groups"] child: gi.group.key];
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
}

- (void) updateChildValues: (UIView *) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2
{
    
    if ( [visualObject isNoteItem] ) {
        NoteItem2 *ni = [visualObject getNoteItem];
        FIRDatabaseReference *notesDataRef = [[_version01TableRef child: @"notes"] child: [ni.note.key stringByAppendingString:@"/data"]];
        [notesDataRef updateChildValues: @{
                                  propertyName1 : [ni.note valueForKey:propertyName1],
                                  propertyName2 : [ni.note valueForKey:propertyName2],
                                  }];
    }
    else if ([visualObject isKindOfClass: [GroupItem class]]) {  // TODO - simple method the check if it's a GroupItem
        GroupItem *gi = (GroupItem *) visualObject;
        NSString *groupUrl = [[@"groups/" stringByAppendingString: gi.group.key] stringByAppendingString:@"/data/"];
        [_version01TableRef updateChildValues: @{
                                  [groupUrl stringByAppendingString:propertyName1] : [gi.group valueForKey:propertyName1],
                                  [groupUrl stringByAppendingString:propertyName2] : [gi.group valueForKey:propertyName2],
                                  }];
    }
}

- (void) removeValue: (UIView *) view
{
    if( [view isNoteItem])
    {
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
//                [ni delete:nil];
            }
        }];
        
        FIRDatabaseReference *deleteNoteKeyFromVisuallRef = [[_visuallsTableCurrentVisuallRef child: @"notes"] child: ni.note.key];
        [deleteNoteKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Note key could not be removed.");
            } else {
                NSLog(@"Note key removed successfully.");
            }
        }];
        
    }
    else if([view isGroupItem])
    {
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
        
        FIRDatabaseReference *deleteNoteKeyFromVisuallRef = [[_visuallsTableCurrentVisuallRef child: @"groups"] child: gi.group.key];
        [deleteNoteKeyFromVisuallRef removeValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            if (error) {
                NSLog(@"Group key could not be removed.");
            } else {
                NSLog(@"Group key removed successfully.");
            }
        }];
    }
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