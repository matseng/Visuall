//
//  GroupItem.h
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "NoteItem2.h"
#import "Group2.h"
#import "ArrowItem.h"
#import "PathItem.h"
//#import "VisualItem.h"

//@interface GroupItem : UIView

@interface GroupItem : VisualItem

//+ (StateUtilFirebase) *visuallState;

@property Group2 *group;
//@property Group *group2;

@property (strong) NSMutableArray *notesInGroup;

@property (strong) NSMutableArray *groupsInGroup;

@property (strong) NSMutableArray *arrowsInGroup;

@property (strong) NSMutableArray *pathsInGroup;

@property UIView *innerGroupView;

@property UIView *handleSelected;

//- (instancetype) initGroup:(Group *)group;

- (instancetype) initGroup: (NSString *) key andValue: (NSDictionary *) value;

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height;

- (void) updateGroupItem: (NSString *) key andValue: (NSDictionary *) value;

- (GroupItem *) initWithRect: (CGRect) rect;

- (void) handlePanGroup2: (UIPanGestureRecognizer *) gestureRecognizer;

- (BOOL) isNoteInGroup: (NoteItem2 *) noteItem;

- (void) saveToCoreData;

- (BOOL) isGroupInGroup: (GroupItem *) gi;

- (BOOL) isArrowInGroup: (ArrowItem *) ai;

- (BOOL) isPathInGroup: (PathItem *) pi;

- (void) resizeGroup: (UIPanGestureRecognizer *) gestureRecognizer;

- (float) getRadius;

- (float) getWidth;

- (float) getArea;

- (CGPoint) getCenterPoint;

- (UIView *) hitTestOnHandles: (UIGestureRecognizer *) gestureRecognizer;

- (void) setViewAsSelected;

- (void) setViewAsSelectedForEditModeOn: (BOOL) editModeOn andZoomScale: (float) zoomScale;

- (void) setViewAsNotSelected;

- (BOOL) isHandle: (UIView *) subView;

- (void) renderGroup;

- (void) updateFrame;

- (UIView *) hitTestIncludingHandles: (CGPoint) point;

@end
