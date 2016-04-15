//
//  Group.h
//  Visuall
//
//  Created by John Mai on 11/23/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Note.h"

@class Note;

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSManagedObject

@property Note *titleNote;

@property NSMutableArray *childNotes;

@property NSMutableArray *childGroups;


- (void) setTopPoint:(CGPoint) point;
- (void) setTopX:(float)pointX andTopY:(float)pointY;
- (void) setHeight:(float)height andWidth:(float)width;

@end

NS_ASSUME_NONNULL_END

#import "Group+CoreDataProperties.h"
