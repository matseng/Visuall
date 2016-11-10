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

@property FDPath *fdpath;

@property BOOL isPoint;

@property CGFloat lineWidth;

@end
