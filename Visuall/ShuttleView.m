//
//  ShuttleView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 2/10/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import "ShuttleView.h"
#import "UserUtil.h"

@implementation ShuttleView

- (instancetype) initWithGroupItem: (GroupItem *) gi
{
    self = [super init];
    if (self)
    {
        CGRect rect =  [[[[UserUtil sharedManager] getState] VisualItemsView] frame];
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, 1, 1);
//        [self addSubview: gi];
    }
    return self;
}

// Add visual items to view and remove from their parent views. Also need a new FDView for PathItems


// Remove visual items and add them back to their original superviews

@end
