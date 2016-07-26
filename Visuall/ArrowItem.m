//
//  EdgeItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ArrowItem.h"
#import "NoteItem2.h"
#import "UIBezierPath+arrowhead.h"

@implementation ArrowItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initArrowWithSourceNoteItem: (NoteItem2*) ni0 andTargetNoteItem: (NoteItem2*) ni1
// http://stackoverflow.com/questions/13528898/how-can-i-draw-an-arrow-using-core-graphics
//http://stackoverflow.com/questions/13528898/how-can-i-draw-an-arrow-using-core-graphics
{
    self = [super init];
    if (self) {
        self.arrow = [[Arrow alloc] init];
        self.arrow.sourceKey = [ni0 getKey];
        self.arrow.targetKey = [ni1 getKey];
        self.arrow.sourcePoint = [ni0 getCenterPoint];
        self.arrow.targetPoint = [ni1 getCenterPoint];
        float dist = sqrtf( powf(self.arrow.targetPoint.x - self.arrow.sourcePoint.x, 2) + powf(self.arrow.targetPoint.y - self.arrow.sourcePoint.y, 2) );
        self.arrow.length = dist;
        self.arrow.width = dist;  // TODO auto size width
        
        self.backgroundColor = [UIColor blueColor];
        self.frame = CGRectMake(self.arrow.sourcePoint.x, self.arrow.sourcePoint.y, dist, dist);
//        [[UIColor redColor] setStroke];
        UIBezierPath *uberArror = [UIBezierPath bezierPathWithArrowFromPoint:self.arrow.sourcePoint toPoint:self.arrow.targetPoint tailWidth:40 headWidth:40 headLength:50];
//        [uberArror setLineWidth:2.0];
//        [uberArror stroke];
        
        CAShapeLayer *lines = [CAShapeLayer layer];
        lines.path = uberArror.CGPath;
        lines.bounds = CGPathGetBoundingBox(lines.path);
        lines.strokeColor = [UIColor whiteColor].CGColor;
        lines.fillColor = [UIColor redColor].CGColor; /*if you just want lines*/
        lines.lineWidth = 3;
//        lines.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
//        lines.anchorPoint = CGPointMake(.5, .5);
        
        [self.layer addSublayer:lines];
        
    }
    return self;
}

@end
