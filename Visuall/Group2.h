//
//  Group2.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/19/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note2.h"

@interface Group2 : NSObject

@property NSString *key;
@property float x;
@property float y;
@property float width;
@property float height;
//@property Note2 *titleNote;
@property NSString *titleNoteKey;

- (void) setX:(float)pointX andY:(float)pointY;

- (void) setWidth:(float)width andHeight:(float)width;

- (float) getArea;

@end


//@interface Group (CoreDataProperties)
//
//@property (nullable, nonatomic, retain) NSNumber *height;
//@property (nullable, nonatomic, retain) NSString *title;
//@property (nullable, nonatomic, retain) NSNumber *topX;
//@property (nullable, nonatomic, retain) NSNumber *topY;
//@property (nullable, nonatomic, retain) NSNumber *width;
//@property (nullable, nonatomic, retain) id bgcolor;
//@property (nullable, nonatomic, retain) NSNumber *alpha;
//@property (nullable, nonatomic, retain) id bordercolor;
//@property (nullable, nonatomic, retain) NSNumber *borderwidth;
//@property (nullable, nonatomic, retain) NSSet<Note *> *note;
//
//@end
//
//@interface Group (CoreDataGeneratedAccessors)
//
//- (void)addNoteObject:(Note *)value;
//- (void)removeNoteObject:(Note *)value;
//- (void)addNote:(NSSet<Note *> *)values;
//- (void)removeNote:(NSSet<Note *> *)values;
//
//@end


//@interface Note2 : NSObject
//
//@property NSString *key;
//@property NSString *title;
//@property float x;
//@property float y;
//@property float width;
//@property float height;
//@property float fontSize;
//@property NSString *parentGroup;
//
//@end