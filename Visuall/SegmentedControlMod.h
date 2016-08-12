//
//  SegmentedControlMod.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedControlMod : UISegmentedControl

// TODO (Aug 11, 2016): Move methods for UISegmentedControl+MyTitle.h to this new subclass

- (void) setMyTitle: (NSString *) title forSegmentAtIndex: (NSUInteger) i;

- (NSString *) getMyTitleForSegmentAtIndex: (NSUInteger) i;

- (NSString *) getMyTitleForCurrentlySelectedSegment;

- (BOOL) didValueChange;

@end
