//
//  DrawItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 10/31/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "PathItem.h"
#import "FDPath.h"
#import "UserUtil.h"

@implementation PathItem

- (instancetype) initPathFromFirebase: (NSString *) key andValue: (NSDictionary *) value
{
    self = [super init];
    if (self) {
//        [self setDataFromFirebase: key andValue: value];
//        [self addArrowSublayer];
//        [self addHandles];
        self.key = key;
        self.fdpath = [FDPath parse: value[@"data"][@"path"]];
        self.fdpath.color = [UIColor blueColor];  // overwriting color for now
        if ( value[@"data"][@"path"][@"lineWidth"] != nil)
        {
            self.fdpath.lineWidth = [value[@"data"][@"path"][@"lineWidth"] floatValue];
        }
        else
        {
            self.fdpath.lineWidth = 4.0;
        }
        if ( self.fdpath.points.count == 1 )
        {
            self.isPoint = YES;
        }        
    }
    return self;
}

- (void) increaseLineWidth
{
    self.fdpath.lineWidth = [[[UserUtil sharedManager] getState] roundUpToEven: self.fdpath.lineWidth * 1.5];
    [self drawPathOnSelf];
}

- (void) decreaseLineWidth
{
    self.fdpath.lineWidth =  [[[UserUtil sharedManager] getState] roundUpToEven: self.fdpath.lineWidth * 0.667];
    [self drawPathOnSelf];
}

- (void) drawPathOnSelf
{
    FDPath *path = self.fdpath;
    if (path.isCircle || path.points.count == 1)
    {
        path.isCircle = YES;
        FDPoint *point = self.fdpath.points[0];
//        [self setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - self.lineWidth / 2, point.y - self.lineWidth / 2, self.lineWidth, self.lineWidth)] CGPath]];
        [self setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - self.fdpath.lineWidth / 2, point.y - self.fdpath.lineWidth / 2, self.fdpath.lineWidth, self.fdpath.lineWidth)] CGPath]];
        [self setFillColor: [[UIColor blueColor] CGColor]];
    }
    
    else if (path.points.count > 1) {
        // make sure this is a new line and starting point
        UIBezierPath *bzPath = [UIBezierPath bezierPath];
        FDPoint *point = path.points[0];
        [bzPath moveToPoint: CGPointMake(point.x, point.y)];
        
        // draw all points on the path
        for (NSUInteger i = 0; i < path.points.count; i++) {
            FDPoint *point = path.points[i];
            [bzPath addLineToPoint:CGPointMake(point.x, point.y)];
        }
        
        // actually draw the path
        self.strokeColor = [self.fdpath.color CGColor];
        self.lineWidth = self.fdpath.lineWidth;
        [self setFillColor: nil];
        [self setPath: bzPath.CGPath];
    }
}


@end
