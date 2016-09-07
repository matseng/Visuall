//
//  EdgeItem.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "VisualItem.h"
#import "Arrow.h"
#import "NoteItem2.h"


@interface ArrowItem : VisualItem

@property Arrow *arrow;

@property NSString *key;
@property NoteItem2 *startItem;
@property NoteItem2 *endItem;
@property CGPoint startPoint;
@property CGPoint endPoint;
@property CGFloat tailWidth;
@property CGFloat headWidth;
@property CGFloat headLength;
@property UIView *headHandle;
@property UIView *tailHandle;
//@property CGFloat headInnerLength;  // TODO (Aug 26, 2016): make arrow trapezoid-like if tail and head substantially different sizes

+ (void) setStartPoint: (CGPoint) aPoint;

+ (CGPoint) getStartPoint;

+ (CAShapeLayer *) makeArrowFromStartPointToEndPoint: (CGPoint) endPoint;

- (instancetype) initArrowFromStartPointToEndPoint;

- (instancetype) initArrowFromFirebase: (NSString *) key andValue: (NSDictionary *) value;

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer;

- (void) setViewAsSelected;

- (void) setViewAsNotSelected;

- (void) translateArrowByDelta: (CGPoint) translation;

- (void) translateArrowTailByDelta: (CGPoint) translation;

- (void) translateArrowHeadByDelta: (CGPoint) translation;

- (BOOL) isHandle: (UIView*) handle;

- (UIView *) hitTestWithHandles: (CGPoint) point;

- (void) increaseSize;

- (void) decreaseSize;

@end
