//
//  TouchDownGestureRecognizer.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 2/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "TouchDownGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UserUtil.h"
#import "FDDrawView.h"

@implementation TouchDownGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//     if ( [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
//     {
//         [[[[UserUtil sharedManager] getState] DrawView] touchesBegan: touches withEvent: event];
//         self.state = UIGestureRecognizerStateBegan;
//         return;
//     }
    if (self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateRecognized;
    }
}

/*
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
    {
        [[[[UserUtil sharedManager] getState] DrawView] touchesMoved: touches withEvent: event];
    }
//    self.state = UIGestureRecognizerStateFailed;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
    {
        [[[[UserUtil sharedManager] getState] DrawView] touchesEnded: touches withEvent: event];
    }

//    self.state = UIGestureRecognizerStateFailed;
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( [[[UserUtil sharedManager] getState] isDrawButtonSelected] )
    {
        [[[[UserUtil sharedManager] getState] DrawView] touchesCancelled: touches withEvent: event];
    }
    
//    self.state = UIGestureRecognizerStateFailed;
}
 */

@end
