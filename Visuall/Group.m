//
//  Group.m
//  Visuall
//
//  Created by John Mai on 11/23/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "Group.h"
#import "Note.h"
#import "AppDelegate.h"

@implementation Group

- (void) setTopPoint: (CGPoint)point
{
    self.topX = [NSNumber numberWithFloat:point.x];
    self.topY = [NSNumber numberWithFloat:point.y];
}

- (void) setTopX:(float)pointX andTopY:(float)pointY
{
    self.topX = [NSNumber numberWithFloat:pointX];
    self.topY = [NSNumber numberWithFloat:pointY];
}

- (void) setHeight:(float)height andWidth:(float)width
{
    self.height = [NSNumber numberWithFloat:height];
    self.width = [NSNumber numberWithFloat:width];
}

+ (NSManagedObjectContext *) getMOC {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

@end
