//
//  UISegmentedControl+MyTitle.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/12/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (MyTitle)


- (void) setMyTitle: (NSString *) title forSegmentAtIndex: (NSUInteger) i;

- (NSString *) getMyTitleForSegmentAtIndex: (NSUInteger) i;

- (NSString *) getMyTitleForCurrentlySelectedSegment;

@end
