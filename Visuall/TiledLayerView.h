//
//  TiledLayerView.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/18/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ViewController.h"

@interface TiledLayerView : UIView

@property UIView *hitTestView;

- (UIView *) hitTestOnNotes:(CGPoint)point withEvent:(UIEvent *) event;

@end
