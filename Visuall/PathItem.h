//
//  DrawItem.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 10/31/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FDPath.h"

@interface PathItem : CAShapeLayer

@property NSString *key;

@property FDPath *fdpath;

@property BOOL isPoint;

- (instancetype) initPathFromFirebase: (NSString *) key andValue: (NSDictionary *) value;

- (void) drawPathOnSelf;

- (void) increaseLineWidth;

@end
