//
//  NoteView.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/12/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "NoteItem.h"

@interface NoteItem()

@end

#define NOTE_WIDTH 300.0f
#define NOTE_HEIGHT 50.0f

@implementation NoteItem

- (instancetype) initNote: (NSString *) title andPoint: (CGPoint) point
{
    self = [super init];
    if (self) {
        Note* note = [[Note alloc] initWithString:title andCenterX:point.x andCenterY:point.y];
        [self setNote: note];
        [self setFrame: CGRectMake(self.note.centerPointScreen.x - NOTE_WIDTH / 2,
                                   self.note.centerPointScreen.y - NOTE_HEIGHT / 2,
                                   NOTE_WIDTH,
                                   NOTE_HEIGHT)];
        self.text = self.note.text;
        //        NoteItem *ni = [[NoteItem alloc] initWithFrame:CGRectMake(self.note.centerPointScreen.x, self.note.centerPointScreen.y, NOTE_WIDTH, NOTE_HEIGHT)];
//        ni.note = note;
//        ni.text = ni.note.text;
        NSLog(@"Init %f, %f", self.note.centerPointScreen.x, self.note.centerPointScreen.y);
//        return ni;
    }
    return self;
    
}

- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];

//        float translationX = translation.x;  // need to transform
//        float translationY = translation.y;  // need to transform

        NSLog(@"Previous note %f, %f", self.note.centerPointScreen.x, self.note.centerPointScreen.y);
        NSLog(@"Previous noteItem %f, %f", self.center.x, self.center.y);
        
        float xScreen = self.note.centerPointScreen.x + translation.x;
        float yScreen = self.note.centerPointScreen.y + translation.y;
        
        self.note.centerPointScreen = CGPointMake(xScreen, yScreen);
        self.center = self.note.centerPointScreen;
        
        NSLog(@"New note %f, %f", self.note.centerPointScreen.x, self.note.centerPointScreen.y);
        NSLog(@"New noteItem %f, %f", self.center.x, self.center.y);

    }
}

@end
