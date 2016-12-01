//
//  DrawItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 10/31/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "PathItem.h"
#import "FDPath.h"

@implementation PathItem

- (instancetype) initPathFromFirebase: (NSString *) key andValue: (NSDictionary *) value
{
    self = [super init];
    if (self) {
//        [self setDataFromFirebase: key andValue: value];
//        [self addArrowSublayer];
//        [self addHandles];
        self.fdpath = [FDPath parse: value[@"data"][@"path"]];
        [self drawPathOnShapeLayer];
    }
    return self;
}

- (void) drawPathOnShapeLayer
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    
    if (self.fdpath.points.count > 1) {
        // make sure this is a new line
        CGContextBeginPath(context);
        
        // set the color
        CGContextSetStrokeColorWithColor(context, self.fdpath.color.CGColor);
        
        FDPoint *point = self.fdpath.points[0];
        CGContextMoveToPoint(context, point.x, point.y);
        
        // draw all points on the path
        for (NSUInteger i = 0; i < self.fdpath.points.count; i++) {
            FDPoint *point = self.fdpath.points[i];
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        CGPathRef pathRef = CGContextCopyPath(context);
        
        // actually draw the path
        self.strokeColor = [[UIColor blueColor] CGColor];
        self.lineWidth = 4.0;
        [self setFillColor:[[UIColor clearColor] CGColor]];
        [self setPath: pathRef];
    }
    else
    {
        NSLog(@"\n Draw a point on load");
    }
}


@end
