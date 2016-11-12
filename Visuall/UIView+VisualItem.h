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
#import "GroupItemImage.h"
#import "ArrowItem.h"
#import "FDDrawView.h"
#import "PathItem.h"

@interface UIView (VisualItem)

-(void)setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius;

- (BOOL) isNoteItem;

- (NoteItem2 *) getNoteItem;

- (BOOL) isGroupItem;

- (GroupItem *) getGroupItem;

- (BOOL) isArrowItem;

- (ArrowItem *) getArrowItem;

- (BOOL) isPathItem;

- (PathItem *) getPathItem;

- (BOOL) isInBoundsOfView: (UIView *) parentView;

- (BOOL) isPartiallyInBoundsOfView: (UIView *) parentView;

- (BOOL) isGroupItemSubview;

- (BOOL) isGroupHandle;

- (BOOL) isImage;

- (GroupItemImage *) getGroupItemImage;

- (UIViewController *) firstAvailableUIViewController;

- (id) traverseResponderChainForUIViewController;

@end
