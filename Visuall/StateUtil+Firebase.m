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

- (void) GIDdisconnect
{
//    [[GIDSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];
}

-(void) userIsSignedInHandler: (FIRUser *) user
{
    _ref = [[[FIRDatabase database] reference] child:@"version_01"];
    
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
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ( ![snapshot exists] )  // we have a new user
        {
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
        
        // Get user value
        //        NSString *myUserName = snapshot.value[@"username"];
        
        // ...
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void) setValueNote: (NoteItem2 *) ni
{
    FIRDatabaseReference *notesRef = [_ref child: @"notes"];
        NSDictionary *noteDictionary = @{
                                         @"data/title": ni.note.title,
                                         @"data/x": [NSString stringWithFormat:@"%.3f", ni.note.x],
                                         @"data/y": [NSString stringWithFormat:@"%.3f", ni.note.y],
                                         @"data/font-size": [NSString stringWithFormat:@"%.3f", ni.note.fontSize],
                                         @"metadata/date-created": [FIRServerValue timestamp],
                                         @"metadata/created-by": [FIRAuth auth].currentUser.uid
                                         };
    FIRDatabaseReference *newNoteRef = [notesRef childByAutoId];
    [newNoteRef updateChildValues: noteDictionary];
    ni.note.key = newNoteRef.key;
}

- (void) setValueGroup: (GroupItem *) gi
{
    FIRDatabaseReference *groupsRef = [_ref child: @"groups"];
    NSDictionary *groupDictionary = @{
                                      @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
                                      @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
                                      @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
                                      @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height]
                                      };
    FIRDatabaseReference *newGroupRef = [groupsRef childByAutoId];
    [newGroupRef updateChildValues: groupDictionary];
    gi.group.key = newGroupRef.key;
}

- (void) loadFirebaseNotes: (void (^)(NoteItem2 *ni)) callback
{
    _ref = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *notesRef = [_ref child: @"notes"];
//    [Firebase goOffline];
    self.notesCollection = [NotesCollection new];
    [notesRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         if([self.notesCollection getNoteFromKey:snapshot.key])  // If the note already exists in the collection
         {
             return;
         }
         
         NoteItem2 *newNote = [[NoteItem2 alloc] initNoteFromFirebase:snapshot.key andValue:snapshot.value];
         [self.notesCollection addNote:newNote withKey:snapshot.key];
         callback(newNote);
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
}

- (void) loadFirebaseGroups: (void (^)(GroupItem *ni)) callback
{
    _ref = [[[FIRDatabase database] reference] child:@"version_01"];
    FIRDatabaseReference *groupsRef = [_ref child: @"groups"];
    self.groupsCollection = [GroupsCollection new];
    [groupsRef observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot)
     {
         if( [self.groupsCollection getGroupItemFromKey: snapshot.key] )  // If the group already exists in the collection
         {
             return;
         }
         
         GroupItem *newGroup = [[GroupItem alloc] initGroup:snapshot.key andValue:snapshot.value];
         [self.groupsCollection addGroup: newGroup withKey:snapshot.key];
         callback(newGroup);
         
     } withCancelBlock:^(NSError *error)
     {
         NSLog(@"%@", error.description);
     }];
}

- (void) updateChildValue: (UIView *) visualObject Property: (NSString *) propertyName
{
    if ( [visualObject isNoteItem] )
    {
        NoteItem2 *ni = [visualObject getNoteItem];
        FIRDatabaseReference *notesDataRef = [[_ref child: @"notes"] child: [ni.note.key stringByAppendingString:@"/data"]];
        [notesDataRef updateChildValues: @{
                                           propertyName : [ni.note valueForKey:propertyName]
                                           }];
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
 - (void) loadFirebaseGroups
 {
 
 Firebase *refGroups = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com/groups2"];
 [Firebase goOffline];
 self.groupsCollection = [GroupsCollection new];
 [[TransformUtil sharedManager] setGroupsCollection: self.groupsCollection];
 [refGroups observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
 {
 if([self.groupsCollection getGroupItemFromKey: snapshot.key])  // If the note already exists in the collection
 {
 return;  // TODO: add functionality to update values during multiuser collaboration
 }
 
 GroupItem *newGroup = [[GroupItem alloc] initGroup:snapshot.key andValue:snapshot.value];
 [self addGestureRecognizersToGroup: newGroup];
 [self.groupsCollection addGroup: newGroup withKey: snapshot.key];
 [self.GroupsView addSubview:newGroup];
 //         [[TransformUtil sharedManager] transformGroupItem: newGroup];
 } withCancelBlock:^(NSError *error)
 {
 NSLog(@"%@", error.description);
 }];
 
 }
 

 
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
 
 - (void) updateChildValue: (id) visualObject andProperty: (NSString *) propertyName
 {
 Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
 
 if ( [visualObject isKindOfClass: [NoteItem2 class]] ) {
 NoteItem2 *ni = (NoteItem2 *) visualObject;
 NSString *noteUrl = [[@"notes2/" stringByAppendingString: ni.note.key] stringByAppendingString:@"/data/"];
 [ref updateChildValues: @{
 [noteUrl stringByAppendingString:propertyName] : [ni.note valueForKey:propertyName]
 }];
 }
 }
 

 
 - (void) setGroup: (GroupItem *) gi
 {
 Firebase *ref = [[Firebase alloc] initWithUrl: @"https://brainspace-biz.firebaseio.com"];
 Firebase *groupsRef = [ref childByAppendingPath: @"groups2"];
 Firebase *newGroupRef = [groupsRef childByAutoId];
 NSDictionary *groupDictionary = @{
 @"data/x": [NSString stringWithFormat:@"%.3f", gi.group.x],
 @"data/y": [NSString stringWithFormat:@"%.3f", gi.group.y],
 @"data/width": [NSString stringWithFormat:@"%.3f", gi.group.width],
 @"data/height": [NSString stringWithFormat:@"%.3f", gi.group.height]
 };
 [newGroupRef updateChildValues: groupDictionary];
 gi.group.key = newGroupRef.key;
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
