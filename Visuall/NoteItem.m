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
@property NSManagedObjectContext *moc;
@end

#define NOTE_WIDTH 150.0f
#define NOTE_HEIGHT 50.0f

@implementation NoteItem

- (instancetype) initNote:(Note *)note
{
    self = [super init];
    if (self) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
        
        [self setNote: note];
        NSLog(@"Init %f, %f", note.centerX.floatValue, note.centerY.floatValue);
        NSLog(@"Init %f, %f", note.width.floatValue, note.height.floatValue);
        self.text = [NSString stringWithFormat: @"%@ %@", self.note.title, self.note.paragraph];
        self.userInteractionEnabled = true;
        self.textAlignment = NSTextAlignmentCenter;
        [self setBorderStyle:UITextBorderStyleRoundedRect];
        CGRect frame = self.frame;
        frame.size.width = note.width.floatValue;
        frame.size.height = note.height.floatValue;
        frame.origin.x = - note.width.floatValue / 2;
        frame.origin.y = - note.height.floatValue / 2;
        self.frame = frame;
        [[TransformUtil sharedManager] transformNoteItem: self];
//        CGRect frame2 = self.frame;
        NSLog(@"Init %f, %f", self.note.centerX.floatValue, self.note.centerY.floatValue);
    }
    
    return self;
}

- (instancetype) initNote:(NSString *) title
                 andPoint:(CGPoint) point
                  andText:(NSString *) paragraph
{
    self = [super init];
    if (self) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
        
        Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.moc];
        note.title = title;
        note.paragraph = paragraph;
        [note setCenterPoint:point];
        
        [self setNote: note];
        self.text = [NSString stringWithFormat: @"%@\n\n%@", self.note.title, self.note.paragraph];
        self.textAlignment = NSTextAlignmentCenter;
        [self setBorderStyle:UITextBorderStyleRoundedRect];
        [self renderToAutosizeWidth2];
    }
    
    return self;
    
}

- (void) renderToAutosizeWidth
{
//    CGRect frame0 = self.frame;
//    CGAffineTransform matrix = self.transform;
    [self sizeToFit];
    CGRect frame = self.frame;
    NSLog(@"Check frame %f, %f", self.frame.origin.x, self.frame.origin.y);
//    frame.size.width = frame.size.width * 1.05;
    frame.size.width = frame.size.width * 1.0;
    frame.size.height = frame.size.height;
    
//    frame.origin.x = - frame.size.width / 2;
//    frame.origin.y = - frame.size.height / 2;
//    self.frame = frame;  // BUG?
    [self setFrame:frame];
//    [self setNeedsDisplay];
    [self.note setHeight:frame.size.height andWidth:frame.size.width];
    [[TransformUtil sharedManager] transformNoteItem: self];
}

- (void) renderToAutosizeWidth2
{
    //    CGRect frame0 = self.frame;
    //    CGAffineTransform matrix = self.transform;
    [self sizeToFit];
    CGRect frame = self.frame;
    NSLog(@"Check frame %f, %f", self.frame.origin.x, self.frame.origin.y);
    frame.size.width = frame.size.width * 1.0;
    frame.size.height = frame.size.height;
    frame.origin.x = - frame.size.width / 2;
    frame.origin.y = - frame.size.height / 2;
    //    self.frame = frame;  // BUG?
    [self setFrame:frame];
    //    [self setNeedsDisplay];
    [self.note setHeight:frame.size.height andWidth:frame.size.width];
    [[TransformUtil sharedManager] transformNoteItem: self];
}

- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        [self translateTx:translation.x andTy:translation.y];
    }
}

- (void) saveToCoreData
{
    [self.moc save:nil];
}

- (void) translateTx: (float) tx andTy: (float) ty
{
    float xCenter = self.note.centerX.floatValue + tx;
    float yCenter = self.note.centerY.floatValue + ty;
    [self.note setCenterX:xCenter andCenterY:yCenter];
    
    [[TransformUtil sharedManager] transformNoteItem: self];
    
    NSLog(@"New note %f, %f", self.note.centerX.floatValue, self.note.centerY.floatValue);
}

@end
