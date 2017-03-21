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
#import "StateUtilFirebase.h"
#import "ViewController+ViewHit.h"
#import "ViewController+Group.h"
#import "ViewController+Arrow.h"
#import "UIView+VisualItem.h"
#import "TiledLayerView.h"
#import "ArrowItem.h"
#import "UserUtil.h"
#import "FDDrawView.h"

@implementation ViewController (panHandler)

/*
 * Name: panHandler
 * @param {type}
 * @return {type}
 * Notes:
 */
- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer
{
    UIView *viewHit = self.BoundsTiledLayerView.hitTestView;
    if ( [self isDrawGroupButtonSelected] )  // isGroupHandle
    {
        [self drawGroup: gestureRecognizer];
        return;
    } else if ([self isArrowButtonSelected]
               && ![[viewHit getArrowItem] isEqual:[self.visuallState.selectedVisualItem getArrowItem]] ) // Allow draw arrow if not
    {
        [self panHandlerForDrawArrow: gestureRecognizer];
        return;
    } else if (  [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
    {
        [[[[UserUtil sharedManager] getState] DrawView] panHandler: gestureRecognizer];
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan
        || gestureRecognizer.state == UIGestureRecognizerStateChanged
        || gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {

        if ( ([self isPointerButtonSelected] || [self isNoteButtonSelected])
            && [self.visuallState.selectedVisualItemDuringPan isNoteItem])  // Pan a note
        {
            NoteItem2 *ni = [self.visuallState.selectedVisualItemDuringPan getNoteItem];
            [self setSelectedObject:ni];
            [ni handlePan:gestureRecognizer];
//            [self.visuallState updateChildValues: ni Property1:@"x" Property2:@"y"];  // save note coordinates
            [self.visuallState updateChildValue: ni Property: nil];  // save note coordinates
            for (ArrowItem *ai in ni.arrowTailsInGroup)
            {
                [[[UserUtil sharedManager] getState] updateChildValue: ai Property: nil];  // save arrow tail(s) position
            }
            
            for (ArrowItem *ai in ni.arrowHeadsInGroup)
            {
                [[[UserUtil sharedManager] getState] updateChildValue: ai Property: nil];  // save arrow heads(s) position
            }
            return;
        }
        else if ([self isPointerButtonSelected]
                 && [self.visuallState.selectedVisualItemDuringPan isGroupItem]
                 && ([self.visuallState.selectedVisualItem getGroupItem] == [self.visuallState.selectedVisualItemDuringPan getGroupItem]) )  // Pan or resize a group
        {
            GroupItem *gi = [self.visuallState.selectedVisualItemDuringPan getGroupItem];
            if ( [gi isHandle: self.visuallState.selectedVisualItemDuringPan] )
            {
                [gi resizeGroup: gestureRecognizer];
                [self.visuallState updateChildValue:gi Property:@"frame"];
            } else
            {
                [self handlePanGroup: gestureRecognizer andGroupItem:gi];
                [self.visuallState updateChildValue:gi Property:@"frame"];
            }
            return;
        }
        else if ( ([self isPointerButtonSelected] || [self isArrowButtonSelected])
                 && ([self.visuallState.selectedVisualItemDuringPan getArrowItem])
                 && ([self.visuallState.selectedVisualItem getArrowItem] == [self.visuallState.selectedVisualItemDuringPan getArrowItem]))
        {
            ArrowItem *ai = [self.visuallState.selectedVisualItemDuringPan getArrowItem];
            if ( ![ai isHandle: self.visuallState.selectedVisualItemDuringPan] )
            {
                [self setSelectedObject: ai];
            }
            [ai handlePan: gestureRecognizer];
            [self.visuallState updateChildValue: ai Property: nil];
            return;
        }
        else if ( [self isPointerButtonSelected] && [self.visuallState.selectedVisualItem isDrawView] )
        {
            if ( [self.visuallState.DrawView selectedPath] == [self.visuallState.DrawView hitTestPath] )
            {
                PathItem *pi = [self.visuallState.selectedVisualItemDuringPan getPathItem];
                NSLog(@"\n Should drag path here"); // TODO (Jan 31, 2017):
                [self.visuallState.DrawView panHandler: gestureRecognizer withPathItem: pi];
                return;
            }
        }
        else
        {
            CGPoint translation = [gestureRecognizer translationInView: self.BackgroundScrollView];
            [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
            CGRect rect = self.BoundsTiledLayerView.frame;
            rect.origin.x = rect.origin.x + translation.x;
            rect.origin.y = rect.origin.y + translation.y;
            self.BoundsTiledLayerView.frame = rect;
        }
        
        return;  // --> YES pan the background

        // TODO:
        if ( self.visuallState.selectedVisualItemDuringPan && [viewHit isEqual: self.scrollViewButtonList] )
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
            if ([self.visuallState.selectedVisualItemDuringPan isKindOfClass:[NoteItem2 class]]) {
                NoteItem2 *ni = (NoteItem2 *)self.visuallState.selectedVisualItem;
//                [self removeValue:ni];
                [self.visuallState.notesCollection deleteNoteGivenKey: ni.note.key];
            } else if ([self.visuallState.selectedVisualItemDuringPan isKindOfClass:[GroupItem class]]) {
                GroupItem *gi = (GroupItem *)self.visuallState.selectedVisualItem;
//                [self removeValue:gi];
                [self.visuallState.groupsCollection deleteGroupGivenKey: gi.group.key];
            }
            [self.visuallState.selectedVisualItem removeFromSuperview];
            self.visuallState.selectedVisualItem = nil;
            [self normalizeTrashButton];
        }
        else if ( [self.visuallState.selectedVisualItemDuringPan isNoteItem] )
        {
            [self calculateTotalBounds: self.visuallState.selectedVisualItemDuringPan];
        }
        else if ( [self.visuallState.selectedVisualItemDuringPan isGroupItem] )
        {
            GroupItem *gi = [self.visuallState.selectedVisualItemDuringPan getGroupItem];
            if ( [gi isHandle: self.visuallState.selectedVisualItemDuringPan] )
            {
                [self refreshGroupsView];  // TODO (Aug 10, 2016): Get this working again
                [gi setViewAsSelectedForEditModeOn:[self.visuallState editModeOn] andZoomScale:[self.visuallState getZoomScale]];  // To re-render the handles  // TODO (Aug 10, 2016): animate this step for a smoother transition
            }
            [self calculateTotalBounds: gi];
//            [self centerScrollViewContents2];
            [self expandBoundsTiledLayerView: 1.75];  // Adds 1.75 screen widths to the self.BackgroundScrollView
        }
        
        [self.visuallState setSelectedVisualItemDuringPan: nil];

    }
    return;
}

- (void) panHandlerForScrollViewButtonList: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (self.visuallState.selectedVisualItemDuringPan)
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



