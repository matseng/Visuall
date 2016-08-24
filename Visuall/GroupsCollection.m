//
//  GroupsCollection.m
//  Visuall
//
//  Created by John Mai on 11/24/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "GroupsCollection.h"
#import "GroupItem.h"
#import "AppDelegate.h"

@implementation GroupsCollection

//- (void) initializeGroups {
//    
//    self.groups = [NSMutableArray new];
//    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
//    
//    NSArray *groupsCD = [moc executeFetchRequest:request error:nil];
//    NSLog(@"Fetching Groups from Core Data...found %d groups", groupsCD.count);
//    
//    for (Group *group in groupsCD)
//    {
//        [self.groups addObject:[[GroupItem alloc] initGroup: group]];
//    }
//}


//- (void) addGroup:(GroupItem *) newGroup {
//    [self.groups addObject: newGroup];
//}

- (void) addGroup:(GroupItem *) newGroup withKey: (NSString *) key
{
    if ( !self.groups2) {
        self.groups2 = [[NSMutableDictionary alloc] init];
    }
    newGroup.group.key = key;
    self.groups2[key] = newGroup;
}

- (void) myForIn: (void (^)(GroupItem *gi)) myFunction
{
    for (NSString *key in self.groups2) {
        GroupItem *gi = self.groups2[key];
        myFunction(gi);
    }
}

- (GroupItem *) getGroupItemFromKey: (NSString *) key
{
    return self.groups2[key];
}

- (float) getGroupAreaFromKey: (NSString *) key
{
    return [[self.groups2[key] group] getArea];
}

- (BOOL) deleteGroupGivenKey: (NSString *) key
{
    if([self.groups2 objectForKey: key]) {
        [self.groups2 removeObjectForKey: key];
        return YES;
    }
    return NO;
    
}

@end
