//
//  NoteView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/12/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "Note+CoreDataProperties.h"
#import "TransformUtil.h"
#import "AppDelegate.h"

@interface NoteItem()

@end

#define NOTE_WIDTH 150.0f
#define NOTE_HEIGHT 50.0f

@implementation NoteItem

- (instancetype) initNote: (NSString *) title andPoint: (CGPoint) point
{
    self = [super init];
    if (self) {
        Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:[Note getMOC]];
        note.title = title;
//        note.centerX = [NSNumber numberWithFloat:point.x];
//        note.centerY = [NSNumber numberWithFloat:point.y];
        [note setCenterPoint:point];
        [note setHeight:NOTE_HEIGHT andWidth:NOTE_WIDTH];
        [self setNote: note];
        [self setFrame: CGRectMake(- NOTE_WIDTH / 2,
                                   - NOTE_HEIGHT / 2,
                                   NOTE_WIDTH,
                                   NOTE_HEIGHT)];
        self.text = self.note.title;
        [self setBorderStyle:UITextBorderStyleRoundedRect];
        [[TransformUtil sharedManager] transformNoteItem: self];
        NSLog(@"Init %f, %f", self.note.centerX.floatValue, self.note.centerY.floatValue);
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
        float xCenter = self.note.centerX.floatValue + translation.x;
        float yCenter = self.note.centerY.floatValue + translation.y;
        [self.note setCenterX:xCenter andCenterY:yCenter];
//        self.note.centerX = [NSNumber numberWithFloat:xCenter];
//        self.note.centerY = [NSNumber numberWithFloat:yCenter];
        
        [[TransformUtil sharedManager] transformNoteItem: self];
        
        NSLog(@"New note %f, %f", self.note.centerX.floatValue, self.note.centerY.floatValue);

    }
}

@end