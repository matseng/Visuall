//
//  ViewController+Group.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+Group.h"
#import "ViewController+Menus.h"
#import "StateUtil.h"

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
    return drawGroupView;
}

- (void) handlePanGroup: (UIPanGestureRecognizer *) gestureRecognizer andGroupItem: (GroupItem *) groupItem
{
    
    if (!groupItem) {
        groupItem = (GroupItem *) gestureRecognizer.view;
    }
    
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setSelectedObject:groupItem];
        NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
        NSMutableArray *groupsInGroup = [[NSMutableArray alloc]init];

        [[[StateUtil sharedManager] notesCollection] myForIn:^(NoteItem2 *ni)
         {
             if ( [groupItem isNoteInGroup:ni]) {
                 //                NSLog(@"Note name in group: %@", ni.note.title);
                 [notesInGroup addObject:ni];
             }

         }];

        [[[StateUtil sharedManager] groupsCollection] myForIn:^(GroupItem *gi)
        {
            if ([groupItem isGroupInGroup:gi]) {
                [groupsInGroup addObject:gi];
            }
        }];
         
        [groupItem setNotesInGroup: notesInGroup];
        [groupItem setGroupsInGroup:groupsInGroup];
    }
    else if ( gestureRecognizer.state == UIGestureRecognizerStateChanged )
    {
        [groupItem handlePanGroup2:gestureRecognizer];
        
        [[StateUtil sharedManager] updateChildValue:groupItem Property:@"frame"];
        
        for (NoteItem2 *ni in groupItem.notesInGroup)
        {
            [[StateUtil sharedManager] updateChildValues: ni Property1:@"x" Property2:@"y"];
        }
        for (GroupItem *gi in groupItem.groupsInGroup)
        {
            [[StateUtil sharedManager] updateChildValue:gi Property:@"frame"];
            
        }
        
    }
}

- (void) setItemsInGroup: (GroupItem *) groupItem
{
    NSMutableArray *notesInGroup = [[NSMutableArray alloc] init];
    NSMutableArray *groupsInGroup = [[NSMutableArray alloc]init];
    
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
    
    [groupItem setNotesInGroup: notesInGroup];
    [groupItem setGroupsInGroup:groupsInGroup];
}

- (void) refreshGroupView
{
    // Sort by area of group view
    NSArray *sortedArray;
    
    sortedArray = [self.groupsCollection.groups2 keysSortedByValueUsingComparator: ^(GroupItem *group1, GroupItem *group2) {
        
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
        float area = [self.groupsCollection getGroupAreaFromKey:key];
//        NSLog(@"Group area: %f", area);
        [self.groupsCollection.groups2[key] removeFromSuperview];
        [self.GroupsView addSubview:self.groupsCollection.groups2[key]];
    }
    
    [self.drawGroupView setFrame:(CGRect){0,0,0,0}];
    [self.drawGroupView removeFromSuperview];
    
}


@end
