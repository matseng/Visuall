//
//  GroupItem.h
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "NoteItem.h"

@interface GroupItem : UIView

@property Group *group;

@property (strong) NSMutableArray *notesInGroup;

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height;

- (void) handlePanGroup2: (UIPanGestureRecognizer *) gestureRecognizer;

- (BOOL) isNoteInGroup: (NoteItem *) noteItem;

@end