//
//  StateUtilFirebase.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/18/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "StateUtil.h"

@interface StateUtilFirebase : StateUtil

//+(id) sharedManager;
@property NSInteger childrenCountNotes;

- (void) setCallbackNoteItem: (void (^)(NoteItem2 *ni)) callbackOnNote;

- (void) setCallbackGroupItem: (void (^)(GroupItem *gi)) callbackGroupItem;

- (void) setCallbackPublicVisuallLoaded: (void (^)(void)) callback;

- (void) loadVisuallsListForCurrentUser;

- (void) loadVisuallsForCurrentUser;

- (void) loadFirebaseNotes: (void (^)(NoteItem2 *ni)) callback;

- (void) loadFirebaseGroups: (void (^)(GroupItem *ni)) callback;

- (void) userIsSignedInHandler: (FIRUser *) firebaseUser;  // Implemented in StateUtil+Firebase.m

- (void) setValueNote: (NoteItem2 *) ni;

- (void) setValueGroup: (GroupItem *) gi;

- (void) setValueArrow: (VisualItem *) vi;

- (void) updateChildValue: (UIView *) visualObject Property: (NSString *) propertyName;

- (void) updateChildValues: (UIView *) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

- (void) removeValue: (UIView *) view;

- (void) loadPublicVisuallsList;

- (void) loadOrCreatePublicVisuall: (NSString *) publicKey;

- (float) getZoomScale;

- (void) setUserID: (NSString *) userID;

@end
