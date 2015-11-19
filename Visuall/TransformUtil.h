//
//  NavigationUtil.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Note.h"
#import "NotesCollection.h"

@interface TransformUtil : NSObject

@property CGPoint translation;
@property float scale;
@property float scaleTest;

+(id)sharedManager;

-(void) handlePanBackground: (UIPanGestureRecognizer *) pan withNotes: (NSArray *) Notes;

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) pinch withNotes: (NSArray *) Notes;

@end


//@interface MyManager : NSObject {
//    NSString *someProperty;
//}
//
//@property (nonatomic, retain) NSString *someProperty;
//
//+ (id)sharedManager;
//
//@end