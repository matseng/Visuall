//
//  Group.m
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "Group.h"

@implementation Group

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
        self.coordinate = coordinate;
        self.width = width;
        self.height = height;
    }
    
    return self;
}

@end
