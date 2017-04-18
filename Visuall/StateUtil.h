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
#import "ScrollViewMod.h"
#import "TiledLayerView.h"
#import "Collection.h"
#import "FDDrawView.h"

@interface StateUtil : NSObject


@property CGPoint translation;
@property float scale;
@property float scaleTest;
@property float zoom;
@property CGPoint pan;
@property float _relativeScale;
@property (strong, atomic) NSMutableDictionary *metadata;  //
@property (strong, atomic) NotesCollection *notesCollection;
@property (strong, atomic) GroupsCollection *groupsCollection;
@property (strong, atomic) Collection *arrowsCollection;
@property (strong, atomic) Collection *pathsCollection;

// New state properties (moving away from ViewController)
@property FIRUser *firebaseUser;
@property ScrollViewMod *BackgroundScrollView;
@property TiledLayerView *BoundsTiledLayerView;
@property UIView *VisualItemsView;
@property UIView *GroupsView;
@property UIView *NotesView;
@property UIView *ArrowsView;
@property FDDrawView *DrawView;
@property UIView *selectedVisualItem;
@property UIView *selectedVisualItemSubview;  // e.g. a group handle for resizing
@property UIView *selectedVisualItemDuringPan;  // see ViewController.m --> handleTouchDown method
@property BOOL editModeOn;
@property CGPoint touchDownPoint;

@property NSMutableDictionary *topMenuViews;

// Default properties for Text, Arrows and Paths
@property float textFontSize;
@property float arrowHeadSize;
@property float pathLineWidth;

- (void) handlePanBackground: (UIPanGestureRecognizer *) pan withNotes: (NotesCollection *) Notes withGroups: (GroupsCollection *) GroupItems;

- (void) transformGroupItem: (GroupItem *) groupItem;

- (void) transformVisualItem: (VisualItem *) visualItem;

- (CGPoint) getGlobalCoordinate: (CGPoint) point;

- (void) handleDoubleTapToZoom: (UITapGestureRecognizer *) gestureRecognizer andTargetView: (UIView *) view;

- (float) getZoomScale;

- (void) scaleNoteTitleSize: (NoteItem2 *) ni;

- (id) getItemFromKey: (NSString *) key;

- (BOOL) isDrawButtonSelected;

- (void) setDefaultSizes;

- (float) roundUpToEven: (float) size;

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
