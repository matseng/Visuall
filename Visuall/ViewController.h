//
//  ViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupItem.h"
#import "ArrowItem.h"
#import "GroupItemImage.h"
#import "NotesCollection.h"
#import "GroupsCollection.h"
#import "TiledLayerView.h"
#import "StateUtilFirebase.h"
#import "ScrollViewMod.h"
#import "SegmentedControlMod.h"
#import "SevenSwitch.h"
#import "FDDrawView.h"


@protocol GroupsController  // implemented in ViewController+Group.h

- (void) addGroupItemToMVC: (GroupItem *) currentGroupItem;

@end

@protocol ArrowsController  // implemented in ViewController+Group.h

- (void) addArrowItemToMVC: (ArrowItem *) arrow;

@end

@protocol XMLController  // implemented in ViewController+Group.h

- (void) loadAndUploadXML;

@end

@protocol TopMenuProtocol  // implemented in ViewController+Group.h

@property NSDictionary *topMenuViews;

@end


@interface ViewController : UIViewController

@property(nonatomic,retain) UIPopoverPresentationController *dateTimePopover8;

@property (nonatomic, strong) StateUtilFirebase *visuallState;

@property (nonatomic, strong) NSString *firebaseURL;

@property (nonatomic, strong) NSString *firebaseVisuallKeyToLoad;

@property (nonatomic, weak) NSMutableDictionary *metadataTemp;  // used temporarily to load data from previous viewcontroller

@property (strong, nonatomic) UIView *Background;

@property (strong, nonatomic) ScrollViewMod *BackgroundScrollView;

@property (strong, nonatomic) TiledLayerView *BoundsTiledLayerView;

@property (strong, nonatomic) UIView *VisualItemsView;

@property (strong, nonatomic) UIView *GroupsView;

@property (strong, nonatomic) UIView *ArrowsView;

@property (strong, nonatomic) CAShapeLayer *DrawArrowShapeLayer;

@property (strong, nonatomic) UIView *drawGroupView;

@property (strong, nonatomic) UIView *NotesView;

@property (strong, nonatomic) UIScrollView *scrollViewButtonList;

@property CGRect totalBoundsRect;

//@property UIView *lastSelectedObject;

//@property UIView *activelySelectedObjectDuringPan;

@property CGPoint drawGroupViewStart;  // Used in ViewController+Group.m

@property SevenSwitch *editSwitch;  // Utilized in ViewController+Menus.m [...]
@property SegmentedControlMod *segmentControlVisualItem;
@property SegmentedControlMod *segmentControlFormattingOptions;
@property BOOL alreadyAnimated;
@property UIScrollView *submenuScrollView;
@property UIView *submenu;
@property UIScrollView *secondSubmenuScrollView;
@property SegmentedControlMod *segmentControlInsertMedia;
@property NSMutableDictionary *buttonDictionary;
@property UIButton *trashButton;

- (void) updateSecondSubmenuStateFromSelectedVisualItem; // Utilized in ViewController+Menus.m

- (BOOL) setSelectedObject:(UIView *) object;

- (void) backButtonHandler;

- (void) buttonTapped: (id) sender;

//- (void) updateChildValue: (id) visualObject andProperty: (NSString *) propertyName;

//- (void) updateChildValues: (id) visualObject Property1: (NSString *) propertyName1 Property2: (NSString *) propertyName2;

- (void) setTransformFirebase;

- (void) setInitialNote: (NoteItem2 *) ni;

- (void) addNoteToViewWithHandlers:(NoteItem2 *) noteItem;

//- (void) removeValue: (id) object;

- (void) calculateTotalBounds: (UIView *) view;

- (void) constrainWidthToSuperview: (UIView *) subView;

- (void) centerScrollViewContents2;

- (void) expandBoundsTiledLayerView: (float) scale;

@end


