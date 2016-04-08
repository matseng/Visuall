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

@interface NoteItem2 : VisualItem

@property Note *note;
@property UITextView *noteTextView;

- (instancetype) initNote:(Note *)note;

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer;

- (void) translateTx: (float) tx andTy: (float) ty;

- (void) saveToCoreData;

@end
