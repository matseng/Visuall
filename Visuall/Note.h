//
//  Note.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/9/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface Note : NSObject

@property CGPoint centerPoint;
@property NSString *text;

- (instancetype) initWithString: (NSString *) string andCenterX: (float) centerX andCenterY: (float) centerY;

@end
