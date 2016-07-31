//
//  ScrollViewMod.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/27/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ScrollViewMod.h"
#import "NoteItem2.h"
#import "UIView+VisualItem.h"

@implementation ScrollViewMod

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// Have access to the super class' original method that is overwritten by the subclass'
// http://stackoverflow.com/questions/16678463/accessing-a-method-in-a-super-class-when-its-not-exposed
- (void)scrollRectToVisibleSuperclass:(CGRect)rect animated:(BOOL)animated
{
    //now call super method here
    [super scrollRectToVisible:(CGRect)rect animated:(BOOL)animated];
}

// Overwrite this method to prevent jumpiness in the scroll view when entering text in a note
// http://stackoverflow.com/questions/4585718/disable-uiscrollview-scrolling-when-uitextfield-becomes-first-responder
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    return;
}

// implement custom hit testing for notes and groups // http://smnh.me/hit-testing-in-ios/

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *target;
    UIView *NotesView = self.subviews[0].subviews[0].subviews[2];  // TODO: Create singleton to hold views
    UIView *GroupsView = self.subviews[0].subviews[0].subviews[0];
    
    for (UIView *subview in [NotesView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
//        if ([subview pointInside:convertedPoint withEvent:event] && [subview isKindOfClass: [NoteItem2 class]])
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isNoteItem])
        {
            target =  [subview hitTest:convertedPoint withEvent:event];
            NSLog(@"scrollView hitTest %@", [target class]);
            return target;
        }
    }
    for (UIView *subview in [GroupsView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isGroupItem])
        {
            target =  [subview hitTest:convertedPoint withEvent:event];
            return target;
        }
    }
//    self.hitTestView = nil;
    NSLog(@"scrollView hitTest %@", nil);
    return self;
}

@end
