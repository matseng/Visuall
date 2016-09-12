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
#import "UserUtil.h"

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

    UIView *target = nil;
    
    if ( [self hitTestOnArrows: point withEvent: event] ) {
        return self.hitTestView;
    }
    
    if ( [self hitTestOnNotes: point withEvent: event] ) return self.hitTestView;

    if ( [self hitTestOnGroups: point withEvent: event] ) return self.hitTestView;

    self.hitTestView = nil;
    NSLog(@"TiledLayerView viewHit %@", [target class]);
    return nil;
}

- (UIView *) hitTestOnGroups: (CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result;
    UIView *GroupsView = [[[UserUtil sharedManager] getState] GroupsView];
    for (GroupItem *gi in [GroupsView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [gi convertPoint:point fromView: self];
        result = [gi hitTestIncludingHandles:convertedPoint];
        if (result) {
            NSLog(@"TiledLayerView viewHit %@", [self.hitTestView class]);
            self.hitTestView = result;
            return self.hitTestView;
        }
    }
    return nil;
}

- (UIView *) hitTestOnNotes:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *NotesView = [[[UserUtil sharedManager] getState] NotesView];
    for (UIView *subview in [NotesView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView: self];
        if ([subview pointInside:convertedPoint withEvent:event] && [subview isKindOfClass: [NoteItem2 class]])
        {
            self.hitTestView = [subview hitTest:convertedPoint withEvent:event];
            NSLog(@"TiledLayerView viewHit %@", [self.hitTestView class]);
            return self.hitTestView;
        }
    }
    return nil;
}

- (UIView *) hitTestOnArrows:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result;
    UIView *ArrowsView =  [[[UserUtil sharedManager] getState] ArrowsView];
    for (ArrowItem *ai in [ArrowsView.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [ai convertPoint:point fromView: self];
        result = [ai hitTestWithHandles:convertedPoint];
        if (result) {
            NSLog(@"TiledLayerView viewHit %@", [self.hitTestView class]);
            self.hitTestView = result;
            return self.hitTestView;
        }
    }
    return nil;
}

@end
