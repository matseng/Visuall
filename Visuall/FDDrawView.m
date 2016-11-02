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

// the paths currently displayed by this view
@property (nonatomic, strong) NSMutableArray *paths;

// the current path the user is drawing
@property (nonatomic, strong) FDPath *currentPath;

// the touch that is used to currently draw this path
@property (nonatomic, strong) UITouch *currentTouch;

//@property (nonatomic, strong) UIView *currentView;

@property (nonatomic, strong) DrawItem *shapeLayer;

@property (nonatomic, strong) DrawItem *shapeLayerBackground;

@property float lineWidth;

@end

@implementation FDDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.paths = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        self.drawColor = [UIColor redColor];
        self.lineWidth = 5.0;
        self.shapeLayerBackground = [[DrawItem alloc] init];  // shows highlight of currently selected line segment
        self.shapeLayer = [[DrawItem alloc] init];  // shows current line segment
        [self.layer addSublayer: self.shapeLayerBackground];
        [self.layer addSublayer: self.shapeLayer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    
    // draw all lines from Firebase
    //    for (FDPath *path in self.paths) {
    //        [self drawPath:path withContext:context];
    //        [self drawPathOnShapeLayer: path withContext: context];
    
    //    }
    
    // make sure to draw the line the user is currently drawing
    if (self.currentPath != nil) {
        //        [self drawPath:self.currentPath withContext:context];
        [self drawPathOnShapeLayer: self.currentPath withContext: context];
        [self drawPathOnBackgroundLayer: self.currentPath withContext: context];
    }
}

- (void)addPath:(FDPath *)path
{
    [self.paths addObject:path];

    // make sure the view is redrawn
    [self setNeedsDisplay];
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
//    return;
    
    /*

     //Get the CGContext from this view
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     //Set the stroke (pen) color
     CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
     //Set the width of the pen mark
     CGContextSetLineWidth(context, 5.0);
     
     // Draw a line
     //Start at this point
     CGContextMoveToPoint(context, 10.0, 30.0);
     
     //Give instructions to the CGContext
     //(move "pen" around the screen)
     CGContextAddLineToPoint(context, 310.0, 30.0);
     CGContextAddLineToPoint(context, 310.0, 90.0);
     CGContextAddLineToPoint(context, 10.0, 90.0);
     
     //Draw it
     CGContextStrokePath(context);
     */
    
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

        DrawItem *circleLayer = [DrawItem layer];
        
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
        
        [self.layer addSublayer: circleLayer];
        circleLayer.fdpath = self.currentPath;
        circleLayer.isPoint = YES;
        [self.paths addObject: circleLayer];
        
        
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
    DrawItem *layer = [[DrawItem alloc] init];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    [self drawPathOnShapeLayer: layer withPath: self.currentPath withContext:context];
    [self.layer addSublayer: layer];
    layer.fdpath = self.currentPath;
    [self.paths addObject: layer];
    
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentPath != nil) {
        for (UITouch *touch in touches) {
            if (self.currentTouch == touch) {
                // the touch finished draw add the line to the current state
                [self.paths addObject:self.currentPath];

                // notify the delegate
                [self.delegate drawView:self didFinishDrawingPath:self.currentPath];

                // reset drawing state
                self.currentPath = nil;
                self.currentTouch = nil;
            }
        }
    }
}


/*
Problem:
    https://oleb.net/blog/2012/02/cgpath-hit-testing/
    Hit testing. The CGPath APIs can only help you if you want to hit test the for interior of a path, not if your hit target is the path’s contour. Since CGPathCreateCopyByStrokingPath() can convert the countour into a new path’s interior, it can help with this problem, too.
 */

- (CAShapeLayer *) hitTestOnShapeLayer: (CGPoint) point withEvent:(UIEvent *)event
{
    int counter = 0;
    for (DrawItem *layer in self.layer.sublayers)
    {
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
                self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
                self.shapeLayerBackground.lineWidth = self.lineWidth * 2;
                [self.shapeLayerBackground setFillColor: nil];
                [self.shapeLayerBackground setPath: layer.path];
                
                return layer;
            }
        } else if (layer.path && layer.isPoint)
        {
            FDPoint *fdpoint = [layer.fdpath getFirstPoint];
            double dist = hypot((point.x - fdpoint.x), (point.y - fdpoint.y));
            if (dist < self.lineWidth * 2)
            {
                self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
                self.shapeLayerBackground.lineWidth = self.lineWidth * 2;
                [self.shapeLayerBackground setFillColor: nil];
                [self.shapeLayerBackground setPath: layer.path];
            }
            NSLog(@"\n dist: %f", dist);
        }
        counter++;
    }
    NSLog(@"\n layer counter: %i", counter);
    return nil;
}


@end
