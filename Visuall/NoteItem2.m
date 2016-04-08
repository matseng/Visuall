//
//  NoteItem2.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "NoteItem2.h"

#import "Note+CoreDataProperties.h"
#import "TransformUtil.h"
#import "AppDelegate.h"

@interface NoteItem2()
@property NSManagedObjectContext *moc;
@end

@implementation NoteItem2

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initNote:(Note *)note
{
    self = [super init];
    if (self)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
        
        [self setNote: note];  // built-in setter
        self.noteTextView = [[UITextView alloc] init];
        [self.noteTextView setScrollEnabled: YES];
        [self.noteTextView setText: note.title];
        [self.noteTextView sizeToFit];
        [self.noteTextView setScrollEnabled: NO];
        CGRect frame = self.noteTextView.frame;
        [self.note setWidth:frame.size.width andHeight:frame.size.height];
        
        self.frame = self.noteTextView.frame;
        [self addSubview: self.noteTextView];
        
        float x = -self.frame.size.width/2 + note.centerX.floatValue;
        float y = -self.frame.size.height/2 + note.centerY.floatValue;
        
        [self setX: x andY: y andWidth: self.frame.size.width andHeight:self.frame.size.height];
        
        [[TransformUtil sharedManager] transformVisualItem: self];  //TODO change to
        
    }
    
    return self;
}

@end
