//
//  FDDrawView.m
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FDDrawView.h"
#import "UserUtil.h"

@interface FDDrawView ()

// the paths (PathItems) currently displayed by this view
@property (nonatomic, strong) NSMutableArray *paths;

// the current path the user is drawing
@property (nonatomic, strong) FDPath *currentPath;

// the touch that is used to currently draw this path
@property (nonatomic, strong) UITouch *currentTouch;

//@property (nonatomic, strong) UIView *currentView;

@property (nonatomic, strong) PathItem *shapeLayer;

@property (nonatomic, strong) PathItem *shapeLayerBackground;

@property float lineWidth;

@end

@implementation FDDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.paths = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        self.drawColor = [UIColor redColor];
        self.lineWidth = 5.0;
        self.shapeLayerBackground = [[PathItem alloc] init];  // shows highlight of currently selected line segment
        self.shapeLayer = [[PathItem alloc] init];  // shows current line segment
        [self.layer addSublayer: self.shapeLayerBackground];
        [self.layer addSublayer: self.shapeLayer];
    }
    return self;
}

- (void) addPathItemToMVCandFirebase: (PathItem *) pi
{
    self.selectedPath = pi;
    [[[UserUtil sharedManager] getState] setValuePath: pi];
    [self addPathItemToMVC: pi];
    [self highlightSelectedPath];
}

- (void) addPathItemToMVC: (PathItem *) pi
{
    [[[[UserUtil sharedManager] getState] pathsCollection] addItem: pi withKey: pi.key];
    [self.layer addSublayer: pi];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    
    if (self.currentPath != nil)
    {
        [self drawPathOnShapeLayer: self.currentPath withContext: context];
        [self drawPathOnBackgroundLayer: self.currentPath withContext: context];
    }
}

- (void) drawPath:(FDPath *)path withContext:(CGContextRef)context
{
    if (path.points.count > 1) {
        // make sure this is a new line
        CGContextBeginPath(context);

        // set the color
        CGContextSetStrokeColorWithColor(context, path.color.CGColor);

        FDPoint *point = path.points[0];
        CGContextMoveToPoint(context, point.x, point.y);

        // draw all points on the path
        for (NSUInteger i = 0; i < path.points.count; i++) {
            FDPoint *point = path.points[i];
            CGContextAddLineToPoint(context, point.x, point.y);
        }

        // actually draw the path
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)__drawPathOnShapeLayer:(FDPath *)path withContext:(CGContextRef)context
{
    if (path.points.count > 1)
    {
        CGMutablePathRef newPath = CGPathCreateMutable();
        FDPoint *point = path.points[0];
        
        
        for (NSUInteger i = 0; i < path.points.count - 1; i++)
        {
            FDPoint *point = path.points[i];
            FDPoint *nextPoint = path.points[i+1];
            CGPathMoveToPoint(newPath, NULL, point.x, point.y);
            CGPathAddLineToPoint(newPath, NULL, nextPoint.x, nextPoint.y);
        }
//        CGPathCloseSubpath(newPath);
        
//        CGContextBeginPath(context);
        CGContextAddPath(context, newPath);
        CGContextSetStrokeColorWithColor(context,[UIColor greenColor].CGColor);
        CGContextSetLineWidth(context, 4.0);
        CGContextStrokePath(context);
    }

}

- (void) drawPathOnShapeLayer:(FDPath *)path withContext:(CGContextRef)context
{
//    [shapeView setPath: path.CGPath];
    
    if (path.points.count > 1) {
        // make sure this is a new line
        CGContextBeginPath(context);
        
        // set the color
        CGContextSetStrokeColorWithColor(context, path.color.CGColor);
        
        FDPoint *point = path.points[0];
        CGContextMoveToPoint(context, point.x, point.y);
        
        // draw all points on the path
        for (NSUInteger i = 0; i < path.points.count; i++) {
            FDPoint *point = path.points[i];
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        CGPathRef pathRef = CGContextCopyPath(context);
        
        // actually draw the path
        self.shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
        self.shapeLayer.lineWidth = 4.0;
//        [self.shapeLayer setFillColor:[[UIColor redColor] CGColor]];
        [self.shapeLayer setFillColor: nil];
        [self.shapeLayer setPath: pathRef];

    }
}

- (void) drawPathOnBackgroundLayer:(FDPath *)path withContext:(CGContextRef)context
{
    if (path.points.count > 1) {
        // make sure this is a new line
        CGContextBeginPath(context);
        
        // set the color
        CGContextSetStrokeColorWithColor(context, path.color.CGColor);
        
        FDPoint *point = path.points[0];
        CGContextMoveToPoint(context, point.x, point.y);
        
        // draw all points on the path
        for (NSUInteger i = 0; i < path.points.count; i++) {
            FDPoint *point = path.points[i];
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        CGPathRef pathRef = CGContextCopyPath(context);
        
        // actually draw the path
        self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
        self.shapeLayerBackground.lineWidth = 10.0;
        [self.shapeLayerBackground setFillColor: nil];
        [self.shapeLayerBackground setPath: pathRef];
    }
}

- (void) drawPathOnShapeLayer: (CAShapeLayer *) shapeLayer withPath: (FDPath *)path withContext:(CGContextRef)context
{
    //    [shapeView setPath: path.CGPath];
    
    if (path.points.count > 1) {
        // make sure this is a new line
        CGContextBeginPath(context);
        
        // set the color
        CGContextSetStrokeColorWithColor(context, path.color.CGColor);
        
        FDPoint *point = path.points[0];
        CGContextMoveToPoint(context, point.x, point.y);
        
        // draw all points on the path
        for (NSUInteger i = 0; i < path.points.count; i++) {
            FDPoint *point = path.points[i];
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        CGPathRef pathRef = CGContextCopyPath(context);
        
        // actually draw the path
        shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
        shapeLayer.lineWidth = 4.0;
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setPath: pathRef];
        
    }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (self.currentPath == nil) {
        // the user is currently not drawing a line so start a new one

        // remember the touch to not mix up multitouch
        self.currentTouch = [touches anyObject];
        self.currentPath = [[FDPath alloc] initWithColor:self.drawColor];

        // add the current point on the path
        CGPoint touchPoint = [self.currentTouch locationInView:self];
        [self.currentPath addPoint:touchPoint];

        [self setNeedsDisplay];
    }
}

- (void) tapHandler: (UIGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.currentPath = [[FDPath alloc] initWithColor:self.drawColor];
        CGPoint touchPoint = [gestureRecognizer locationInView: self];
        [self.currentPath addPoint: touchPoint];

        PathItem *circleLayer = [PathItem layer];
        
        [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(touchPoint.x - self.lineWidth / 2, touchPoint.y - self.lineWidth / 2, self.lineWidth, self.lineWidth)] CGPath]];
/*
        UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:circleLayer.path];
        CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(circleLayer.path, NULL, 35.0f,
                                                                path.lineCapStyle,
                                                                 path.lineJoinStyle,
                                                                 path.miterLimit);
        [circleLayer setPath: tapTargetPath];
*/
        [circleLayer setFillColor: [[UIColor blueColor] CGColor]];
        
        circleLayer.fdpath = self.currentPath;
        circleLayer.isPoint = YES;
        [self addPathItemToMVCandFirebase: circleLayer];
        
        // notify the delegate
        [self.delegate drawView:self didFinishDrawingPath:self.currentPath];
        
        // reset drawing state
        self.currentPath = nil;
    }
}

- (void) panHandler: (UIGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self panBeganWithGestureRecognizer: gestureRecognizer];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [self panChangedWithGestureRecognizer: gestureRecognizer];
        NSLog(@"\n FDDrawView");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self panEndedWithGestureRecognizer: gestureRecognizer];
    }
}


- (void) panBeganWithGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
{
    CGPoint touchDownPoint = [[[UserUtil sharedManager] getState] touchDownPoint];
    self.currentPath = [[FDPath alloc] initWithColor:self.drawColor];
    CGPoint touchPoint = [gestureRecognizer locationInView: self];
    [self.currentPath addPoint:touchDownPoint];
    [self.currentPath addPoint:touchPoint];
    self.selectedPath = self.currentPath;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentPath != nil) {
        // look if any of the touches that moved is the one currently used to draw a line
        for (UITouch *touch in touches) {
            if (self.currentTouch == touch) {
                // we found the touch so update the line
                CGPoint touchPoint = [self.currentTouch locationInView:self];
                [self.currentPath addPoint:touchPoint];
                [self setNeedsDisplay];
            }
        }
    }
}

- (void) panChangedWithGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView: self];
    [self.currentPath addPoint:touchPoint];
    [self setNeedsDisplay];
}

- (void) panEndedWithGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
{
    // the touch finished draw add the line to the current state
//    [self.paths addObject:self.currentPath];
    
    // draw completed path on its own shape layer
//    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    PathItem *layer = [[PathItem alloc] init];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    [self drawPathOnShapeLayer: layer withPath: self.currentPath withContext:context];
    layer.fdpath = self.currentPath;
    [self addPathItemToMVCandFirebase: layer];
    
    // notify the delegate
    [self.delegate drawView:self didFinishDrawingPath:self.currentPath];
    
    // reset drawing state
    self.currentPath = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentPath != nil) {
        for (UITouch *touch in touches) {
            if (self.currentTouch == touch) {
                // the touch was cancelled reset drawing state
                self.currentPath = nil;
                self.currentTouch = nil;
                [self setNeedsDisplay];
            }
        }
    }
}

/*
Problem:
    https://oleb.net/blog/2012/02/cgpath-hit-testing/
    Hit testing. The CGPath APIs can only help you if you want to hit test the for interior of a path, not if your hit target is the path’s contour. Since CGPathCreateCopyByStrokingPath() can convert the countour into a new path’s interior, it can help with this problem, too.
 */

- (PathItem *) hitTestOnShapeLayer: (CGPoint) point withEvent:(UIEvent *)event
{
    int counter = 0;
    NSMutableDictionary *items =  [[[[UserUtil sharedManager] getState] pathsCollection] items];
    
//    for (PathItem *layer in self.layer.sublayers)
    for (NSString *key in items)
    {
        PathItem *layer = items[key];
        if ( layer.path && !layer.isPoint)
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:layer.path];
            
            CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(layer.path,
                                                                     NULL,
                                                                     fmaxf(35.0f, path.lineWidth),
//                                                                     path.lineWidth,
                                                                     path.lineCapStyle,
                                                                     path.lineJoinStyle,
                                                                     path.miterLimit);
            if (tapTargetPath == NULL) {
                return nil;
            }
            
            UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:tapTargetPath];
//            UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:layer.path];
            CGPathRelease(tapTargetPath);

            
            if ([tapTarget containsPoint:point])
            {
                self.selectedPath = layer;
                return layer;
            }
        } else if (layer.path && layer.isPoint)
        {
            FDPoint *fdpoint = [layer.fdpath getFirstPoint];
            double dist = hypot((point.x - fdpoint.x), (point.y - fdpoint.y));
            if (dist < self.lineWidth * 2)
            {
//                self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
//                self.shapeLayerBackground.lineWidth = self.lineWidth * 2;
//                [self.shapeLayerBackground setFillColor: nil];
//                [self.shapeLayerBackground setPath: layer.path];
                self.selectedPath = layer;
                return layer;
            }
            NSLog(@"\n dist: %f", dist);
        }
        counter++;
    }
    NSLog(@"\n layer counter: %i", counter);
    self.selectedPath = nil;
    return nil;
}

- (void) highlightSelectedPath
{
    self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
    self.shapeLayerBackground.lineWidth = self.lineWidth * 2;
    [self.shapeLayerBackground setFillColor: nil];
    [self.shapeLayerBackground setPath: self.selectedPath.path];
}

- (void) removeHighlightFromPreviouslySelectedPath
{
    self.shapeLayerBackground.lineWidth = 0;
}

@end
