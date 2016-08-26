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
#import "UIView+VisualItem.m"
#import "ViewController.h"
#import "UserUtil.h"
#import "StateUtilFirebase.h"

static CGPoint __startPoint;
static CGPoint __endPoint;
static CAShapeLayer *__tempShapeLayer;

@implementation ArrowItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

{
    CGPoint __startPoint;
    CGPoint __endPoint;
//    CGFloat tailWidth;
//    CGFloat headWidth;
//    CGFloat headLength;
//    UIBezierPath *path;
    NoteItem2 *startNote;
    NoteItem2 *endNote;
    
}

+ (void) setStartPoint: (CGPoint) aPoint
{
    __startPoint = aPoint;
}

+ (CGPoint) getStartPoint
{
    return __startPoint;
}

- (instancetype) initArrowFromStartPointToEndPoint
{
    self = [super init];
    if (self) {
        //    CGPoint startPoint;
        //    CGPoint endPoint;
        CGFloat tailWidth;
        CGFloat headWidth;
        CGFloat headLength;
        UIBezierPath *path;
        
        tailWidth = 4;
        headWidth = 8 * 3;
        headLength = 8 * 3;
        
        if (__tempShapeLayer) [__tempShapeLayer removeFromSuperlayer];
        
        [self hitTestOnNotes: __startPoint];
        
        CGRect rect = [self createGroupViewRect: __startPoint withEndPoint: __endPoint];
        
        if ( rect.size.width < rect.size.height)  // TODO (Aug 25, 2016): Instead of augmenting the size of box, rotate the view instead via a transform
        {
            if (rect.size.width < 2 * headWidth)
            {
                rect.origin.x = rect.origin.x - 0.5 * headWidth;
                rect.size.width = 2 * headWidth;
            } else {
                rect.origin.x = rect.origin.x - 0.25 * headWidth;
                rect.size.width = rect.size.width + 0.5 * headWidth;
            }
        } else {
            if (rect.size.height < 2 * headWidth)
            {
                rect.origin.y = rect.origin.y - 0.5 * headWidth;
//                rect.size.height = rect.size.height + headWidth;
                rect.size.height = 2 * headWidth;
            } else {
                rect.origin.y = rect.origin.y - 0.25 * headWidth;
                rect.size.height = rect.size.height + 0.5 * headWidth;
            }
        }
        self.frame = rect;
        self.backgroundColor = [UIColor redColor];

        CGPoint localStartPoint = CGPointMake(__startPoint.x - rect.origin.x, __startPoint.y - rect.origin.y);
        CGPoint localEndPoint = CGPointMake(__endPoint.x - rect.origin.x, __endPoint.y - rect.origin.y);
        
        [[UIColor redColor] setStroke];

        path = [UIBezierPath bezierPathWithArrowFromPoint:(CGPoint)localStartPoint
                                                  toPoint:(CGPoint)localEndPoint
                                                tailWidth:(CGFloat)tailWidth
                                                headWidth:(CGFloat)headWidth
                                               headLength:(CGFloat)headLength];
        [path setLineWidth:2.0];
        [path stroke];
        
        CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
        [shapeView setPath: path.CGPath];
        [self.layer addSublayer: shapeView];
    }
    return self;
}

//- (UIView *) hitTestOnNotes: (CGPoint) point withViewController: (ViewController *) viewController
//{
//    
//    return [viewController.BoundsTiledLayerView hitTestOnNotes: point withEvent:nil];
//}

- (UIView *) hitTestOnNotes: (CGPoint) point
{
    StateUtilFirebase *state = [[UserUtil sharedManager] getState];
    return [[state BoundsTiledLayerView] hitTestOnNotes: point withEvent:nil];
}

//- (UIView *) hitTestOnNotes:(CGPoint)point withEvent:(UIEvent *)event

- (CGRect) createGroupViewRect:(CGPoint)start withEndPoint:(CGPoint)end {
    float x1 = start.x < end.x ? start.x : end.x;
    float y1 = start.y < end.y ? start.y : end.y;
    
    float x2 = start.x < end.x ? end.x : start.x;
    float y2 = start.y < end.y ? end.y : start.y;
    
    float width = x2 - x1;
    float height = y2 - y1;
    
    return CGRectMake(x1, y1, width, height);
}

/*
- (instancetype) __initArrowWithSourceNoteItem: (NoteItem2*) ni0 andTargetNoteItem: (NoteItem2*) ni1
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
        tailWidth = 20.0;
        headWidth = 40.0;
        headLength = 50.0;
        

//        self.frame = CGRectMake(self.arrow.sourcePoint.x, self.arrow.sourcePoint.y, dist, dist);
        [self setFrame: CGRectUnion(ni0.frame, ni1.frame)];
//        UIView *temp = [[UIView alloc] init];
//        temp.frame = self.frame;
//        [self setNeedsDisplay];
//        self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.backgroundColor = [UIColor blueColor];
//        CGPoint origin = temp.frame.origin;
        CGPoint relativeSourcePoint = CGPointMake( ni0.frame.origin.x - self.frame.origin.x, ni0.frame.origin.y - self.frame.origin.y);
        CGPoint relativeTargetPoint = CGPointMake( ni1.frame.origin.x - self.frame.origin.x, ni1.frame.origin.y - self.frame.origin.y);
//        CGPoint relativeTargetPoint = [temp convertPoint: [ni1 getRelativeCenterPoint] fromView:ni1];
//        CGPoint relativeSourcePoint = [ni0 getRelativeCenterPoint];
//        CGPoint relativeTargetPoint = [ni0 convertPoint: [ni1 getRelativeCenterPoint] fromView:ni1];
        
//        [[UIColor redColor] setStroke];
        UIBezierPath *uberArror = [UIBezierPath bezierPathWithArrowFromPoint:relativeSourcePoint toPoint:relativeTargetPoint tailWidth: tailWidth headWidth: headWidth headLength: headLength];
        
        ////        [uberArror setLineWidth:2.0];
////        [uberArror stroke];
//        
        CAShapeLayer *lines = [CAShapeLayer layer];
        lines.position = CGPointMake(0, 0); //etc...
        lines.path = uberArror.CGPath;
//        lines.bounds = CGPathGetBoundingBox(lines.path);
//        lines.bounds = self.frame;
        lines.strokeColor = [UIColor whiteColor].CGColor;
        lines.fillColor = [UIColor redColor].CGColor; // if you just want lines
        lines.lineWidth = 3;
        [self.layer addSublayer:lines];
//        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//        shapeLayer.path = [self createPath].CGPath;
//        shapeLayer.strokeColor = [UIColor redColor].CGColor; //etc...
//        shapeLayer.lineWidth = 2.0; //etc...
//        shapeLayer.position = CGPointMake(100, 100); //etc...
//        [self.layer addSublayer:shapeLayer];
        
        
//        lines.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
//        lines.anchorPoint = CGPointMake(.5, .5);
        

//        [self drawRect: self.frame];
    }
    return self;
}

- (void)__drawRect:(CGRect)rect {
    
    [[UIColor redColor] setStroke];
    tailWidth = 4;
    headWidth = 8;
    headLength = 8;
    path = [UIBezierPath bezierPathWithArrowFromPoint:(CGPoint) self.arrow.sourcePoint
                                                  toPoint:(CGPoint) self.arrow.targetPoint
                                                tailWidth:(CGFloat) tailWidth
                                                headWidth:(CGFloat) headWidth
                                               headLength:(CGFloat) headLength];
    [path setLineWidth:2.0];
    
    [path stroke];
    
}
*/

@end
