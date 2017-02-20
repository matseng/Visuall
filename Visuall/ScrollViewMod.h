//
//  ScrollViewMod.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/27/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class ScrollViewMod;

@interface ScrollViewMod : UIScrollView

@property BOOL zoomFromDoubleTapGesture;

@property BOOL isZoomedToRect;

@property UIView *doubleTapFocus;

- (void)scrollRectToVisibleSuperclass:(CGRect)rect animated:(BOOL)animated;

@end
