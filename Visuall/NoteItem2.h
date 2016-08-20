//
//  NoteItem2.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "VisualItem.h"
#import <UIKit/UIKit.h>
#import "Note+CoreDataProperties.h"
#import "Note2.h"


@interface NoteItem2 : VisualItem

@property Note2 *note;
@property UITextView *noteTextView;
@property float fontSizeScaleFactor;

//- (instancetype) initNote:(Note *) note;

- (instancetype) initNote:(NSString *) title withPoint:(CGPoint) point;

- (instancetype) initNoteFromFirebase: (NSString *) key andValue: (NSDictionary *) data;

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer;

- (void) translateTx: (float) tx andTy: (float) ty;

- (void) saveToCoreData;

- (void) resizeToFit: (NSString *) text;

- (void) setFontSize: (float) fontSize;

- (void) increaseFontSize;

- (void) decreaseFontSize;

- (void) scaleFontSize: (float) scalar;

- (CGPoint) getCenterPoint;

- (CGPoint) getRelativeCenterPoint;

- (void) transformVisualItem;

@end
