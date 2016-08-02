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
#import "StateUtil.h"
#import "UIView+VisualItem.h"
#import "ArrowItem.h"
#import "UIBezierPath+arrowhead.h"
#import "ViewController+Group.h"

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
    NSLog(@"panHandler viewHit %@", [viewHit class]);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            
            //        NSLog(@"tapHandler called HERE");
            
            //        UIView *viewHit = gestureRecognizer.view;
            CGPoint point = [gestureRecognizer locationInView: self.BoundsTiledLayerView];
            UIView *viewHit = [self.BoundsTiledLayerView hitTest:point withEvent:nil];
            NSLog(@"tapHandler viewHit %@", [viewHit class]);
            //        NSLog(@"tag %ld", (long)viewHit.tag);
            //        NSLog(@"gestureRecognizer %@", [gestureRecognizer.view class]);
            
            if ( [viewHit isNoteItem] )
            {
                NoteItem2 *ni = [viewHit getNoteItem];
                [self setSelectedObject:ni];
                
                if ( [self isArrowButtonSelected] )
                {
                    if ( !sourceNoteForArrow )
                    {
                        sourceNoteForArrow = ni;
                    } else {
                        // init arrow, draw arrow view, save arrow to firebase and get key, cross-share note and arrow keys
                        ArrowItem *ai = [[ArrowItem alloc] initArrowWithSourceNoteItem:sourceNoteForArrow andTargetNoteItem: ni];
                        [self.ArrowsView addSubview: ai];
                        sourceNoteForArrow = nil;
                    }
                    
                }
                //            NSLog(@"Note key: %@", ni.note.key);
                //            NSLog(@"Parent group key: %@", ni.note.parentGroupKey);
                //            NSLog(@"Is a title note?: %@", ni.note.isTitleOfParentGroup ? @"YES" : @"NO");
                //            NSLog(@"Note width: %f", ni.frame.size.width);
                return;
            } else {
                sourceNoteForArrow = nil;
            }
            
            if ( [self isNoteButtonSelected] ) {  // new note button  //- (BOOL) isNoteButtonSelected
                CGPoint point = [gestureRecognizer locationInView: self.NotesView];
                NoteItem2 *newNote = [[NoteItem2 alloc] initNote:@"text..." withPoint:point];
                [[StateUtil sharedManager] setValueNote: newNote];
                [self.NotesCollection addNote:newNote withKey:newNote.note.key];  // TODO: set key after saving to firebase
                [self addNoteToViewWithHandlers:newNote];
                [self setSelectedObject:newNote];
                [newNote becomeFirstResponder];  // puts cursor on text field
                [newNote.noteTextView selectAll:nil];  // highlights text
            } else
            {
                [self setSelectedObject: viewHit];
                //            if ([viewHit isKindOfClass: [GroupItem class]])
                if (viewHit.tag == 100)
                {
                    GroupItem *gi = (GroupItem *) [viewHit superview];
                    NSString *titleNoteString = [self.NotesCollection getNoteTitleFromKey: [gi.group titleNoteKey]];
                    NSLog(@"Group title: %@", titleNoteString);
                    NSLog(@"Group key: %@", [gi.group key]);
                }
            }
        }
    }
    
    @end
