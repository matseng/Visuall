//
//  ViewController+panHandler.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/11/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (panHandler)

- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer;

- (void) panHandlerForScrollViewButtonList: (UIPanGestureRecognizer *) gestureRecognizer;

@end
