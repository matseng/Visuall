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
@property NoteItem2 *startNote;
@property NoteItem2 *endNote;
@property CGPoint startPoint;
@property CGPoint endPoint;
@property CGFloat tailWidth;
@property CGFloat headWidth;
@property CGFloat headLength;
//@property CGFloat headInnerLength;  // TODO (Aug 26, 2016): make arrow trapezoid-like if tail and head substantially different sizes

+ (void) setStartPoint: (CGPoint) aPoint;

+ (CGPoint) getStartPoint;

+ (CAShapeLayer *) makeArrowFromStartPointToEndPoint: (CGPoint) endPoint;

- (instancetype) initArrowFromStartPointToEndPoint;

- (instancetype) initArrowFromFirebase: (NSString *) key andValue: (NSDictionary *) value;

@end
