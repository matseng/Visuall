//
//  ScrollViewMod.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/27/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ScrollViewMod.h"

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
//
//- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    UIView *NotesView = self.subviews[0].subviews[2];  // TODO: Create singleton to hold views
//    UIView *GroupsView = self.subviews[0].subviews[0];
//    UIView *target = nil;
//    
//    for (UIView *subview in [NotesView.subviews reverseObjectEnumerator]) {
//        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
//        if ([subview pointInside:convertedPoint withEvent:event] && [subview isKindOfClass: [NoteItem2 class]])
//        {
//            //            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
//            //            return self.hitTestView;
//            target = [subview hitTest:convertedPoint withEvent:event];
//            NSLog(@"TiledLayerView viewHit %@", [target class]);
//            return target;
//            
//        }
//    }
//    for (UIView *subview in [GroupsView.subviews reverseObjectEnumerator]) {
//        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
//        if ([subview pointInside:convertedPoint withEvent:event] && [subview isGroupItem])
//        {
//            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
//            return self.hitTestView;
//        }
//    }
//    //    self.hitTestView = nil;
//    NSLog(@"TiledLayerView viewHit %@", [target class]);
//    return nil;
//}

@end
