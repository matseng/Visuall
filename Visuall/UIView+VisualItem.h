//
//  UIView+VisualItem.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/13/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteItem2.h"
#import "GroupItem.h"

@interface UIView (VisualItem)

- (BOOL) isNoteItem;

- (NoteItem2 *) getNoteItem;

- (BOOL) isGroupItem;

- (GroupItem *) getGroupItem;

@end
