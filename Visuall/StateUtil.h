//
//  NavigationUtil.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import Firebase;
#import "Note.h"
#import "NotesCollection.h"
#import "GroupItem.h"
#import "VisualItem.h"
#import "GroupsCollection.h"

@interface StateUtil : NSObject

@property FIRUser *firebaseUser;
@property CGPoint translation;
@property float scale;
@property float scaleTest;
@property float zoom;
@property CGPoint pan;
@property float _relativeScale;
@property NotesCollection *notesCollection;
@property GroupsCollection *groupsCollection;
// New state properties (moving away from ViewController)
@property UIView *selectedVisualItem;
@property UIView *selectedVisualItemSubview;  // e.g. a group handle for resizing
@property BOOL editModeOn;

+(id)sharedManager;

-(void) handlePanBackground: (UIPanGestureRecognizer *) pan withNotes: (NotesCollection *) Notes withGroups: (GroupsCollection *) GroupItems;

//-(void) handlePinchBackground: (UIPinchGestureRecognizer *) pinch withNotes: (NotesCollection *) Notes andGroups: (GroupsCollection *) Groups;

-(void) transformGroupItem: (GroupItem *) groupItem;

-(void) transformVisualItem: (VisualItem *) visualItem;

-(CGPoint) getGlobalCoordinate: (CGPoint) point;

-(void) handleDoubleTapToZoom: (UITapGestureRecognizer *) gestureRecognizer andTargetView: (UIView *) view;



//-(void) setNotesCollection: (NotesCollection *) nc andGroupsCollection: (GroupsCollection *) gc;

@end

@protocol FirebaseUtilProtocolDelegate

- (void) loadFirebaseNotes: (void (^)(NoteItem2 *ni)) callback;

- (void) userIsSignedInHandler: (FIRUser *) firebaseUser;  // Implemented in StateUtil+Firebase.m

- (void) setValueNote: (NoteItem2 *) ni;

- (void) setValueGroup: (GroupItem *) gi;

- (void) updateChildValue: (UIView *) visualObject Property: (NSString *) propertyName;

- (void) updateChildValues: (UIView *) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

- (void) GIDdisconnect;

@end


//@interface MyManager : NSObject {
//    NSString *someProperty;
//}
//
//@property (nonatomic, retain) NSString *someProperty;
//
//+ (id)sharedManager;
//
//@end