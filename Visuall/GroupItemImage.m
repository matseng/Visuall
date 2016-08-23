//
//  GroupItemImage.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/22/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "GroupItemImage.h"

@implementation GroupItemImage

- (instancetype) initGroupWithImage: (UIImage *) img andPoint: (CGPoint) point
//- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float) width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
        CGRect rect = CGRectMake(point.x, point.y, 100, 100);
        Group2 *group = [[Group2 alloc] init];
        group.key = nil;
        group.x = rect.origin.x;
        group.y = rect.origin.y;
        group.width = rect.size.width;
        group.height = rect.size.height;
        [self setGroup: group];
        [self renderGroup];
        [self setViewAsNotSelected];
        [self updateFrame];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
        imageView.frame = CGRectMake(0, 0, 100, 100);
        [self.innerGroupView addSubview: imageView];
    }
    return self;
}

@end
