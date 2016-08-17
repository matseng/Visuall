//
//  SegmentedControlMod.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "SegmentedControlMod.h"

//@interface SegmentedControlMod : UISegmentedControl
@interface SegmentedControlMod ()

@property BOOL valueChange;
@property NSMutableDictionary *dict;

@end

@implementation SegmentedControlMod

- (void) setMyTitle: (NSString *) title forSegmentAtIndex: (NSUInteger) i
{
    if (!self.dict) self.dict = [[NSMutableDictionary alloc] init];
    [self.dict setObject:title forKey: [NSNumber numberWithUnsignedInteger:i]];
}
//
- (NSString *) getMyTitleForSegmentAtIndex: (NSUInteger) i
{
    return [self.dict objectForKey:[NSNumber numberWithUnsignedInteger:i]];
}

- (NSString *) getMyTitleForCurrentlySelectedSegment
{
    NSInteger i = self.selectedSegmentIndex;
    return [self.dict objectForKey: [NSNumber numberWithInteger:i]];
}

/*
 * Name:
 * Description: Sends an event for tapping a segment that is already selected
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.valueChange = YES;
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    
    [super touchesEnded:touches withEvent:event];
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    CGPoint viewPoint = [self convertPoint:locationPoint fromView:self];
    if ([self pointInside:viewPoint withEvent:event] && previousSelectedSegmentIndex == self.selectedSegmentIndex)
    {
        self.valueChange = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

- (BOOL) didValueChange
{
    return self.valueChange;
}

@end
