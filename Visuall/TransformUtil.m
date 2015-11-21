//
//  NavigationUtil.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "TransformUtil.h"
#import "NoteItem.h"

@implementation TransformUtil

+(id)sharedManager {
    
    static TransformUtil *sharedMyManager = nil;
    
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
            sharedMyManager.zoom = 1.0;
            sharedMyManager.pan = (CGPoint){0.0,0.0};
            NSLog(@"RESET ZOOM and PAN");
        }
    }
    return sharedMyManager;
}

-(void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer withNotes:(NSArray *)Notes
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        float panX = self.pan.x + translation.x;
        float panY = self.pan.y + translation.y;
        self.pan = CGPointMake(panX, panY);

        for (NoteItem *noteItem in Notes) {
            [self transformNoteItem: noteItem];
        }
    }
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer withNotes:(NSArray *)Notes
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"1. gestureRecognizer.scale %f", gestureRecognizer.scale);
        NSLog(@"2. self.zoom %f", self.zoom);
        float zoom = self.zoom * gestureRecognizer.scale;
        NSLog(@"--> zoom %f", zoom);
        CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        float deltaX = gesturePoint.x - gesturePoint.x / self.zoom * zoom;
        float deltaY = gesturePoint.y - gesturePoint.y / self.zoom * zoom;
        
        CGFloat tx = self.pan.x / self.zoom * zoom + deltaX;
        CGFloat ty = self.pan.y / self.zoom * zoom + deltaY;
        self.pan = CGPointMake(tx, ty);
        
        self.zoom = zoom;
        
        
        for (NoteItem *noteItem in Notes) {
            [self transformNoteItem:noteItem];
        }
        [gestureRecognizer setScale:1.0];
    }
}

-(void) transformNoteItem: (NoteItem *) noteItem
{
    CGAffineTransform matrix = noteItem.transform;
    matrix.a = self.zoom;
    matrix.d = self.zoom;
    matrix.tx = (noteItem.note.centerPoint.x * self.zoom) + self.pan.x;
    matrix.ty = (noteItem.note.centerPoint.y * self.zoom) + self.pan.y;
    NSLog(@"tx and ty %f, %f", matrix.tx, matrix.ty);
    NSLog(@"pan.x and pan.y %f, %f", self.pan.x, self.pan.y);
    NSLog(@"zoom %f", self.zoom);

    [noteItem setTransform: matrix];
    
}

@end

