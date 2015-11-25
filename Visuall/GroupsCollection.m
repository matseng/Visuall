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

- (void) initializeGroups {
    
    self.groups = [NSMutableArray new];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
    
    NSArray *groupsCD = [moc executeFetchRequest:request error:nil];
    NSLog(@"Fetching Groups from Core Data...found %d groups", groupsCD.count);
    
    for (Group *group in groupsCD)
    {
        [self.groups addObject:[[GroupItem alloc] initGroup: group]];
    }
}


- (void) addGroup:(GroupItem *)newGroup {
    [self.groups addObject:newGroup];
}



@end
