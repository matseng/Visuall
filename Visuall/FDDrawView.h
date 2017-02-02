//
//  FDDrawView.h
//  Firebase Drawing
//
//  Created by Jonny Dimond on 8/14/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDPath.h"
#import "PathItem.h"

@class FDDrawView;

@protocol FDDrawViewDelegate <NSObject>

// called when a user finished drawing a line/path
- (void)drawView:(FDDrawView *)view didFinishDrawingPath:(FDPath *)path;

@end

@interface FDDrawView : UIView

// the color that is used to draw lines
@property (nonatomic, strong) UIColor *drawColor;

@property (nonatomic, strong) PathItem *hitTestPath;

@property (nonatomic, strong) PathItem *selectedPath;

@property (nonatomic, strong) PathItem *previouslySelectedPath;

// the delegate that is notified about any drawing by the user
@property (nonatomic, weak) id<FDDrawViewDelegate> delegate;

// adds a path to display to this view
- (void) addPath:(FDPath *)path;

- (void) tapHandler: (UIGestureRecognizer *) gestureRecognizer;

- (void) panHandler: (UIGestureRecognizer *) gestureRecognizer;

- (void) panHandler: (UIPanGestureRecognizer *) gestureRecognizer withPathItem: (PathItem *) pi;

- (PathItem *) hitTestOnShapeLayer: (CGPoint) point withEvent:(UIEvent *)event;

- (void) addPathItemToMVC: (PathItem *) pi;

- (void) highlightSelectedPath;

- (void) removeHighlightFromPreviouslySelectedPath;

- (void) deleteSelectedPath;

- (void) deletePath: (PathItem *) pi;

- (void) setSelectedPathFromHitTestPath;

@end
