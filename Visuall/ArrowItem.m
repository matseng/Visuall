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

#define TAIL_WIDTH 4.0
#define HEAD_WIDTH 24.0
#define HEAD_LENGTH 24.0

static CGPoint __startPoint;  // class variables http://rypress.com/tutorials/objective-c/classes
static CGPoint __endPoint;
static CAShapeLayer *__tempShapeLayer;

@interface ArrowItem ()

@property float length;
@property CAShapeLayer *arrowLayer;
@property UIColor *borderColor;
@property UIView *headHandle;

@end


@implementation ArrowItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void) setStartPoint: (CGPoint) aPoint
{
    __startPoint = aPoint;
}

+ (CGPoint) getStartPoint
{
    return __startPoint;
}

/*
 * Name:
 * Description: Class method used to temporarily draw an arrow
 * http://stackoverflow.com/questions/13528898/how-can-i-draw-an-arrow-using-core-graphics
 */
+ (CAShapeLayer *) makeArrowFromStartPointToEndPoint: (CGPoint) endPoint
{
    CGFloat tailWidth;
    CGFloat headWidth;
    CGFloat headLength;
    UIBezierPath *path;
    
    if (__tempShapeLayer) [__tempShapeLayer removeFromSuperlayer];
    
    UIGraphicsBeginImageContext( CGSizeMake(1, 1) );  // required to avoid errors 'invalid context 0x0.'
    
//    [[UIColor redColor] setStroke];
    
    tailWidth = 4;
    headWidth = 8 * 3;
    headLength = 8 * 3;
    path = [UIBezierPath bezierPathWithArrowFromPoint:(CGPoint)__startPoint
                                              toPoint:(CGPoint)endPoint
                                            tailWidth:(CGFloat)tailWidth
                                            headWidth:(CGFloat)headWidth
                                           headLength:(CGFloat)headLength];
    [path setLineWidth:2.0];
    [path stroke];
    
    CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
    [shapeView setPath: path.CGPath];
    __endPoint = endPoint;
    __tempShapeLayer = shapeView;
    return shapeView;
}

- (instancetype) initArrowFromFirebase: (NSString *) key andValue: (NSDictionary *) value
{
    self = [super init];
    if (self) {
//        self.startNote = [[[[UserUtil sharedManager] getState] notesCollection] getNoteItemFromKey:value[@"data"][@"startNoteKey"]];
//        self.endNote = [[[[UserUtil sharedManager] getState] notesCollection] getNoteItemFromKey:value[@"data"][@"endNoteKey"]];
        self.startItem = [[[UserUtil sharedManager] getState] getItemFromKey: value[@"data"][@"startItemKey"]];
        self.endItem = [[[UserUtil sharedManager] getState] getItemFromKey: value[@"data"][@"endItemKey"]];
        self.startPoint = CGPointMake( [value[@"data"][@"startX"] floatValue], [value[@"data"][@"startY"] floatValue]);
        self.endPoint = CGPointMake( [value[@"data"][@"endX"] floatValue], [value[@"data"][@"endY"] floatValue]);
        self.tailWidth = [value[@"data"][@"tailWidth"] floatValue];
        self.headWidth = [value[@"data"][@"headWidth"] floatValue];
        self.headLength = [value[@"data"][@"headLength"] floatValue];
        self.borderColor = [UIColor whiteColor];
        [self addArrowSublayer];
    }
    return self;
}

- (instancetype) initArrowFromStartPointToEndPoint
{
    self = [super init];
    if (self) {
        
        self.startItem = [self hitTestOnNotesAndGroups: __startPoint];
        self.endItem = [self hitTestOnNotesAndGroups: __endPoint];
        self.startPoint = __startPoint;
        self.endPoint = __endPoint;
        self.tailWidth = TAIL_WIDTH;
        self.headWidth = HEAD_WIDTH;
        self.headLength = HEAD_LENGTH;
        self.borderColor = [UIColor blueColor];
        
        if (__tempShapeLayer) [__tempShapeLayer removeFromSuperlayer];
        [[[UserUtil sharedManager] getState] setSelectedVisualItem: self];
        [self addArrowSublayer];
    }
    return self;
}

- (void) addArrowSublayer
{
    UIBezierPath *path;
    UIGraphicsBeginImageContext( CGSizeMake(1, 1) );  // required to avoid errors 'invalid context 0x0.'
    float theta;
    self.transform = CGAffineTransformIdentity;
    
    CGPoint point = CGPointMake(self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y);
    self.length = sqrtf( powf(point.x, 2) + powf(point.y, 2));
    CGPoint localStartPoint = CGPointMake(0, self.headWidth/2);
    CGPoint localEndPoint = CGPointMake(self.length, self.headWidth/2);

    float offsetCenterX = point.x / 2 - self.length / 2;
    float offsetCenterY = point.y / 2;
    CGRect rect = CGRectMake(self.startPoint.x + offsetCenterX, self.startPoint.y - self.headWidth/2 + offsetCenterY , self.length, self.headWidth);
    self.frame = rect;
    self.x = rect.origin.x;
    self.y = rect.origin.y;
//    self.backgroundColor = [UIColor greenColor];
    self.alpha = 1.0;
    
    path = [UIBezierPath bezierPathWithArrowFromPoint:(CGPoint)localStartPoint
                                              toPoint:(CGPoint)localEndPoint
                                            tailWidth:(CGFloat)self.tailWidth
                                            headWidth:(CGFloat)self.headWidth
                                           headLength:(CGFloat)self.headLength];
    [path setLineWidth:2.0];
    [path stroke];
    
    CAShapeLayer *arrowLayer = [[CAShapeLayer alloc] init];
    [arrowLayer setFillColor: [UIColor blackColor].CGColor];
//    if ( [[[UserUtil sharedManager] getState] selectedVisualItem] == self )
//    {
//        [arrowLayer setStrokeColor: [UIColor blueColor].CGColor];
//    } else {
//        [arrowLayer setStrokeColor: [UIColor whiteColor].CGColor];
//    }
    [arrowLayer setStrokeColor: self.borderColor.CGColor];
    
    [arrowLayer setPath: path.CGPath];
    
    [self.layer addSublayer: arrowLayer];
    self.arrowLayer = arrowLayer;
    
    theta = atan2( point.y, point.x );
    self.transform = CGAffineTransformMakeRotation( theta );
}

/*
- (void) __addArrowSublayer
{
    UIBezierPath *path;
    
    UIGraphicsBeginImageContext( CGSizeMake(1, 1) );  // required to avoid errors 'invalid context 0x0.'
    
    CGRect rect = [self createGroupViewRect: self.startPoint withEndPoint: self.endPoint];
    rect = [self augmentRectSize: rect];
    self.frame = rect;
    self.x = rect.origin.x;
    self.y = rect.origin.y;
//    self.backgroundColor = [UIColor greenColor];
    self.alpha = 0.5;
    
    CGPoint localStartPoint = CGPointMake(self.startPoint.x - rect.origin.x, self.startPoint.y - rect.origin.y);
    CGPoint localEndPoint = CGPointMake(self.endPoint.x - rect.origin.x, self.endPoint.y - rect.origin.y);

    
    [[UIColor redColor] setStroke];
    
    path = [UIBezierPath bezierPathWithArrowFromPoint:(CGPoint)localStartPoint
                                              toPoint:(CGPoint)localEndPoint
                                            tailWidth:(CGFloat)self.tailWidth
                                            headWidth:(CGFloat)self.headWidth
                                           headLength:(CGFloat)self.headLength];
    [path setLineWidth:2.0];
    [path stroke];
    
    CAShapeLayer *shapeView = [[CAShapeLayer alloc] init];
    [shapeView setStrokeColor: [UIColor redColor].CGColor];
    [shapeView setPath: path.CGPath];
    [self.layer addSublayer: shapeView];
}
 */

- (id) hitTestOnNotesAndGroups: (CGPoint) point
{
    StateUtilFirebase *state = [[UserUtil sharedManager] getState];
    CGPoint convertedPoint = [[state BoundsTiledLayerView] convertPoint:point fromView: [state ArrowsView]];
    UIView *view = [[state BoundsTiledLayerView] hitTest: convertedPoint withEvent:nil];
    if( [view isNoteItem])
    {
        return [view getNoteItem];
    }
    if( [view isGroupItem] )
    {
        return [view getGroupItem];
    }
    return nil;

}

- (CGRect) createGroupViewRect:(CGPoint)start withEndPoint:(CGPoint)end {
    float x1 = start.x < end.x ? start.x : end.x;
    float y1 = start.y < end.y ? start.y : end.y;
    
    float x2 = start.x < end.x ? end.x : start.x;
    float y2 = start.y < end.y ? end.y : start.y;
    
    float width = x2 - x1;
    float height = y2 - y1;
    
    return CGRectMake(x1, y1, width, height);
}

- (CGRect) augmentRectSize: (CGRect) rect
{
    if ( rect.size.width < rect.size.height)  // TODO (Aug 25, 2016): Instead of augmenting the size of box, rotate the view instead via a transform
    {
        if (rect.size.width < 2 * self.headWidth)
        {
            rect.origin.x = rect.origin.x - 0.5 * self.headWidth;
            rect.size.width = 2 * self.headWidth;
        } else {
            rect.origin.x = rect.origin.x - 0.25 * self.headWidth;
            rect.size.width = rect.size.width + 0.5 * self.headWidth;
        }
    } else {
        if (rect.size.height < 2 * self.headWidth)
        {
            rect.origin.y = rect.origin.y - 0.5 * self.headWidth;
            rect.size.height = 2 * self.headWidth;
        } else {
            rect.origin.y = rect.origin.y - 0.25 * self.headWidth;
            rect.size.height = rect.size.height + 0.5 * self.headWidth;
        }
    }
    return rect;
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView: [[[UserUtil sharedManager] getState] ArrowsView]];
    self.startPoint = CGPointMake(self.startPoint.x + translation.x, self.startPoint.y + translation.y);
    self.endPoint = CGPointMake(self.endPoint.x + translation.x, self.endPoint.y + translation.y);
    self.transform = CGAffineTransformTranslate( CGAffineTransformIdentity, self.transform.tx + translation.x, self.transform.ty + translation.y);
    
    CGPoint point = CGPointMake(self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y);
    float theta = atan2( point.y, point.x );
    self.transform = CGAffineTransformRotate(self.transform, theta);
    
    [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
}

- (void) addHandles
{
    UIView *handle = [self makeHandle];
    self.headHandle = handle;
    CGRect rect = handle.frame;
    rect.origin.x = (self.length - self.headLength/2) - rect.size.width/2;
    rect.origin.y = self.headWidth / 2 - rect.size.height /2;
    handle.frame = rect;
    [self addSubview: handle];
    
}

- (UIView *) makeHandle
{
    float diameter = (self.headWidth > self.headLength) ? self.headWidth : self.headLength;
    diameter = diameter * 1.5;
    UIView *circleView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, diameter, diameter)];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = diameter / 2;
    circleView.layer.backgroundColor = [self.borderColor CGColor];
    return circleView;
}

- (void) setViewAsSelected
{
    [self setViewAsNotSelected];
    self.borderColor = [UIColor blueColor];
    if ( [[[UserUtil sharedManager] getState] editModeOn] )
    {
        [self addHandles];
    }
    [self addArrowSublayer];
//    self.backgroundColor = [UIColor greenColor];
}

- (void) setViewAsNotSelected
{
    [self.arrowLayer removeFromSuperlayer];
    [self.headHandle removeFromSuperview];
    self.borderColor = [UIColor whiteColor];
    [self addArrowSublayer];
}

@end
