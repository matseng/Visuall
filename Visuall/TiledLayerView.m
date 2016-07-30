//
//  TiledLayerView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/18/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "TiledLayerView.h"
#import "NoteItem2.h"
#import "UIView+VisualItem.h"

@implementation TiledLayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass {
    return [CATiledLayer class];
}

// implement custom hit testing for notes and groups // http://smnh.me/hit-testing-in-ios/

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    NSLog(@"TiledLayerView point %f, %f", point.x, point.y);
    UIView *NotesView = self.subviews[0].subviews[2];  // TODO: Create singleton to hold views
    UIView *GroupsView = self.subviews[0].subviews[0];
    UIView *target = nil;
    
    for (UIView *subview in [NotesView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isKindOfClass: [NoteItem2 class]])
        {
//            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
//            return self.hitTestView;
            target = [subview hitTest:convertedPoint withEvent:event];
            NSLog(@"TiledLayerView viewHit %@", [target class]);
            return target;
            
        }
    }
    for (UIView *subview in [GroupsView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isGroupItem])
        {
            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
            return self.hitTestView;
        }
    }
//    self.hitTestView = nil;
    NSLog(@"TiledLayerView viewHit %@", [target class]);
    return nil;
}

@end
