//
//  GroupItem.m
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "GroupItem.h"

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0

@implementation GroupItem

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
        self.group = [[Group alloc] initWithPoint:coordinate andWidth:width andHeight:height];
        [self setFrame:CGRectMake(coordinate.x, coordinate.y, width, height)];
        [self setBackgroundColor:GROUP_VIEW_BACKGROUND_COLOR];
        [self.layer setBorderColor:GROUP_VIEW_BORDER_COLOR];
        [self.layer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
    }

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
