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

- (void) myForIn: (void (^)(VisualItem *vi)) myFunction
{
    for (NSString *key in self.items) {
        VisualItem *vi = self.items[key];
        myFunction(vi);
    }
}

- (VisualItem *) getItemFromKey: (NSString *) key
{
    return self.items[key];
}

@end
