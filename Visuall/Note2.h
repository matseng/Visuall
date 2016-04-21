//
//  Note2.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/15/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Group2.h"

@interface Note2 : NSObject

@property NSString *key;
@property NSString *title;
@property float x;
@property float y;
@property float width;
@property float height;
@property float fontSize;
@property NSString *parentGroupKey;
//@property Group2 *parentGroup;

@end

/*
 @property (nullable, nonatomic, retain) NSNumber *centerX;
 @property (nullable, nonatomic, retain) NSNumber *centerY;
 @property (nullable, nonatomic, retain) NSNumber *height;
 @property (nullable, nonatomic, retain) NSString *imageName;
 @property (nullable, nonatomic, retain) NSString *imagePath;
 @property (nullable, nonatomic, retain) NSString *paragraph;
 @property (nullable, nonatomic, retain) NSString *title;
 @property (nullable, nonatomic, retain) NSNumber *width;
 @property (nullable, nonatomic, retain) id color;
 
 @property float fontSize;
 @property float x;
 @property float y;
*/