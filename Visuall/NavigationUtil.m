//
//  NavigationUtil.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NavigationUtil.h"

@implementation NavigationUtil

+(id)sharedManager {
    
    static NavigationUtil *sharedMyManager = nil;
    
//    sharedMyManager.scale = 1.0;
    
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

-(void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer withNotes:(NSArray *)Notes
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        
        for (UITextField *hw in Notes) {
            float x = hw.center.x;
            float y = hw.center.y;
            float newX = x + translation.x;
            float newY = y + translation.y;
            hw.center = CGPointMake(newX, newY);
        }
    }
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer withNotes:(NSArray *)Notes
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.scale = gestureRecognizer.scale;
        NSLog(@"0. UIGestureRecognizerStateBegan");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = gestureRecognizer.scale;
        CGPoint centerPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        NSLog(@"1. scale: %f", scale);
        NSLog(@"2. self.scale: %f", self.scale);
        for (UITextField *hw in Notes) {
            float x = hw.center.x;
            float y = hw.center.y;
            float deltaX = x - centerPoint.x;
            float deltaY = y - centerPoint.y;
            float newX = centerPoint.x + deltaX / self.scale * scale;
            float newY = centerPoint.y + deltaY / self.scale * scale;
            [hw setTransform:CGAffineTransformScale(hw.transform, scale / self.scale, scale / self.scale)];
//            NSLog(@"OLD: %f, %f", x, y);
//            NSLog(@"scale: %f", scale);
//            NSLog(@"NEW: %f, %f", newX, newY);
            hw.center = CGPointMake(newX, newY);
        }
//        gestureRecognizer setScale:<#(CGFloat)#>
        self.scale = scale;
        NSLog(@"3. scale: %f", scale);
        NSLog(@"4. self.scale: %f", self.scale);

    }
}

@end
