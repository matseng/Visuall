//
//  ViewController+Group.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (Group)

- (UIView *) initializeDrawGroupView;

- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem;

- (void) setItemsInGroup: (GroupItem *) groupItem;

@end