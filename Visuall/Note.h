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
//- (instancetype) initWithString: (NSString *)text;
//- (instancetype) initWithString: (NSString *)text andCenterX: (float)pointX andCenterY: (float)pointY;
//- (void) centerPoint:(CGPoint) point;
//- (void) setCenterX:(float)pointX CenterY:(float)pointY;
+ (NSManagedObjectContext *) getMOC;
@end

NS_ASSUME_NONNULL_END

#import "Note+CoreDataProperties.h"
