//
//  ViewController+Group.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (Group) <GroupsController>

- (UIView *) initializeDrawGroupView;

- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem;

- (void) setItemsInGroup: (GroupItem *) groupItem;

- (void) refreshGroupsView;

@end

