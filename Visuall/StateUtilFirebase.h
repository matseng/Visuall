//
//  StateUtilFirebase.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/18/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtil.h"
#import "UIView+VisualItem.h"

static void (^__callbackGroupItem)(GroupItem *gi);
static void (^__callbackNoteItem)(NoteItem2 *ni);

@protocol Create

+ (void) setSharedVisuall: (NSString *) visuallKey withEmails: (NSArray *) emails;

@end

@protocol Read

- (void) loadNoteFromRef: (FIRDatabaseReference *) noteRef;
- (void) loadGroupFromRef: (FIRDatabaseReference *) groupRef;
- (void) loadArrowFromRef: (FIRDatabaseReference *) arrowRef;
- (void) loadPathFromRef: (FIRDatabaseReference *) pathRef;
- (void) allNotesDidLoad;
- (void) allGroupsDidLoad;



@end

@protocol Update

- (void) updateNoteFromRef: (FIRDatabaseReference *) noteRef;
- (void) updateGroupFromRef: (FIRDatabaseReference *) groupRef;

@end

@protocol Delete

- (void) removeValue: (UIView *) view;
+ (void) removeSharedVisuallInvite: (NSString *) visuallKey withEmails: (NSArray *) emails;

@end

@interface StateUtilFirebase : StateUtil

@property FIRDatabaseReference *usersTableCurrentUser;
@property FIRDatabaseReference *visuallsTableRef;
@property FIRDatabaseReference *visuallsTable_currentVisuallRef;
@property FIRDatabaseReference *notesTableRef;
@property FIRDatabaseReference *groupsTableRef;
@property FIRDatabaseReference *arrowsTableRef;
@property FIRDatabaseReference *pathsTableRef;
@property FIRDatabaseReference *publicVisuallsTableRef;

@property FIRStorageReference *storageImagesRef;

@property __block int numberOfGroupsToBeLoaded;
@property __block int numberOfGroupsLoaded;
@property __block BOOL allGroupsLoadedBOOL;

@property __block int numberOfNotesToBeLoaded;
@property __block int numberOfNotesLoaded;
@property __block BOOL allNotesLoadedBOOL;

@property __block int numberOfArrowsToBeLoaded;
@property __block int numberOfArrowsLoaded;
@property __block BOOL allArrowsLoadedBOOL;

@property __block int numberOfPathsToBeLoaded;
@property __block int numberOfPathsLoaded;
@property __block BOOL allPathsLoadedBOOL;

@property NSInteger childrenCountNotes;

+ (void) setCallbackNoteItem: (void (^)(NoteItem2 *ni)) callbackOnNote;

+ (void) setCallbackGroupItem: (void (^)(GroupItem *gi)) callbackGroupItem;

+ (void) loadVisuallsListForCurrentUser;

+ (void) removeVisuall: (NSString *) key;

+ (NSMutableDictionary *) setValueVisuall: (NSMutableDictionary *) title;

+ (void) updateMetadataVisuall: (NSMutableDictionary *) dict;

- (void) setCallbackPublicVisuallLoaded: (void (^)(void)) callback;

//- (void) loadVisuallsListForCurrentUser;

- (void) loadVisuallFromKey: (NSString *) key;

- (void) loadVisuallsForCurrentUser;

- (void) loadFirebaseNotes: (void (^)(NoteItem2 *ni)) callback;

- (void) loadFirebaseGroups: (void (^)(GroupItem *ni)) callback;

- (void) userIsSignedInHandler: (FIRUser *) firebaseUser;  // Implemented in StateUtil+Firebase.m

- (void) setValueVisuall: (NSString *) title;

- (void) setValueNote: (NoteItem2 *) ni;

- (void) setValueGroup: (GroupItem *) gi;

- (void) setValueArrow: (VisualItem *) vi;

- (void) setValuePath: (PathItem *) pi;

- (void) updateChildValue: (UIView *) visualObject Property: (NSString *) propertyName;

- (void) updateChildValues: (UIView *) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

- (void) updateValuePath: (PathItem *) pi;

- (void) loadPublicVisuallsList;

- (void) loadOrCreatePublicVisuall: (NSString *) publicKey;

- (float) getZoomScale;

- (void) setUserID: (NSString *) userID;

- (BOOL) isSnapshotFromLocalDevice: (FIRDataSnapshot*) snapshot;

- (void) removeNoteKeyFromParentVisuall: (NSString *) key;

@end
