//
//  Edge.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Arrow : NSObject

@property NSString *sourceKey;

@property NSString *targetKey;

@property CGPoint sourcePoint;

@property CGPoint targetPoint;

@property float length;

@property float width;

@end
