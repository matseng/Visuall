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
    if ( !self.items) {
        self.items = [[NSMutableDictionary alloc] init];
    }
    newGroup.group.key = key;
    newGroup.key = key;
    self.items[key] = newGroup;
}

//- (void) myForIn: (void (^)(GroupItem *gi)) myFunction
//{
//    for (NSString *key in self.items) {
//        GroupItem *gi = self.items[key];
//        myFunction(gi);
//    }
//}

- (GroupItem *) getGroupItemFromKey: (NSString *) key
{
    return self.items[key];
}

- (float) getGroupAreaFromKey: (NSString *) key
{
    return [[self.items[key] group] getArea];
}

- (BOOL) deleteGroupGivenKey: (NSString *) key
{
    if([self.items objectForKey: key]) {
        NSLog(@"\n %li", [[self items] count]);
        [self.items removeObjectForKey: key];
        NSLog(@"\n %li", [[self items] count]);
        return YES;
    }
    return NO;
    
}

@end
