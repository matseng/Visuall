//
//  NoteView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/12/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NoteItem.h"
#import "TransformUtil.h"

@interface NoteItem()

@end

#define NOTE_WIDTH 150.0f
#define NOTE_HEIGHT 50.0f

@implementation NoteItem

- (instancetype) initNote: (NSString *) title andPoint: (CGPoint) point
{
    self = [super init];
    if (self) {
        Note* note = [[Note alloc] initWithString:title andCenterX:point.x andCenterY:point.y];
        [self setNote: note];
        [self setFrame: CGRectMake(- NOTE_WIDTH / 2,
                                   - NOTE_HEIGHT / 2,
                                   NOTE_WIDTH,
                                   NOTE_HEIGHT)];
        self.text = self.note.text;
        [self setBorderStyle:UITextBorderStyleRoundedRect];
        [[TransformUtil sharedManager] transformNoteItem: self];
        NSLog(@"Init %f, %f", self.note.centerPoint.x, self.note.centerPoint.y);
    }
    return self;
    
}

- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
//        float zoom = [[TransformUtil sharedManager] zoom];

        NSLog(@"translation.x,y %f, %f", translation.x, translation.y);
        
//        float xCenter = self.note.centerPoint.x + translation.x / zoom;
//        float yCenter = self.note.centerPoint.y + translation.y / zoom;
        float xCenter = self.note.centerPoint.x + translation.x;
        float yCenter = self.note.centerPoint.y + translation.y;
        self.note.centerPoint = CGPointMake(xCenter, yCenter);
        
        [[TransformUtil sharedManager] transformNoteItem: self];
        
        NSLog(@"New note %f, %f", self.note.centerPoint.x, self.note.centerPoint.y);

    }
}

@end
