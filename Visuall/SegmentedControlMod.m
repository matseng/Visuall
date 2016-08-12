//
//  SegmentedControlMod.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "SegmentedControlMod.h"

@implementation SegmentedControlMod

NSMutableDictionary *dict;

- (void) setMyTitle: (NSString *) title forSegmentAtIndex: (NSUInteger) i
{
    if (!dict) dict = [[NSMutableDictionary alloc] init];
    [dict setObject:title forKey: [NSNumber numberWithUnsignedInteger:i]];
}
//
- (NSString *) getMyTitleForSegmentAtIndex: (NSUInteger) i
{
    return [dict objectForKey:[NSNumber numberWithUnsignedInteger:i]];
}

- (NSString *) getMyTitleForCurrentlySelectedSegment
{
    NSInteger i = self.selectedSegmentIndex;
    return [dict objectForKey: [NSNumber numberWithInteger:i]];
}

/*
 * Name:
 * Description: Sends an event for tapping a segment that is already selected
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    
    [super touchesEnded:touches withEvent:event];
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    CGPoint viewPoint = [self convertPoint:locationPoint fromView:self];
    if ([self pointInside:viewPoint withEvent:event] && previousSelectedSegmentIndex == self.selectedSegmentIndex) {
        self.selectedSegmentIndex = UISegmentedControlNoSegment;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
