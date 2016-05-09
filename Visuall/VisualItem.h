//
//  VisualItem.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VisualItem : UIView

@property float x;
@property float y;
@property float width;
@property float height;

-(void) setX:(float)x andY:(float)y andWidth: (float) width andHeight:(float) height;

- (BOOL) isNote;

@end
