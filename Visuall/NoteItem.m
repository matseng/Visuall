//
//  NoteView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/12/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NoteItem.h"

@implementation NoteItem 

- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        
        [gestureRecognizer.view setTransform:
         CGAffineTransformTranslate(gestureRecognizer.view.transform, translation.x, translation.y)];
        [gestureRecognizer setTranslation: CGPointZero inView:gestureRecognizer.view];
        NSLog(@"%f, %f", translation.x, translation.y);
    }
}

@end
