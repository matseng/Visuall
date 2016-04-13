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
        [self resizeToFit: note.title];
        [self addSubview: self.noteTextView];
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
        self.noteTextView = [[UITextView alloc] init];
        [self resizeToFit: note.title];
        [self addSubview: self.noteTextView];
    }
    return self;
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        [self translateTx:translation.x andTy:translation.y];
    }
}

- (void) resizeToFit: (NSString *) text;
{
//    float zoom = [[TransformUtil sharedManager] zoom];
    CGRect frame = self.noteTextView.frame;
//    CGRect frame = CGRectMake(0, 0, 0, 0);
    CGSize tempSize = self.noteTextView.bounds.size;
    tempSize.width = CGRectInfinite.size.width;
    frame.size = tempSize;
    [self.noteTextView setFrame: frame];
    
    [self.noteTextView setScrollEnabled: YES];
    [self.noteTextView setText: text];
    [self.noteTextView sizeToFit];
    [self.noteTextView setScrollEnabled: NO];

    frame = self.noteTextView.frame;
//    float x = -frame.size.width/2 + self.note.centerX.floatValue;
//    float y = -frame.size.height/2 + self.note.centerY.floatValue;
    float x = self.note.centerX.floatValue;
    float y = self.note.centerY.floatValue;
    [self setX: x andY: y andWidth: frame.size.width andHeight: frame.size.height];
    [self.note setCenterX: x + frame.size.width/2 andCenterY: y + frame.size.height/2];
    [self.note setWidth:frame.size.width andHeight:frame.size.height];
//    [self setFrame: self.noteTextView.frame];
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
    self.x = self.x + tx;
    self.y = self.y + ty;
    
    [[TransformUtil sharedManager] transformVisualItem: self];
}

@end
