//
//  ViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupItem.h"
#import "GroupItemImage.h"
#import "NotesCollection.h"
#import "GroupsCollection.h"
#import "TiledLayerView.h"
#import "StateUtilFirebase.h"
#import "ScrollViewMod.h"
#import "SegmentedControlMod.h"
#import "SevenSwitch.h"


@interface ViewController : UIViewController

@property (nonatomic, strong) StateUtilFirebase *visuallState;

@property (nonatomic, strong) NSString *firebaseURL;

@property (nonatomic, strong) NSString *firebaseVisuallKeyToLoad;

@property (strong, nonatomic) IBOutlet UIView *Background;

@property (strong, nonatomic) IBOutlet ScrollViewMod *BackgroundScrollView;

@property TiledLayerView *BoundsTiledLayerView;

@property (strong, nonatomic) IBOutlet UIView *VisualItemsView;

@property (strong, nonatomic) IBOutlet UIView *GroupsView;

@property (strong, nonatomic) IBOutlet UIView *ArrowsView;

@property UIView *drawGroupView;

@property (strong, nonatomic) IBOutlet UIView *NotesView;

@property (strong, nonatomic) UIScrollView *scrollViewButtonList;

@property NotesCollection *NotesCollection;

@property GroupsCollection *groupsCollection;

@property UIView *lastSelectedObject;

@property UIView *activelySelectedObjectDuringPan;


@property SevenSwitch *editSwitch;  // Utilized in ViewController+Menus.m [...]
@property SegmentedControlMod *segmentControlVisualItem;
@property SegmentedControlMod *segmentControlFormattingOptions;
@property BOOL alreadyAnimated;
@property UIScrollView *submenuScrollView;
@property UIView *submenu;
@property UIScrollView *secondSubmenuScrollView;
@property SegmentedControlMod *segmentControlInsertMedia;
@property UIButton *trashButton; // Utilized in ViewController+Menus.m

- (BOOL) setSelectedObject:(UIView *) object;

- (void) backButtonHandler;

- (void) buttonTapped: (id) sender;

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer;

//- (void) updateChildValue: (id) visualObject andProperty: (NSString *) propertyName;

//- (void) updateChildValues: (id) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

- (void) setTransformFirebase;

- (void) setInitialNote: (NoteItem2 *) ni;

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem;

//- (void) removeValue: (id) object;

- (void) calculateTotalBounds: (UIView *) view;

- (void) updateTotalBounds: (UIView *) view;

- (void) addGroupItemToMVC: (GroupItem *) currentGroupItem;

@end

