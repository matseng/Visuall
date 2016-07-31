//
//  BackgroundView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/31/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "BackgroundView.h"
#import "NoteItem2.h"
#import "UIView+VisualItem.h"

@implementation BackgroundView

UIView *NotesView;
UIView *GroupsView;

- (void) setNotesView: (UIView *) nv andGroupsView: (UIView *) gv
{
    NotesView = nv;
    GroupsView = gv;
}

// implement custom hit testing for notes and groups // http://smnh.me/hit-testing-in-ios/

- (UIView *) __hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *target;
    UIView *NotesView = self.subviews[0].subviews[0].subviews[2];  // TODO: Create singleton to hold views
    UIView *GroupsView = self.subviews[0].subviews[0].subviews[0];
    
    for (UIView *subview in [NotesView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isKindOfClass: [NoteItem2 class]])
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
