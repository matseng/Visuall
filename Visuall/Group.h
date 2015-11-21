//
//  Group.h
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface Group : NSObject
@property CGPoint coordinate;
@property float width;
@property float height;
@property NSMutableArray *NoteItems;

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height;

@end
