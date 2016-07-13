//
//  UISegmentedControl+MyTitle.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "UISegmentedControl+MyTitle.h"

@implementation UISegmentedControl (MyTitle)

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
@end
