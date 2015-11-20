//
//  NavigationUtil.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "TransformUtil.h"
#import "NoteItem.h"

@implementation TransformUtil

+(id)sharedManager {
    
    static TransformUtil *sharedMyManager = nil;
    
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
            sharedMyManager.zoom = 1.0;
            sharedMyManager.pan = (CGPoint){0.0,0.0};
            NSLog(@"RESET ZOOM and PAN");
        }
    }
    return sharedMyManager;
}

-(void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer withNotes:(NSArray *)Notes
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        float panX = self.pan.x + translation.x;
        float panY = self.pan.y + translation.y;
        self.pan = CGPointMake(panX, panY);

        for (NoteItem *noteItem in Notes) {
            CGAffineTransform t = noteItem.transform;
            t.tx = 0;
            t.ty = 0;
            [noteItem setTransform:CGAffineTransformTranslate(t, self.pan.x, self.pan.y)];
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
        CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        NSLog(@"1. scale: %f", scale);
        NSLog(@"2. self.scale: %f", self.scale);
        for (UITextField *hw in Notes) {
            float x = hw.center.x;
            float y = hw.center.y;
            float deltaX = x - gesturePoint.x;
            float deltaY = y - gesturePoint.y;
            float newX = gesturePoint.x + deltaX / self.scale * scale;
            float newY = gesturePoint.y + deltaY / self.scale * scale;
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
