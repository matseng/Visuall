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
//@property (nonatomic, strong) FDPath *currentPath;

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

- (void) __addPathItemToMVCandFirebase: (PathItem *) pi
{
    self.selectedPath = pi;
    [[[UserUtil sharedManager] getState] setValuePath: pi];  // save to firebase and add to collection within
    [self addPathItemToMVC: pi];
    // [self highlightSelectedPath];
}

- (void) addPathItemToMVC: (PathItem *) pi
{
    [[[[UserUtil sharedManager] getState] pathsCollection] addItem: pi withKey: pi.key];
    NSLog(@"\n addPathItemToMVC: key: %@", pi.key);
    [pi drawPathOnSelf];
    [self.layer addSublayer: pi];
}

- (void) deleteSelectedPath
{
    // TODO (Dec 14, 2016): Remove from collection, view, firebase and self
    PathItem *pi = self.selectedPath;
    [self deletePath: pi];
    [self removeHighlightFromPreviouslySelectedPath];
    self.selectedPath = nil;
}

- (void) deletePath: (PathItem *) pi
{
    if ( [pi isEqual: self.selectedPath] )
    {
        [self removeHighlightFromPreviouslySelectedPath];
    }
    [[[[UserUtil sharedManager] getState] pathsCollection] deleteItemGivenKey: pi.key];
    [pi removeFromSuperlayer];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
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

- (void) drawPathItemOnShapeLayer: (PathItem *) pi
{
    if (pi.isPoint)
    {
        [self drawPointFromPathItemOnShapeLayer: pi];
    } else
    {
//        [self drawPathOnShapeLayer: pi withPath: pi.fdpath withContext: context];
        //[self drawPathOnShapeLayer: pi];
        [pi drawPathOnSelf];
    }
}

- (void) drawPathOnShapeLayer: (PathItem *) pi
{
    FDPath *path = pi.fdpath;
    if (path.points.count > 1) {
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
        pi.strokeColor = [[UIColor blueColor] CGColor];
        pi.lineWidth = 4.0;
        [pi setFillColor: nil];
        [pi setPath: bzPath.CGPath];
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

- (void) drawPointFromPathItemOnShapeLayer: (PathItem *) pi
{
    FDPoint *point = pi.fdpath.points[0];
    [pi setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - self.lineWidth / 2, point.y - self.lineWidth / 2, self.lineWidth, self.lineWidth)] CGPath]];
    [pi setFillColor: [[UIColor blueColor] CGColor]];
}

- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer withPathItem: (PathItem *) pi
{
    CGPoint translation = [gestureRecognizer translationInView: [[[UserUtil sharedManager] getState] DrawView]];
    //    CGPoint translation = [gestureRecognizer translationInView: gestureRecognizer.view];
    [self translatePath: pi byPoint: translation];
    //    self.currentPath = pi.fdpath;
    //    [self setNeedsDisplay];
//    [self highlightPath: pi];
//    self.currentPath = pi.fdpath;
//    [self drawPathAndHighlight];
    [pi drawPathOnSelf];
    [self highlightPath: pi];
    [gestureRecognizer setTranslation:CGPointZero inView: [[[UserUtil sharedManager] getState] DrawView]];
    [[[UserUtil sharedManager] getState] updateValuePath: pi];  // update to firebase
    
}

- (void) translatePath: (PathItem *) pi byPoint: (CGPoint) translation
{
    for (NSUInteger i = 0; i < pi.fdpath.points.count; i++) {
        FDPoint *point = pi.fdpath.points[i];
        CGPoint translatedCGPoint = CGPointMake(point.x + translation.x, point.y + translation.y);
        FDPoint *translatedPoint = [[FDPoint alloc] initWithCGPoint: translatedCGPoint];
        pi.fdpath.points[i] = translatedPoint;
    }
//    [self drawPathItemOnShapeLayer: pi];
//    [self highlightPath: pi];
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
    self.shapeLayer = [[PathItem alloc] init];
    self.shapeLayer.fdpath = [[FDPath alloc] initWithColor:self.drawColor];
    self.shapeLayer.fdpath.color = [UIColor blueColor];
    self.shapeLayer.fdpath.lineWidth =  [[[UserUtil sharedManager] getState] pathLineWidth];
    
    CGPoint touchPoint = [gestureRecognizer locationInView: self];
    [self.shapeLayer.fdpath addPoint: [[[UserUtil sharedManager] getState] touchDownPoint]];
    [self.shapeLayer.fdpath addPoint:touchPoint];
    
    [self.shapeLayer drawPathOnSelf];
    [self.layer addSublayer: self.shapeLayer];
}

- (void) panChangedWithGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView: self];
    [self.shapeLayer.fdpath addPoint:touchPoint];
    [self.shapeLayer drawPathOnSelf];
    [self highlightPath: self.shapeLayer];
}

- (void) panEndedWithGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
{
    [[[UserUtil sharedManager] getState] setValuePath: self.shapeLayer];  // save to firebase and add to collection within
    self.hitTestPath = self.shapeLayer;
    self.selectedPath = self.shapeLayer;
    
    // notify the delegate
    [self.delegate drawView:self didFinishDrawingPath:self.shapeLayer.fdpath];
}

- (void) tapHandler: (UIGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.shapeLayer = [[PathItem alloc] init];
        self.shapeLayer.fdpath = [[FDPath alloc] initWithColor:self.drawColor];
        self.shapeLayer.fdpath.color = [UIColor blueColor];
        self.shapeLayer.fdpath.lineWidth =  [[[UserUtil sharedManager] getState] pathLineWidth];
        self.shapeLayer.fdpath.isCircle = YES;
//        CGPoint touchPoint = [gestureRecognizer locationInView: self];
//        [self.shapeLayer.fdpath addPoint: touchPoint];
        [self panChangedWithGestureRecognizer: gestureRecognizer];
        [self panEndedWithGestureRecognizer: gestureRecognizer];
        [self.layer addSublayer: self.shapeLayer];
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
        if ( layer.path && !layer.fdpath.isCircle)
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:layer.path];
            
            CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(layer.path,
                                                                     NULL,
                                                                     fmaxf(24.0f, layer.fdpath.lineWidth * 2.0),
                                                                     path.lineCapStyle,
                                                                     path.lineJoinStyle,
                                                                     path.miterLimit);
            if (tapTargetPath == NULL) {
                return nil;
            }
            
            UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:tapTargetPath];
            CGPathRelease(tapTargetPath);
            
            
            if ([tapTarget containsPoint:point])
            {
                self.hitTestPath = layer;
                return layer;
            }
        } else if (layer.path && layer.fdpath.isCircle)
        {
            FDPoint *fdpoint = [layer.fdpath getFirstPoint];
            double dist = hypot((point.x - fdpoint.x), (point.y - fdpoint.y));
            if (dist < self.lineWidth * 2.0)
            {
                self.hitTestPath = layer;
                return layer;
            }
            //            NSLog(@"\n dist: %f", dist);
        }
        counter++;
    }
    //    NSLog(@"\n layer counter: %i", counter);
    self.hitTestPath = nil;
    return nil;
}

- (void) setSelectedPathFromHitTestPath
{
    self.selectedPath = self.hitTestPath;
//    [self highlightSelectedPath];
    [self highlightPath: self.selectedPath];
}


- (void) highlightSelectedPath
{
    self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
    self.shapeLayerBackground.lineWidth = self.selectedPath.fdpath.lineWidth * 2;
    [self.shapeLayerBackground setFillColor: nil];
    [self.shapeLayerBackground setPath: self.selectedPath.path];
}

- (void) highlightPath: (PathItem *) pi
{
    self.shapeLayerBackground.strokeColor = [[UIColor yellowColor] CGColor];
    self.shapeLayerBackground.lineWidth = pi.fdpath.lineWidth * 2;
    [self.shapeLayerBackground setFillColor: nil];
    [self.shapeLayerBackground setPath: pi.path];
}

- (void) removeHighlightFromPreviouslySelectedPath
{
    self.shapeLayerBackground.lineWidth = 0;
}

@end
