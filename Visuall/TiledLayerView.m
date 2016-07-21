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

    UIView *NotesView = self.subviews[0];
    for (UIView *subview in [NotesView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isKindOfClass: [NoteItem2 class]])
        {
            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
            return self.hitTestView;
        }
    }
    for (UIView *subview in  [[NotesView viewWithTag:999].subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isGroupItem])
        {
            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
            return self.hitTestView;
        }
    }
    self.hitTestView = nil;
    return nil;
}

@end
