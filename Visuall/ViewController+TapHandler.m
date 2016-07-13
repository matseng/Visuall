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
#import "TransformUtil.h"

@implementation ViewController (TapHandler)


/*
 Handle tap gesture on background AND other objects especially Groups (and Notes?)
 TODO: refactor as a hard coded gesture recognizer for the background
 */

- (void) tapHandler:(UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        UIView *viewHit = [self getViewHit:sender];
        //        NSLog(@"My viewHit %@", [viewHit class]);
        //        NSLog(@"tag %ld", (long)viewHit.tag);
        //        NSLog(@"gestureRecognizer %@", [sender.view class]);
        
        if ( [viewHit isKindOfClass: [NoteItem2 class]])
        {
            NoteItem2 *nv = (NoteItem2 *) viewHit;
            [self setSelectedObject:nv];
            NSLog(@"Note key: %@", nv.note.key);
            NSLog(@"Parent group key: %@", nv.note.parentGroupKey);
            NSLog(@"Is a title note?: %@", nv.note.isTitleOfParentGroup ? @"YES" : @"NO");
            NSLog(@"Note width: %f", nv.frame.size.width);
            return;
        }
        
        if ( [self isNoteButtonSelected] ) {  // new note button  //- (BOOL) isNoteButtonSelected
            CGPoint gesturePoint = [sender locationInView: self.Background];
            CGPoint point = [[TransformUtil sharedManager] getGlobalCoordinate:gesturePoint];
            NoteItem2 *newNote = [[NoteItem2 alloc] initNote:@"text..." withPoint:point];
            [self setInitialNote:newNote];
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
