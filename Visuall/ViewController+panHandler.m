//
//  ViewController+panHandler.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+panHandler.h"
#import "ViewController+Menus.h"
#import "NoteItem2.h"
#import "GroupItem.h"
#import "TransformUtil.h"
#import "ViewController+ViewHit.h"
#import "ViewController+Group.h"

@implementation ViewController (panHandler)

/*
 * Name: panHandler
 * @param {type}
 * @return {type}
 * Notes:
 */
- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer
{
    if ( [self isDrawGroupButtonSelected] )
    {
        [self drawGroup: gestureRecognizer];
        return;
    }
    
    UIView *viewHit  = [self getViewHit:gestureRecognizer];
    if (!viewHit) return;  // e.g. if viewHit is scrollViewButtonList then return
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if ( [viewHit isKindOfClass: [NoteItem2 class]] ) {
            NoteItem2 *nv = (NoteItem2 *) viewHit;
            [self setSelectedObject:nv];
            [nv handlePan:gestureRecognizer];
            [[self.view window] endEditing:YES];  // hide keyboard when dragging a note
            return;
        } else if ( viewHit.tag == 100)
        {
            GroupItem  *gi = (GroupItem *) [viewHit superview];
            [self setSelectedObject:gi];
            [self setItemsInGroup:gi];
        } else if ( viewHit.tag == 777)
        {
            [self setSelectedObject:viewHit];  // TODO, still should highlight current group
        } else
        {
            [self setSelectedObject:nil];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if ([self.lastSelectedObject isKindOfClass: [NoteItem2 class]] && [self isEditModeOn])
        {
            NoteItem2 *ni = (NoteItem2 *) self.lastSelectedObject;
            [ni handlePan:gestureRecognizer];
            [self updateChildValues:ni Property1:@"x" Property2:@"y"];
        } else if ([self.lastSelectedObject isKindOfClass:[GroupItem class]] && [self isEditModeOn])
        {
            GroupItem *gi = (GroupItem *) self.lastSelectedObject;
            [self handlePanGroup: gestureRecognizer andGroupItem:gi];
            [self updateChildValues:gi Property1:@"x" Property2:@"y"];
        } else if ( self.lastSelectedObject.tag == 777)
        {
            GroupItem *gi = (GroupItem *) [self.lastSelectedObject superview];
            [gi resizeGroup: gestureRecognizer];
            [self refreshGroupView];
            [self updateChildValues:gi Property1:@"width" Property2:@"height"];
        } else
        {
            [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection withGroups: self.groupsCollection];
            
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if ([viewHit isEqual:self.Background] || [viewHit isEqual: self.NotesView] || [viewHit isEqual: self.GroupsView])
        {
            [self setTransformFirebase];
        }
    }
}

@end
