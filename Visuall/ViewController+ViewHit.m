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
    
//     UIView *hitTestView = [super hitTest:point withEvent:event];
    
    UIView *viewHit;
    CGPoint location;
    
    if ([self.scrollViewButtonList hitTest:[gestureRecognizer locationInView: self.scrollViewButtonList] withEvent:NULL])
    {
        return self.scrollViewButtonList;
    }
    
    UIView *view = gestureRecognizer.view;
    location = [gestureRecognizer locationInView: self.NotesView];
    viewHit = [self.NotesView hitTest:location withEvent:NULL];
    if ( viewHit )  
    {
        return [self getNoteItem2FromViewHit:viewHit];
    }
    
    return viewHit;
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
