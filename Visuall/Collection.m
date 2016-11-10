//
//  Collection.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "Collection.h"

@implementation Collection

- (void) addItem:(VisualItem *) vi withKey: (NSString *) key
{
    if ( !self.items) {
        self.items = [[NSMutableDictionary alloc] init];
    }
    vi.key = key;
    self.items[key] = vi;
}

- (void) myForIn: (void (^)(id vi)) myFunction
{
    for (NSString *key in self.items) {
        VisualItem *vi = self.items[key];
        myFunction(vi);
    }
}

- (NSObject *) getItemFromKey: (NSString *) key
{
    return self.items[key];
}

- (BOOL) deleteItemGivenKey: (NSString *) key
{
    if ([self.items objectForKey: key]) {
        [self.items removeObjectForKey: key];
        return YES;
    }
    return NO;
}

@end
