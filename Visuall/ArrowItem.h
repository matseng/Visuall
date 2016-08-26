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

+ (void) setStartPoint: (CGPoint) aPoint;

+ (CGPoint) getStartPoint;

- (instancetype) initArrowFromStartPointToEndPoint;

+ (CAShapeLayer *) makeArrowFromStartPointToEndPoint: (CGPoint) endPoint;

- (CAShapeLayer *) makeArrowFromStartPointToEndPoint: (CGPoint) endPoint;

- (instancetype) initArrowFromStartPointToEndPoint: (CGPoint) endPoint;

- (instancetype) initArrowWithPoints: (CGPoint) pointA and: (CGPoint) pointB;

- (instancetype) initArrowWithSourceNoteItem: (NoteItem2*) ni0 andTargetNoteItem: (NoteItem2*) ni1;

@end
