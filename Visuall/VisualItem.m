//
//  VisualItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "VisualItem.h"

@implementation VisualItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) setX:(float)x andY:(float)y andWidth: (float) width andHeight:(float) height
{
    self.x = x;
    self.y = y;
    self.width = width;
    self.height = height;
}

@end
