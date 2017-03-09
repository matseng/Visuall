//
//  ViewController+TapHandler.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+TapHandler.h"
#import "ViewController+ViewHit.h"
#import "ViewController+Menus.h"
#import "StateUtilFirebase.h"
#import "UIView+VisualItem.h"
#import "ArrowItem.h"
#import "UIBezierPath+arrowhead.h"
#import "ViewController+Group.h"
#import "UserUtil.h"
#import "FDDrawView.h"

@implementation ViewController (TapHandler)

NoteItem2 *sourceNoteForArrow;
NoteItem2 *targetNoteForArrow;

/*
 Handle tap gesture on background AND other objects especially Groups (and Notes?)
 TODO: refactor as a hard coded gesture recognizer for the background
 */

- (void) tapHandler:(UITapGestureRecognizer *) gestureRecognizer
{
    UIView *viewHit = self.BoundsTiledLayerView.hitTestView;
    
    if (  [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
    {
        [[[[UserUtil sharedManager] getState] DrawView] tapHandler: gestureRecognizer];
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [gestureRecognizer locationInView: self.BoundsTiledLayerView];
        UIView *viewHit = [self.BoundsTiledLayerView hitTest:point withEvent:nil];
        NSLog(@"tapHandler viewHit %@", [viewHit class]);
        
        if ( [viewHit isNoteItem] )
        {
            NoteItem2 *ni = [viewHit getNoteItem];
            [self setSelectedObject:ni];
            //                NSLog(@"Is a title note?: %@", ni.note.isTitleOfParentGroup ? @"YES" : @"NO");
            //                return;
            [ni.noteTextView becomeFirstResponder];
        }
        //            else if ( [viewHit isGroupItem] )
        //            {
        //                GroupItem *gi = [viewHit getGroupItem];
        //                NoteItem2 *ni = [self.visuallState.notesCollection getNoteItemFromKey: gi.group.titleNoteKey];
        //                NSLog(@"Group title: %@", ni.note.title);
        //                NSLog(@"Group key: %@", [gi.group key]);
        //
        //            }
        //            else if ( [viewHit isArrowItem] )
        //            {
        //                ArrowItem *ai = [viewHit getArrowItem];
        //                [ai setViewAsSelected];
        //            }
        
        if ( [self isNoteButtonSelected] && ![viewHit isNoteItem])
        {
            CGPoint point = [gestureRecognizer locationInView: self.NotesView];
            NoteItem2 *newNote = [[NoteItem2 alloc] initNote:@"text..." withPoint:point];
            [self.visuallState setValueNote: newNote];  // TODO: add a callback to indicate if the note was sync'd successfully
            [self addNoteToViewWithHandlers:newNote];
            [self setSelectedObject:newNote];
            [newNote becomeFirstResponder];  // puts cursor on text field
            [newNote.noteTextView selectAll:nil];  // selects all text
//            [self updateTotalBounds: newNote];
            int count =  (int) self.visuallState.notesCollection.items.count;
            NSLog(@"\n tapHandler, notes collection count: %i", count);
            return;
        }
        else
        {
            [self setSelectedObject: viewHit];
        }
    }
}

/*
 * Name: isZoomedOut
 * Description:
 */
- (BOOL) isZoomedOut
{
    CGRect rect = [self.visuallState selectedVisualItem].frame;
    rect = [self.BackgroundScrollView convertRect: rect fromView:self.VisualItemsView];
    if (rect.size.width < self.BackgroundScrollView.frame.size.width
        && rect.size.height < self.BackgroundScrollView.frame.size.height)
    {
        return YES;
    }
    return NO;
}


/*
 * Name: doubleTapHandler
 * Description: (1) Zoom in by 2x or (2) Zoom directly to Group or Note
 * Use variable to keep track of most recent double-tap target
 */
- (void) doubleTapHandler:(UITapGestureRecognizer *) gesture
{
 
    NSLog(@"\n HERE doubleTapHandler");
    float zoomFactor = 3;
    if (gesture.numberOfTouches == 1)
    {
        if( [self.visuallState selectedVisualItem]
           && !( [[self.visuallState selectedVisualItem] isDrawView] )
           && [self isZoomedOut] )
        {
            CGRect rect = [self.visuallState selectedVisualItem].frame;
            rect = [self.BoundsTiledLayerView convertRect: rect fromView:self.VisualItemsView];
            [self.BackgroundScrollView zoomToRect:rect animated:YES];
            self.BackgroundScrollView.isZoomedToRect = YES;
            self.BackgroundScrollView.doubleTapFocus = self.visuallState.selectedVisualItem;
            
        }
        else
        {
            CGPoint centerPoint = [gesture locationInView: self.BoundsTiledLayerView];
            CGRect rect = [self.BoundsTiledLayerView convertRect: self.BackgroundScrollView.frame fromView: self.BackgroundScrollView];
            rect = CGRectMake( centerPoint.x - rect.size.width / (2 * zoomFactor),
                              centerPoint.y - rect.size.height / (2 * zoomFactor),
                                     rect.size.width / zoomFactor,
                                     rect.size.height / zoomFactor);
            
            [self.BackgroundScrollView zoomToRect:rect animated:YES];
        }
    }
    else if (gesture.numberOfTouches == 2)
    {
        // Two finger double tap --> zoom out by zoomFactor
        CGFloat scale = self.BackgroundScrollView.zoomScale;
        [self.BackgroundScrollView setZoomScale: scale / zoomFactor animated:YES];
    }
}

@end
