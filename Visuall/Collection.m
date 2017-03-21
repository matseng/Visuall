//
//  Collection.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "Collection.h"

@implementation Collection

- (void) addItem: (id) vi withKey: (NSString *) key
{
    if ( !self.items) {
        self.items = [[NSMutableDictionary alloc] init];
    }
    
    if ( !key )
    {
        key = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    }
    
    if ( [vi isKindOfClass:[VisualItem class]] )
    {
        VisualItem *vi2 = (VisualItem *) vi;
        vi2.key = key;
    }
    
    self.items[key] = vi;
}

- (void) myForIn: (void (^)(id vi)) myFunction
{
    for (NSString *key in self.items) {
        VisualItem *vi = self.items[key];
        myFunction(vi);
    }
}

- (id) getItemFromKey: (NSString *) key
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

- (BOOL) isKeyInCollection: (NSString *) key
{
    if ( [self.items objectForKey: key] == nil )
    {
        return NO;
    }
    return YES;
}

@end
