//
//  ViewController+Group.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+Group.h"
#import "ViewController+Menus.h"
#import "StateUtilFirebase.h"
#import "UIView+VisualItem.h"
#import "UserUtil.h"
#import "ArrowItem.h"
#import "ShuttleView.h"

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0
#define SELECTED_VIEW_BORDER_COLOR [[UIColor blueColor] CGColor]
#define SELECTED_VIEW_BORDER_WIDTH 2.0

@implementation ViewController (Group)


- (UIView *) initializeDrawGroupView
{
    UIView *drawGroupView = [[UIView alloc] init];
    drawGroupView.backgroundColor = GROUP_VIEW_BACKGROUND_COLOR;
    drawGroupView.layer.borderColor = GROUP_VIEW_BORDER_COLOR;
    drawGroupView.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
    drawGroupView.alpha = 0.2;
    return drawGroupView;
}

- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (groupItem.sv) [groupItem.sv removeFromSuperview];
        groupItem.sv = [[ShuttleView alloc] init];
//        groupItem.sv.backgroundColor = [UIColor orangeColor];
        FDDrawView *DrawViewTemp = [[FDDrawView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [groupItem.sv addSubview: DrawViewTemp];
        groupItem.pathsInGroup = [[NSMutableArray alloc] init];
        [[[[UserUtil sharedManager] getState] VisualItemsView] addSubview: groupItem.sv];
        
        [self setSelectedObject:groupItem];
        
        [[self.visuallState notesCollection] myForIn:^(NoteItem2 *ni)
         {
             if ( [groupItem isNoteInGroup:ni]) {
                 [groupItem.sv addSubview: ni];
             }
         }];
        
        [[self.visuallState groupsCollection] myForIn:^(GroupItem *gi)
         {
             if ( [groupItem isGroupInGroup: gi]) {
                 [groupItem.sv addSubview: gi];
             }
         }];
        
        [[[[UserUtil sharedManager] getState] arrowsCollection] myForIn:^(ArrowItem *ai){
            if ([groupItem isArrowInGroup: ai]) {
                [groupItem.sv addSubview: ai];
            }
        }];
        
        [[[[UserUtil sharedManager] getState] pathsCollection] myForIn:^(PathItem *pi) {
            if ([groupItem isPathInGroup: pi]) {
//                [DrawViewTemp drawPathItemOnShapeLayer: pi];
                [DrawViewTemp.layer addSublayer: pi];
                [groupItem.pathsInGroup addObject: pi];
            }
        }];
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
//        [groupItem handlePanGroup2: gestureRecognizer];
        CGPoint translation = [gestureRecognizer translationInView: groupItem];
        [gestureRecognizer setTranslation: CGPointZero inView:gestureRecognizer.view];
        
        float x = groupItem.group.x + translation.x;
        float y = groupItem.group.y + translation.y;
        [groupItem.group setX: x];
        [groupItem.group setY: y];
        [groupItem updateFrame];
        
        [groupItem.sv setFrame: CGRectMake(groupItem.sv.frame.origin.x + translation.x,
                                           groupItem.sv.frame.origin.y + translation.y,
                                           1,
                                           1)];
    }
    
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        for (UIView *uv in groupItem.sv.subviews)
        {
            if ( [uv isNoteItem] )
            {
                NoteItem2 *ni = [uv getNoteItem];
                ni.frame = CGRectMake(ni.frame.origin.x + groupItem.sv.frame.origin.x,
                                      ni.frame.origin.y + groupItem.sv.frame.origin.y,
                                      ni.frame.size.width,
                                      ni.frame.size.height);
                ni.note.x = ni.frame.origin.x;
                ni.note.y = ni.frame.origin.y;
                [[[[UserUtil sharedManager] getState] NotesView] addSubview: ni];
                [self.visuallState updateChildValue: ni Property: nil];
            }
            
            else if ( [uv isGroupItem] )
            {
                GroupItem *gi = [uv getGroupItem];
                gi.frame = CGRectMake(gi.frame.origin.x + groupItem.sv.frame.origin.x,
                                      gi.frame.origin.y + groupItem.sv.frame.origin.y,
                                      gi.frame.size.width,
                                      gi.frame.size.height);
                gi.group.x = gi.frame.origin.x;
                gi.group.y = gi.frame.origin.y;
                [[[[UserUtil sharedManager] getState] GroupsView] addSubview: gi];
                [self.visuallState updateChildValue: gi Property:@"frame"];
            }

            else if ( [uv isArrowItem] )
            {
                ArrowItem *ai = [uv getArrowItem];
                [ai translateArrowByDelta: groupItem.sv.frame.origin];
                [[[[UserUtil sharedManager] getState] ArrowsView] addSubview: ai];
                [self.visuallState updateChildValue: ai Property: nil];
            }
            
            else if ( [uv isDrawView] )
            {
                FDDrawView *dv = [uv getDrawView];
                for (PathItem *pi in groupItem.pathsInGroup)
                {
                    [dv translatePath: pi byPoint: groupItem.sv.frame.origin];
                    [pi drawPathOnSelf];
                    [[[[[UserUtil sharedManager] getState] DrawView] layer] addSublayer: pi];
                    [self.visuallState updateValuePath: pi];
                }
                [groupItem.pathsInGroup removeAllObjects];
            }
        };
    }
    
}

- (void) __handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem
{
    
    if (!groupItem) {
        groupItem = (GroupItem *) gestureRecognizer.view;
    }
    
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setSelectedObject:groupItem];
        NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
        NSMutableArray *groupsInGroup = [[NSMutableArray alloc] init];
        NSMutableArray *arrowsInGroup = [[NSMutableArray alloc] init];
        NSMutableArray *pathsInGroup = [[NSMutableArray alloc] init];

        [[self.visuallState notesCollection] myForIn:^(NoteItem2 *ni)
        {
             if ( [groupItem isNoteInGroup:ni]) {
                 [notesInGroup addObject:ni];
             }

         }];

        [[self.visuallState groupsCollection] myForIn:^(GroupItem *gi)
        {
            if ([groupItem isGroupInGroup:gi]) {
                [groupsInGroup addObject:gi];
            }
        }];
        
        [[[[UserUtil sharedManager] getState] arrowsCollection] myForIn:^(ArrowItem *ai){
            if ([groupItem isArrowInGroup: ai]) {
                [arrowsInGroup addObject:ai];
            }
        }];
        
        [[[[UserUtil sharedManager] getState] pathsCollection] myForIn:^(PathItem *pi) {
            if ([groupItem isPathInGroup: pi]) {
                [pathsInGroup addObject: pi];
            }
        }];
        
        [groupItem setNotesInGroup: notesInGroup];
        [groupItem setGroupsInGroup: groupsInGroup];
        [groupItem setArrowsInGroup: arrowsInGroup];
        [groupItem setPathsInGroup: pathsInGroup];
    }
    else if ( gestureRecognizer.state == UIGestureRecognizerStateChanged )
    {
        [groupItem handlePanGroup2: gestureRecognizer];
        
        [self.visuallState updateChildValue:groupItem Property:@"frame"];
        
        for (NoteItem2 *ni in groupItem.notesInGroup)
        {
            [self.visuallState updateChildValue: ni Property: nil];
        }

        for (GroupItem *gi in groupItem.groupsInGroup)
        {
            [self.visuallState updateChildValue:gi Property:@"frame"];
        }
        
        for (ArrowItem *ai in groupItem.arrowsInGroup)
        {
            [self.visuallState updateChildValue: ai Property:nil];
        }
        
        for (PathItem *pi in groupItem.pathsInGroup)
        {
            [self.visuallState updateValuePath: pi];
        }
        
    }
}

/*
- (void) setItemsInGroup: (GroupItem *) groupItem
{
    NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
    NSMutableArray *groupsInGroup = [[NSMutableArray alloc] init];
    NSMutableArray *arrowsInGroup = [[NSMutableArray alloc] init];
    
    //    for (NoteItem *ni in self.NotesCollection.Notes) {
    //        if ([groupItem isNoteInGroup:ni]) {
    //            //                NSLog(@"Note name in group: %@", ni.note.title);
    //            [notesInGroup addObject:ni];
    //        }
    //    }
    //    for (GroupItem *gi in self.groupsCollection.groups) {
    //        if ([groupItem isGroupInGroup:gi]) {
    //            [groupsInGroup addObject:gi];
    //        }
    //    }
    [self.NotesCollection myForIn:^(NoteItem2 *ni)
     {
         if ([groupItem isNoteInGroup:ni]) {
             [notesInGroup addObject:ni];
         }
     }];
    
    [self.groupsCollection myForIn:^(GroupItem *gi){
        if ([groupItem isGroupInGroup:gi]) {
            [groupsInGroup addObject:gi];
        }
    }];

    [[[[UserUtil sharedManager] getState] arrowsCollection] myForIn:^(ArrowItem *ai){
        if ([groupItem isArrowInGroup: ai]) {
            [arrowsInGroup addObject:ai];
        }
    }];
    
    [groupItem setNotesInGroup: notesInGroup];
    [groupItem setGroupsInGroup:groupsInGroup];
    [groupItem setArrowsInGroup: arrowsInGroup];
}
 */


/*
 * Name: refreshGroupsView
 * Description: Brute force method for sorting all the groups in GroupsView so that groups are ordered largest (back) and smallest (front)
 */
- (void) refreshGroupsView
{
    // Sort by area of group view
    NSArray *sortedArray = [self.visuallState.groupsCollection.items keysSortedByValueUsingComparator: ^(GroupItem *group1, GroupItem *group2) {
        
        float firstArea = group1.group.width * group1.group.height;
        float secondArea = group2.group.width * group2.group.height;
        
        if ( firstArea > secondArea ) {
            
            return (NSComparisonResult) NSOrderedAscending;
        }
        if ( firstArea < secondArea ) {
            
            return (NSComparisonResult) NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (NSString *key in sortedArray) {
        float area = [self.visuallState.groupsCollection getGroupAreaFromKey:key];
//        NSLog(@"Group area: %f", area);
//        [self.groupsCollection.groups2[key] removeFromSuperview];
//        [self.GroupsView addSubview:self.groupsCollection.groups2[key]];
        GroupItem *gi = [self.visuallState.groupsCollection getGroupItemFromKey:key];
        [self.GroupsView bringSubviewToFront: gi];
    }
}

- (void) drawGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
    {
        GroupItem *gi = [self.visuallState.selectedVisualItemDuringPan getGroupItem];
        
        // Resize group by dragging its handle
        if ( ([self.visuallState.selectedVisualItem getGroupItem] == [self.visuallState.selectedVisualItemDuringPan getGroupItem])
            && [gi isHandle: self.visuallState.selectedVisualItemDuringPan] )
        {
            if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
            {
                
                [gi resizeGroup: gestureRecognizer];
                [self.visuallState updateChildValue:gi Property:@"frame"];
            }
            else
            {
                [self.visuallState setSelectedVisualItemDuringPan: nil];
            }
            return;
        }
        
        
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
            // TODO (Aug 11, 2016): && we're not starting on another group's handle
        {
            self.drawGroupViewStart = self.visuallState.touchDownPoint; // determined from handleTouchDown method for more precise start locationdd
            [self.drawGroupView setFrame:(CGRect){0,0,1,1}];
            [self.GroupsView addSubview: self.drawGroupView];
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
        }
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
        }
        
        // State ended
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
            GroupItem *currentGroupItem = [[GroupItem alloc] initWithRect: self.drawGroupView.frame];
            [self addGroupItemToMVC: currentGroupItem];
            [self.drawGroupView removeFromSuperview];
        }
    }
}

- (void) addGroupItemToMVC: (GroupItem *) currentGroupItem
{
    [self.visuallState setValueGroup: currentGroupItem];
    [self.GroupsView addSubview: currentGroupItem];
    if ( !self.visuallState.groupsCollection ) self.visuallState.groupsCollection = [GroupsCollection new];
    [self.visuallState.groupsCollection addGroup:currentGroupItem withKey:currentGroupItem.group.key];
    [self refreshGroupsView];
    [self.visuallState setSelectedVisualItemDuringPan: nil];
    [self setSelectedObject: currentGroupItem];
}

- (CGRect) createGroupViewRect:(CGPoint)start withEnd:(CGPoint)end {
    float x1 = start.x < end.x ? start.x : end.x;
    float y1 = start.y < end.y ? start.y : end.y;
    
    float x2 = start.x < end.x ? end.x : start.x;
    float y2 = start.y < end.y ? end.y : start.y;
    
    float width = x2 - x1;
    float height = y2 - y1;
    
    return CGRectMake(x1, y1, width, height);
}

@end
