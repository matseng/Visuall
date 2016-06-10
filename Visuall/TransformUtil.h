//
//  NavigationUtil.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Note.h"
#import "NoteItem.h"
#import "NotesCollection.h"
#import "GroupItem.h"
#import "VisualItem.h"
#import "GroupsCollection.h"

@interface TransformUtil : NSObject

@property CGPoint translation;
@property float scale;
@property float scaleTest;
@property float zoom;
@property CGPoint pan;
@property float _relativeScale;
@property NotesCollection *notesCollection;
@property GroupsCollection *groupsCollection;


+(id)sharedManager;

-(void) handlePanBackground: (UIPanGestureRecognizer *) pan withNotes: (NotesCollection *) Notes withGroups: (GroupsCollection *) GroupItems;

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) pinch withNotes: (NotesCollection *) Notes andGroups: (GroupsCollection *) Groups;

-(void) transformNoteItem: (NoteItem *) noteItem;

-(void) transformGroupItem: (GroupItem *) groupItem;

-(void) transformVisualItem: (VisualItem *) visualItem;

-(CGPoint) getGlobalCoordinate: (CGPoint) point;

-(void) handleDoubleTapToZoom: (UITapGestureRecognizer *) gestureRecognizer;

//-(void) setNotesCollection: (NotesCollection *) nc andGroupsCollection: (GroupsCollection *) gc;

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