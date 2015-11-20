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
#import "NoteItem.h"
#import "NotesCollection.h"

@interface TransformUtil : NSObject

@property CGPoint translation;
@property float scale;
@property float scaleTest;

@property float zoom;
@property CGPoint pan;

@property float _relativeScale;


+(id)sharedManager;

-(void) handlePanBackground: (UIPanGestureRecognizer *) pan withNotes: (NSArray *) Notes;

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) pinch withNotes: (NSArray *) Notes;

-(void) transformNoteItem: (NoteItem *) noteItem;

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