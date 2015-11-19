//
//  NoteView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/12/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NoteItem.h"

@implementation NoteItem 

//- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
//        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
//        
//        [gestureRecognizer.view setTransform:
//         CGAffineTransformTranslate(gestureRecognizer.view.transform, translation.x, translation.y)];
//        [gestureRecognizer setTranslation: CGPointZero inView:gestureRecognizer.view];
//        NSLog(@"%f, %f", translation.x, translation.y);
//    }
//}

//-(void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer withNotes:(NSArray *)Notes
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
//        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
//        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
//        
//        for (UITextField *hw in Notes) {
//            float x = hw.center.x;
//            float y = hw.center.y;
//            float newX = x + translation.x;
//            float newY = y + translation.y;
//            hw.center = CGPointMake(newX, newY);
//        }
//    }
//}

- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];

        float x = self.center.x + translation.x;
        float y = self.center.y + translation.y;
        
        self.center = CGPointMake(x, y);
        
        NSLog(@"%f, %f", translation.x, translation.y);
    }
}

@end
