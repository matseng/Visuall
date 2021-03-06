//
//  ViewController+Arrow.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+Arrow.h"
#import "ArrowItem.h"
#import "UserUtil.h"

@implementation ViewController (Arrow)

- (void) panHandlerForDrawArrow: (UIPanGestureRecognizer *) gestureRecognizer
{
    
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
//            [ArrowItem setStartPoint: [gestureRecognizer locationInView: self.ArrowsView]];
            [ArrowItem setStartPoint:[[[UserUtil sharedManager] getState] touchDownPoint]];
        }
        
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint endPoint = [gestureRecognizer locationInView: self.ArrowsView];
            [self.DrawArrowShapeLayer removeFromSuperlayer];
            self.DrawArrowShapeLayer = [ArrowItem makeArrowFromStartPointToEndPoint: endPoint];
            [self.NotesView.layer addSublayer: self.DrawArrowShapeLayer];  // temporarily added arrow to NotesView for aesthetics only
        }
    
        // State ended
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            [self.DrawArrowShapeLayer removeFromSuperlayer];
            ArrowItem *ai = [[ArrowItem alloc] initArrowFromStartPointToEndPoint];
            [self addArrowItemToMVC: ai];
        }
}

- (void) addArrowItemToMVC: (ArrowItem *) ai
{
    [self.ArrowsView addSubview: ai];
    if (ai) [[[UserUtil sharedManager] getState] setValueArrow: ai];
    [[[[UserUtil sharedManager] getState] arrowsCollection] addItem: ai withKey: ai.key];
    [self setSelectedObject: ai];
}

@end
