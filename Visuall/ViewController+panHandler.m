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
- (BOOL) panHandler: (UIPanGestureRecognizer *) gestureRecognizer
{
    if ( [self isDrawGroupButtonSelected] )  // isGroupHandle
    {
        
            [self drawGroup: gestureRecognizer];
            return NO;
        
    }
    
    
    UIView *viewHit = self.BoundsTiledLayerView.hitTestView;
    NSLog(@"panHandler viewHit %@", [viewHit class]);
    
//    if (!viewHit) return NO;  // Delegate pan gesture does NOT receive touch, therefore the gesture is passed to UIScrollView's native pan... in short NO --> YES pan background scrollview
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
//        if ( [self isDrawGroupButtonSelected] )  // isGroupHandle
//        {
//            if ( ([self.lastSelectedObject getGroupItem] == [self.activelySelectedObjectDuringPan getGroupItem])  && [viewHit isGroupHandle] )
//            {
//                GroupItem *gi = [self.activelySelectedObjectDuringPan getGroupItem];
//                [gi resizeGroup: gestureRecognizer];
//                [[StateUtil sharedManager] updateChildValue:gi Property:@"frame"];
//                return YES;
//            }
//            else {
//                [self drawGroup: gestureRecognizer];
//                return NO;
//            }
//        }

        if ( [self isPointerButtonSelected] && [self.activelySelectedObjectDuringPan isNoteItem])  // Pan a note
        {
            NoteItem2 *ni = [self.activelySelectedObjectDuringPan getNoteItem];
            [ni handlePan:gestureRecognizer];
            [[StateUtil sharedManager] updateChildValues: ni Property1:@"x" Property2:@"y"];
            return YES;
        } else if ([self isPointerButtonSelected] && [self.activelySelectedObjectDuringPan isGroupItem])  // Pan or resize a group
        {
            GroupItem *gi = [self.activelySelectedObjectDuringPan getGroupItem];
            if ( ([self.lastSelectedObject getGroupItem] == [self.activelySelectedObjectDuringPan getGroupItem])  && [gi isHandle: self.activelySelectedObjectDuringPan] )
            {
                [gi resizeGroup: gestureRecognizer];
                [[StateUtil sharedManager] updateChildValue:gi Property:@"frame"];
                return YES;
            } else
            {
                [self handlePanGroup: gestureRecognizer andGroupItem:gi];
                [[StateUtil sharedManager] updateChildValue:gi Property:@"frame"];
                return YES;
            }
        }
        else
        {
            CGPoint translation = [gestureRecognizer translationInView: self.BackgroundScrollView];  // amount translated in the NotesView, which is effectively the user's screen
            [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
            CGRect rect = self.BoundsTiledLayerView.frame;
            rect.origin.x = rect.origin.x + translation.x;
            rect.origin.y = rect.origin.y + translation.y;
            self.BoundsTiledLayerView.frame = rect;
        }
        
        return NO;  // --> YES pan the background

        // TODO:
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
//                [self removeValue:ni];
                [self.NotesCollection deleteNoteGivenKey: ni.note.key];
            } else if ([self.activelySelectedObjectDuringPan isKindOfClass:[GroupItem class]]) {
                GroupItem *gi = (GroupItem *)self.lastSelectedObject;
//                [self removeValue:gi];
                [self.groupsCollection deleteGroupGivenKey: gi.group.key];
            }
            [self.lastSelectedObject removeFromSuperview];
            self.lastSelectedObject = nil;
            [self normalizeTrashButton];
        }
        else if ( [self.activelySelectedObjectDuringPan isNoteItem] )
        {
            [self updateTotalBounds: self.activelySelectedObjectDuringPan];
        }
        else if ( [self.activelySelectedObjectDuringPan isGroupItem] )
        {
            GroupItem *gi = [self.activelySelectedObjectDuringPan getGroupItem];
            if ( [gi isHandle: self.activelySelectedObjectDuringPan] )
            {
                [self refreshGroupsView];  // TODO (Aug 10, 2016): Get this working again
                [gi setViewAsSelected];  // To re-render the handles  // TODO (Aug 10, 2016): animate this step for a smoother transition
            }
            [self updateTotalBounds: gi];
        }
        
        [self setActivelySelectedObjectDuringPan: nil];

    }
    return NO;
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



