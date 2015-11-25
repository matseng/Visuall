//
//  Note.h
//  Visuall
//
//  Created by John Mai on 11/20/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Note : NSManagedObject

- (void) setCenterPoint:(CGPoint) point;
- (void) setCenterX:(float)pointX andCenterY:(float)pointY;
- (void) setHeight:(float)height andWidth:(float)width;

@end

NS_ASSUME_NONNULL_END

#import "Note+CoreDataProperties.h"
