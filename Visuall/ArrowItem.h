//
//  EdgeItem.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "VisualItem.h"
#import "Arrow.h"
#import "NoteItem2.h"


@interface ArrowItem : VisualItem

@property Arrow *arrow;

- (instancetype) initArrowWithSourceNoteItem: (NoteItem2*) ni0 andTargetNoteItem: (NoteItem2*) ni1;

@end
