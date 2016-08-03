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

FIRDatabaseReference *_ref;
FIRDatabaseReference *_currentUserRef;
NSString *_visuallKey;
FIRDatabaseReference *_visuallsRef;
FIRDatabaseReference *_currentVisuallRef;
FIRDatabaseReference *_notesRef;
FIRDatabaseReference *_groupsRef;
void (^_callbackNoteItem)(NoteItem2 *ni);
void (^_callbackGroupItem)(GroupItem *gi);

- (void) GIDdisconnect
{
//    [[GIDSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];
}

-(void) userIsSignedInHandler: (FIRUser *) user
{
    _ref = [[[FIRDatabase database] reference] child:@"version_01"];
    _notesRef = [_ref child: @"notes"];
    _groupsRef = [_ref child: @"groups"];
    
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
    
    _currentUserRef = [[_ref child:@"users"] child:userID];
    [_currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
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
            [[[_ref child:@"users"] child: userID] setValue: newUserBasicUserInfo];
        } else {
            NSLog(@"%@", snapshot.value );
            [[[_ref child:@"users"] child: userID] updateChildValues:@{@"date_last_visit": [FIRServerValue timestamp]}];
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void) loadVisuallsForCurrentUser
{
    _visuallsRef = [_ref child: @"visualls"];
    FIRDatabaseReference *visuallsPersonalRef =  [_currentUserRef child: @"visualls/personal"];
    
    [visuallsPersonalRef observeSingleEventOfType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ( ![snapshot exists] ) //create first Visuall for current user
         {
             NSDictionary *visuallDictionary = @{
                                              @"title": @"My First Visuall",
                                              @"date-created": [FIRServerValue timestamp],
                                              @"created-by": [FIRAuth auth].currentUser.uid,
                                              @"write-permission:" : @{ [FIRAuth auth].currentUser.uid : @"1" }
                                              };
             _currentVisuallRef = [_visuallsRef childByAutoId];
             [_currentVisuallRef updateChildValues: visuallDictionary];
             [visuallsPersonalRef updateChildValues: @{_currentVisuallRef.key: @"1"} ];
         
         } else {  // run thru list of Visualls
            NSDictionary *visuallPersonalKeys = (NSDictionary *) snapshot.value;
             for (NSString *key in visuallPersonalKeys) {
                 _visuallKey = key;
                 _currentVisuallRef = [_visuallsRef child: key];
                 [self loadVisuallFromKey: key];
                 return; // TODO: early termination here only loading the 1st and only visuall
             }
         }
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
    FIRDatabaseReference *listOfNoteKeysRef = [[_visuallsRef child:key] child: @"notes"];
    FIRDatabaseReference *listOfGroupKeysRef = [[_visuallsRef child:key] child: @"groups"];
    [self loadListOfNotesFromRef: listOfNoteKeysRef];
    [self loadListOfGroupsFromRef: listOfGroupKeysRef];
}

- (void) loadListOfNotesFromRef: (FIRDatabaseReference *) listOfNoteKeysRef
{
    self.notesCollection = [NotesCollection new];
    [listOfNoteKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         NSString *key = snapshot.key;
         [self loadNoteFromRef: [_notesRef child:key]];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
}

- (void) loadListOfGroupsFromRef: (FIRDatabaseReference *) listOfGroupKeysRef
{
    self.groupsCollection = [GroupsCollection new];
    [listOfGroupKeysRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         NSString *key = snapshot.key;
         [self loadGroupFromRef: [_groupsRef child:key]];
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
}

-(void) loadNoteFromRef: (FIRDatabaseReference *) noteRef
{
    [noteRef observeEventType: FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
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
    FIRDatabaseReference *notesRef = [_ref child: @"notes"];
    NSMutableDictionary *noteDictionary = [@{
                                     @"data/title": ni.note.title,
                                     @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
                                     @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
                                     @"data/font-size": [NSString stringWithFormat:@"%.3f", ni.note.fontSize],
                                     @"metadata/parent-visuall": _visuallKey,
                                     @"metadata/date-created": [FIRServerValue timestamp],
                                     @"metadata/created-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
                                     @"metadata/created-by-uid": [FIRAuth auth].currentUser.uid,
                                     } mutableCopy];
    [noteDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    FIRDatabaseReference *newNoteRef = [notesRef childByAutoId];
    [newNoteRef updateChildValues: noteDictionary];
    ni.note.key = newNoteRef.key;
    [[_currentVisuallRef child: @"notes"] updateChildValues: @{newNoteRef.key: @"1"}];
}

- (void) setValueGroup: (GroupItem *) gi
{
    FIRDatabaseReference *groupsRef = [_ref child: @"groups"];
    NSMutableDictionary *groupDictionary = [@{
                                      @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                      @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                      @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                      @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height],
                                      @"metadata/parent-visuall": _visuallKey,
                                      @"metadata/date-created": [FIRServerValue timestamp],
                                      @"metadata/created-by-username": [FIRAuth auth].currentUser.displayName,  // TODO: working?
                                      @"metadata/created-by-uid": [FIRAuth auth].currentUser.uid,
                                      } mutableCopy];
    [groupDictionary addEntriesFromDictionary: [self getCommonUpdateParameters]];
    FIRDatabaseReference *newGroupRef = [groupsRef childByAutoId];
    [newGroupRef updateChildValues: groupDictionary];
    gi.group.key = newGroupRef.key;
    [[_currentVisuallRef child: @"groups"] updateChildValues: @{newGroupRef.key: @"1"}];
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
        FIRDatabaseReference *notesDataRef = [[_ref child: @"notes"] child: [ni.note.key stringByAppendingString:@"/data"]];
        NSMutableDictionary *noteDict = [@{
                                           propertyName : [ni.note valueForKey:propertyName]
                                           } mutableCopy];
        [noteDict addEntriesFromDictionary: [self getCommonUpdateParameters]];
        [notesDataRef updateChildValues: noteDict];
    }
    else if ( [visualObject isGroupItem] )
    {
        if ( [propertyName isEqualToString:@"frame"] )
        {
            GroupItem *gi = [visualObject getGroupItem];
            FIRDatabaseReference *groupDataRef = [[_ref child: @"groups"] child: [gi.group.key stringByAppendingString:@"/data"]];
            NSMutableDictionary *groupDictionary = [@{
                                              @"x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                              @"y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                              @"width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                              @"height": [NSString stringWithFormat:@"%.3f", gi.group.height],
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
        FIRDatabaseReference *notesDataRef = [[_ref child: @"notes"] child: [ni.note.key stringByAppendingString:@"/data"]];
        [notesDataRef updateChildValues: @{
                                  propertyName1 : [ni.note valueForKey:propertyName1],
                                  propertyName2 : [ni.note valueForKey:propertyName2],
                                  }];
    }
    else if ([visualObject isKindOfClass: [GroupItem class]]) {  // TODO - simple method the check if it's a GroupItem
        GroupItem *gi = (GroupItem *) visualObject;
        NSString *groupUrl = [[@"groups/" stringByAppendingString: gi.group.key] stringByAppendingString:@"/data/"];
        [_ref updateChildValues: @{
                                  [groupUrl stringByAppendingString:propertyName1] : [gi.group valueForKey:propertyName1],
                                  [groupUrl stringByAppendingString:propertyName2] : [gi.group valueForKey:propertyName2],
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
