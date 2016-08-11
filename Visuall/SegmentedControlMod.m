//
//  SegmentedControlMod.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "SegmentedControlMod.h"

@implementation SegmentedControlMod

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (current == self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

//NSMutableDictionary *dict;
//
//- (void) setSelectedSegmentIndex:(NSInteger)toValue
//{
//    if (self.selectedSegmentIndex == toValue) {
//        [super setSelectedSegmentIndex:UISegmentedControlNoSegment];
//    } else {
//        [super setSelectedSegmentIndex:toValue];
//    }
//}
//
//- (void) setMyTitle: (NSString *) title forSegmentAtIndex: (NSUInteger) i
//{
//    if (!dict) dict = [[NSMutableDictionary alloc] init];
//    [dict setObject:title forKey: [NSNumber numberWithUnsignedInteger:i]];
//}
////
//- (NSString *) getMyTitleForSegmentAtIndex: (NSUInteger) i
//{
//    return [dict objectForKey:[NSNumber numberWithUnsignedInteger:i]];
//}
//
//- (NSString *) getMyTitleForCurrentlySelectedSegment
//{
//    NSInteger i = self.selectedSegmentIndex;
//    return [dict objectForKey: [NSNumber numberWithInteger:i]];
//}

@end
