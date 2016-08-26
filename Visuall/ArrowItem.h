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

@property NoteItem2 *startNote;
@property NoteItem2 *endNote;

+ (void) setStartPoint: (CGPoint) aPoint;

+ (CGPoint) getStartPoint;

+ (CAShapeLayer *) makeArrowFromStartPointToEndPoint: (CGPoint) endPoint;

- (instancetype) initArrowFromStartPointToEndPoint;

@end
