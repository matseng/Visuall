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

- (void) setX:(float)x andY:(float) y andWidth: (float) width andHeight:(float) height;

- (BOOL) isNote;

- (NSString *) getKey; // NOTE: my naive implementatin of a protocol declaration - see NoteItem2.m for 'delegate' implementation

@end
