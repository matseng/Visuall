//
//  Note+CoreDataProperties.h
//  Visuall
//
//  Created by John Mai on 11/25/15.
//  Copyright © 2015 Visuall. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *centerX;
@property (nullable, nonatomic, retain) NSNumber *centerY;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSString *imageName;
@property (nullable, nonatomic, retain) NSString *imagePath;
@property (nullable, nonatomic, retain) NSString *paragraph;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) id color;

@end

NS_ASSUME_NONNULL_END
