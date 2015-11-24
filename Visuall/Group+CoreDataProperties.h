//
//  Group+CoreDataProperties.h
//  Visuall
//
//  Created by John Mai on 11/23/15.
//  Copyright © 2015 Visuall. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *topX;
@property (nullable, nonatomic, retain) NSNumber *topY;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NSSet<Note *> *note;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addNoteObject:(Note *)value;
- (void)removeNoteObject:(Note *)value;
- (void)addNote:(NSSet<Note *> *)values;
- (void)removeNote:(NSSet<Note *> *)values;

@end

NS_ASSUME_NONNULL_END
