//
//  GroupItemImage.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/22/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "GroupItem.h"

@interface GroupItemImage : GroupItem

@property UIImage *image;
@property UIImage *thumbnail;

- (instancetype) initGroupWithImage: (UIImage *) img andPoint: (CGPoint) point;

- (void) addImage: (UIImage *) img;

@end
