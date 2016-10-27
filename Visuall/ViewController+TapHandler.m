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
            return;
        }
        else
        {
            [self setSelectedObject: viewHit];
        }
    }
}

- (void) doubleTapHandler:(UITapGestureRecognizer *) gesture
{
    NSLog(@"\n HERE doubleTapHandler");
    if (gesture.numberOfTouches == 1)
    {
        if([self.visuallState selectedVisualItem])
        {
            // Double tap visual item --> zoom to rect of a visual item
            CGRect rect = [self.visuallState selectedVisualItem].frame;
            rect = [self.BoundsTiledLayerView convertRect: rect fromView:self.VisualItemsView];
            [self.BackgroundScrollView zoomToRect:rect animated:YES];
        }
        else
        {
            // Double tap background --> zoom in by a factor of 2
            CGFloat scale = self.BackgroundScrollView.zoomScale;
            [self.BackgroundScrollView setZoomScale: scale * 2 animated:YES];
        }
    }
    else if (gesture.numberOfTouches == 2)
    {
        // Two finger double tap --> zoom out by a factor of 2
        CGFloat scale = self.BackgroundScrollView.zoomScale;
        [self.BackgroundScrollView setZoomScale: scale / 2 animated:YES];
    }
}

@end
