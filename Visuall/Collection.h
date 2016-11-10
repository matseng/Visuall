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

- (void) addItem: (id) vi withKey: (NSString *) key;

- (id) getItemFromKey: (NSString *) key;

- (void) myForIn: (void (^)(id vi)) myFunction;

- (BOOL) deleteItemGivenKey: (NSString *) key;

@end
