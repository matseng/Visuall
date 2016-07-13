//
//  ViewController+ViewHit.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+ViewHit.h"
#import "NoteItem2.h"
//#import "GroupItem.h"

@implementation ViewController (ViewHit)

- (UIView *) getViewHit: (UIGestureRecognizer *) gestureRecognizer
{
    
    UIView *viewHit = gestureRecognizer.view;
    CGPoint location = [gestureRecognizer locationInView: gestureRecognizer.view];
    
    if ([self.scrollViewButtonList hitTest:[gestureRecognizer locationInView: self.scrollViewButtonList] withEvent:NULL])
    {
        return self.scrollViewButtonList;
    }
    
    NoteItem2 *ni = [self getNoteItem2FromViewHit:viewHit];
    if (ni) {
        viewHit = ni;
    } else { // Hack to to double-check if a note is the viewHit
        //        CGPoint location = [gestureRecognizer locationInView: gestureRecognizer.view];
        viewHit = [self.NotesView hitTest:location withEvent:NULL];
        ni = [self getNoteItem2FromViewHit:viewHit];
        if (ni) {
            viewHit = ni;
        }
    }
    
    NSLog(@"getviewHit class: %@", [viewHit class]);
    NSLog(@"viewHit.tag %li", (long) viewHit.tag);
    return viewHit;
    //    return gestureRecognizer.view;
}


- (NoteItem2 *) getNoteItem2FromViewHit: (UIView *) viewHit
{
    NoteItem2 *ni;
    if ( [viewHit isKindOfClass: [NoteItem2 class]])
    {
        ni = (NoteItem2 *) viewHit;
    } else if ( [[viewHit superview] isKindOfClass: [NoteItem2 class]] )
    {
        ni = (NoteItem2*)[viewHit superview];
    }
    return ni;
}

@end
