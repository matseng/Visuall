//
//  ViewController+Arrow.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController+Arrow.h"
#import "ArrowItem.h"

@implementation ViewController (Arrow)

- (void) panHandlerForDrawArrow: (UIPanGestureRecognizer *) gestureRecognizer
{
    
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            [ArrowItem setStartPoint: [gestureRecognizer locationInView: self.ArrowsView]];
        }
        
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint endPoint = [gestureRecognizer locationInView: self.ArrowsView];
            [self.NotesView.layer addSublayer:[ArrowItem makeArrowFromStartPointToEndPoint: endPoint]];  // temporarily added arrow to NotesView for aesthetics only
        }
    
        // State ended
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            ArrowItem *ai = [[ArrowItem alloc] initArrowFromStartPointToEndPoint];
            [self.ArrowsView addSubview: ai];
            // TODO (Aug 25, 2016): draw the arrow in arrows view, save the arrow in firebase, add handlers... and more?
//            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
//            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
//            GroupItem *currentGroupItem = [[GroupItem alloc] initWithRect: self.drawGroupView.frame];
//            [self addGroupItemToMVC: currentGroupItem];
            
        }
    
    
}



@end
