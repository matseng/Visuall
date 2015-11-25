//
//  GroupsCollection.h
//  Visuall
//
//  Created by John Mai on 11/24/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupItem.h"

@interface GroupsCollection : NSObject
@property NSMutableArray *groups;
- (void) initializeGroups;
- (void) addGroup:(GroupItem *)newGroup;

@end
