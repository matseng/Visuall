//
//  Collection.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/29/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VisualItem.h"

@interface Collection : NSObject

@property NSMutableDictionary *items;

- (void) addItem:(VisualItem *) vi withKey: (NSString *) key;

- (void) myForIn: (void (^)(VisualItem *vi)) myFunction;

- (VisualItem *) getItemFromKey: (NSString *) key;

- (BOOL) deleteItemGivenKey: (NSString *) key;

@end
