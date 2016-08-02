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
    if ( [self isDrawGroupButtonSelected] )
    {
        [self drawGroup: gestureRecognizer];
        return NO;
    }
    
    UIView *viewHit = self.BoundsTiledLayerView.hitTestView;
    NSLog(@"panHandler viewHit %@", [viewHit class]);
    
//    if (!viewHit) return NO;  // Delegate pan gesture does NOT receive touch, therefore the gesture is passed to UIScrollView's native pan... in short NO --> YES pan background scrollview
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    
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
        } else if ( ![viewHit isEqual: self.scrollViewButtonList] )
        {
            return YES;
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
        return NO;
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



