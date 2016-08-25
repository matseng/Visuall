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
    {
        /*
        GroupItem *gi = [self.activelySelectedObjectDuringPan getGroupItem];
        
        if ( ([self.lastSelectedObject getGroupItem] == [self.activelySelectedObjectDuringPan getGroupItem])  && [gi isHandle: self.activelySelectedObjectDuringPan] )
        {
            if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
            {
                
                [gi resizeGroup: gestureRecognizer];
                [self.visuallState updateChildValue:gi Property:@"frame"];
            }
            else
            {
                [self setActivelySelectedObjectDuringPan: nil];
            }
            return;
        }
         */
        
        
        // State began
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            [ArrowItem setStartPoint: [gestureRecognizer locationInView: self.ArrowsView]];
        }
        
        
        // State changed
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint endPoint = [gestureRecognizer locationInView: self.ArrowsView];
//            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
//            NSLog(@"\n handlePanArrow: %f, %f", [ArrowItem getStartPoint].x, [ArrowItem getStartPoint].y);
            ArrowItem *ai = [[ArrowItem alloc] initArrowFromStartPointToEndPoint: endPoint];
            [self.ArrowsView addSubview: ai];
        }
        /*
        // State ended
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGPoint currentGroupViewEnd = [gestureRecognizer locationInView: self.GroupsView];
            self.drawGroupView.frame = [self createGroupViewRect:self.drawGroupViewStart withEnd:currentGroupViewEnd];
            GroupItem *currentGroupItem = [[GroupItem alloc] initWithRect: self.drawGroupView.frame];
            [self addGroupItemToMVC: currentGroupItem];
        }
         */
    }
}



@end
