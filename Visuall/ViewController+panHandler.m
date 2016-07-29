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
#import "StateUtil.h"
#import "ViewController+ViewHit.h"
#import "ViewController+Group.h"
#import "UIView+VisualItem.h"
#import "TiledLayerView.h"

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
    
    UIView *viewHit  = gestureRecognizer.view;
//    UIView *viewHit = ((TiledLayerView *) gestureRecognizer.view).hitTestView;
    if (!viewHit) return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if ( [viewHit isEqual: self.scrollViewButtonList] )
        {
            return;
        } else if ( [self isEditModeOn] && ([self isPointerButtonSelected] || [self isNoteButtonSelected]) && [viewHit isNoteItem] )
        {
            NoteItem2 *nv = [viewHit getNoteItem];
            [self setSelectedObject:nv];
            [self setActivelySelectedObjectDuringPan: nv];
            [nv handlePan:gestureRecognizer];
            [[self.view window] endEditing:YES];  // hide keyboard when dragging a note
            return;
        } else if ( [self isEditModeOn] && [self isPointerButtonSelected] && [viewHit isGroupItem])
        {
//            GroupItem  *gi = (GroupItem *) [viewHit superview];
//            if (viewHit.tag == 777)
            UIView *handleSelected = [[viewHit getGroupItem] hitTestOnHandles:gestureRecognizer];
            if ( handleSelected )
            {
                [self setSelectedObject:handleSelected];  // TODO, still should highlight current group
                [self setActivelySelectedObjectDuringPan: handleSelected];
                [[viewHit getGroupItem] setHandleSelected: handleSelected];
                return;
            } else if ([viewHit isInBoundsOfView:self.BackgroundScrollView])
            {
                GroupItem  *gi = [viewHit getGroupItem];
                [self setActivelySelectedObjectDuringPan: gi];
                [self setSelectedObject:gi];
                [self setItemsInGroup:gi];
            }
        }
//        else if ( [self isEditModeOn] && [self isPointerButtonSelected] && viewHit.tag == 777)
//        {
//            [self setSelectedObject:viewHit];  // TODO, still should highlight current group
//            [self setActivelySelectedObjectDuringPan: viewHit];
//        }
        else
        {
//
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if ([self isEditModeOn] && [self isPointerButtonSelected] &&
                    [self.lastSelectedObject isKindOfClass: [NoteItem2 class]] && self.activelySelectedObjectDuringPan)
        {
            NoteItem2 *ni = (NoteItem2 *) self.lastSelectedObject;
            [ni handlePan:gestureRecognizer];
            [self updateChildValues:ni Property1:@"x" Property2:@"y"];
        } else if ([self isEditModeOn] && [self isPointerButtonSelected] &&
                   [self.lastSelectedObject isKindOfClass:[GroupItem class]] && self.activelySelectedObjectDuringPan)
        {
            GroupItem *gi = (GroupItem *) self.lastSelectedObject;
            [self handlePanGroup: gestureRecognizer andGroupItem:gi];
            [self updateChildValues:gi Property1:@"x" Property2:@"y"];
        } else if ( [self isEditModeOn] && [self isPointerButtonSelected] &&
                   [self.lastSelectedObject isGroupItemSubview] && self.activelySelectedObjectDuringPan)
        {
            GroupItem *gi = (GroupItem *) [self.lastSelectedObject superview];
            [gi resizeGroup: gestureRecognizer];
            [self updateChildValues:gi Property1:@"width" Property2:@"height"];
            return;
        } else if ( ![viewHit isEqual: self.scrollViewButtonList] )
        {
//            [[TransformUtil sharedManager] handlePanBackground:gestureRecognizer withNotes: self.NotesCollection withGroups: self.groupsCollection];
        }
        if ( self.activelySelectedObjectDuringPan && [viewHit isEqual: self.scrollViewButtonList] )
        {
            float width = self.scrollViewButtonList.frame.size.width;
            float widthContent = self.scrollViewButtonList.contentSize.width;
            float newContentOffset = widthContent - width;
            NSLog(@"scrollViewButtonList width and content width: %f, %f", width, widthContent);
            
            if( ![[NSNumber numberWithFloat: self.scrollViewButtonList.contentOffset.x] isEqualToNumber:[NSNumber numberWithFloat: newContentOffset]] )
            {
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^(void) {
                                     [self.scrollViewButtonList setContentOffset:CGPointMake(newContentOffset, 0)];
                                 }
                                 completion:NULL];
            }
            if ( [self trashButtonHitTest: gestureRecognizer] )
            {
                [self highlightTrashButton];
            } else {
                [self normalizeTrashButton];
            }
        } else {
            [self normalizeTrashButton];
        }
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if ( [self trashButtonHitTest: gestureRecognizer] )
        {
            if ([self.activelySelectedObjectDuringPan isKindOfClass:[NoteItem2 class]]) {
                NoteItem2 *ni = (NoteItem2 *)self.lastSelectedObject;
                [self removeValue:ni];
                [self.NotesCollection deleteNoteGivenKey: ni.note.key];
            } else if ([self.activelySelectedObjectDuringPan isKindOfClass:[GroupItem class]]) {
                GroupItem *gi = (GroupItem *)self.lastSelectedObject;
                [self removeValue:gi];
                [self.groupsCollection deleteGroupGivenKey: gi.group.key];
            }
            [self.lastSelectedObject removeFromSuperview];
            self.lastSelectedObject = nil;
            [self normalizeTrashButton];
        }
        
        [self setActivelySelectedObjectDuringPan: nil];

        if ([viewHit isEqual:self.Background] || [viewHit isEqual: self.NotesView] || [viewHit isEqual: self.GroupsView])
        {
            [self setTransformFirebase];
        }
        
        if ([self.lastSelectedObject isGroupItemSubview])
        {
            [self refreshGroupView];
        }
    }
}

- (void) panHandlerForScrollViewButtonList: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (self.activelySelectedObjectDuringPan)
    {
        float width = self.scrollViewButtonList.frame.size.width;
        float widthContent = self.scrollViewButtonList.contentSize.width;
        NSLog(@"scrollViewButtonList width and content width: %f, %f", width, widthContent);
        
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             [self.scrollViewButtonList setContentOffset:CGPointMake(widthContent - width, 0)];
                         }
                         completion:NULL];

    }
}

@end


//if ( self.activelySelectedObjectDuringPan && [self.scrollViewButtonList hitTest:[gestureRecognizer locationInView: self.scrollViewButtonList] withEvent:NULL])
//{
//    float width = self.scrollViewButtonList.frame.size.width;
//    float widthContent = self.scrollViewButtonList.contentSize.width;
//    NSLog(@"scrollViewButtonList width and content width: %f, %f", width, widthContent);
//    
//    [UIView animateWithDuration:0.2
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^(void) {
//                         [self.scrollViewButtonList setContentOffset:CGPointMake(widthContent - width, 0)];
//                     }
//                     completion:NULL];
//    
//} else if ([self.scrollViewButtonList hitTest:[gestureRecognizer locationInView: self.scrollViewButtonList] withEvent:NULL])
//{
//    return nil;
//}


