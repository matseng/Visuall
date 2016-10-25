//
//  FDDrawView.m
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import "FDDrawView.h"

@interface FDDrawView ()

// the paths currently displayed by this view
@property (nonatomic, strong) NSMutableArray *paths;

// the current path the user is drawing
@property (nonatomic, strong) FDPath *currentPath;

// the touch that is used to currently draw this path
@property (nonatomic, strong) UITouch *currentTouch;

//@property (nonatomic, strong) UIView *currentView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) CAShapeLayer *shapeLayerBackground;

@end

@implementation FDDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.paths = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        self.drawColor = [UIColor redColor];
//        self.currentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
//        self.currentView.backgroundColor = [UIColor blueColor];
//        self.currentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.shapeLayerBackground = [[CAShapeLayer alloc] init];
        self.shapeLayer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer: self.shapeLayerBackground];  // shows highlight for example
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

- (void)drawPath:(FDPath *)path withContext:(CGContextRef)context
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

- (void)drawPathOnShapeLayer:(FDPath *)path withContext:(CGContextRef)context
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
        [self.shapeLayer setFillColor:[[UIColor redColor] CGColor]];
        [self.shapeLayer setPath: pathRef];

    }
}

- (void) drawPathOnBackgroundLayer:(FDPath *)path withContext:(CGContextRef)context
{
    return;
    
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
        [self.shapeLayerBackground setFillColor:[[UIColor clearColor] CGColor]];
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
    self.currentPath = [[FDPath alloc] initWithColor:self.drawColor];
    CGPoint touchPoint = [gestureRecognizer locationInView: self];
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
    [self.paths addObject:self.currentPath];
    
    // draw completed path on its own shape layer
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    [self drawPathOnShapeLayer: layer withPath: self.currentPath withContext:context];
    [self.layer addSublayer: layer];
    
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

- (CAShapeLayer *) hitTestOnShapeLayer: (CGPoint) point withEvent:(UIEvent *)event
{
    for (CAShapeLayer *layer in self.layer.sublayers)
    {
        // if (CGPathContainsPoint([(CAShapeLayer *)self.layer.mask path], NULL, p, YES) )
        if (CGPathContainsPoint( layer.path, NULL, point, YES))
        {
            return layer;
        }
    }
    return nil;
}


@end
