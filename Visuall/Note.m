//
//  Note.m
//  Visuall
//
//  Created by John Mai on 11/20/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "Note.h"

@implementation Note

- (void) setCenterPoint: (CGPoint)point
{
    self.centerX = [NSNumber numberWithFloat:point.x];
    self.centerY = [NSNumber numberWithFloat:point.y];
}
    
- (void) setCenterX:(float)pointX andCenterY:(float)pointY
{
    self.centerX = [NSNumber numberWithFloat:pointX];
    self.centerY = [NSNumber numberWithFloat:pointY];
}

- (void) setHeight:(float)height andWidth:(float)width
{
    self.height = [NSNumber numberWithFloat:height];
    self.width = [NSNumber numberWithFloat:width];
}

- (void) setWidth:(float)width andHeight:(float)height
{
    self.height = [NSNumber numberWithFloat:height];
    self.width = [NSNumber numberWithFloat:width];
}

- (float) getX
{
    if (self.x) {
        return self.x;
    } else if (self.centerX)
    {
        return self.centerX.floatValue - 0.5 * self.width.floatValue;
    }
    return NO;
}

- (float) getY
{
    if (self.y) {
        return self.y;
    } else if (self.centerY)
    {
        return self.centerX.floatValue - 0.5 * self.width.floatValue;
    }
    return NO;
}

@end
