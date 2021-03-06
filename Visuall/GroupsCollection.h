//
//  GroupsCollection.h
//  Visuall
//
//  Created by John Mai on 11/24/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupItem.h"
#import "Collection.h"

@interface GroupsCollection : Collection

//@property NSMutableArray *groups;

//@property NSMutableDictionary *groups2;

//- (void) initializeGroups;
//- (void) addGroup:(GroupItem *)newGroup;

- (void) addGroup:(GroupItem *) newGroup withKey: (NSString *) key;

- (void) myForIn: (void (^)(GroupItem *gi)) myFunction;

- (GroupItem *) getGroupItemFromKey: (NSString *) key;

- (float) getGroupAreaFromKey: (NSString *) key;

- (BOOL) deleteGroupGivenKey: (NSString *) key;

@end
