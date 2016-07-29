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

@interface GroupItem : UIView

@property Group2 *group;
//@property Group *group2;

@property (strong) NSMutableArray *notesInGroup;

@property (strong) NSMutableArray *groupsInGroup;

@property UIView *handleSelected;

//- (instancetype) initGroup:(Group *)group;

- (instancetype) initGroup: (NSString *) key andValue: (NSDictionary *) value;

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height;

- (void) handlePanGroup2: (UIPanGestureRecognizer *) gestureRecognizer;

- (BOOL) isNoteInGroup: (NoteItem2 *) noteItem;

- (void) saveToCoreData;

- (BOOL) isGroupInGroup: (GroupItem *) gi;

- (void) resizeGroup: (UIPanGestureRecognizer *) gestureRecognizer;

- (float) getRadius;

- (float) getArea;

- (CGPoint) getCenterPoint;

- (UIView *) hitTestOnHandles: (UIGestureRecognizer *) gestureRecognizer;

- (void) setViewAsSelected;

- (void) setViewAsNotSelected;

@end
