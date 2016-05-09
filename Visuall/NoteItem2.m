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

//- (instancetype) initNote:(NSString *) title
//                 andPoint:(CGPoint) point
//                  andText:(NSString *) paragraph
//{
//    self = [super init];
//    if (self) {
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        self.moc = appDelegate.managedObjectContext;
//        
//        Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:self.moc];
//        note.title = title;
//        note.paragraph = paragraph;
//        [note setCenterPoint:point];
//        [self setNote: note];
//        self.noteTextView = [[UITextView alloc] init];
//        [self resizeToFit: note.title];
//        [self addSubview: self.noteTextView];
//    }
//    return self;
//}

//CGFloat x = [snapshot.value[key][@"data"][@"x"] floatValue];
//CGFloat y = [snapshot.value[key][@"data"][@"y"] floatValue];
//CGFloat fontSize = [snapshot.value[key][@"style"][@"font-size"] floatValue];
//CGPoint point = CGPointMake(x, y);
//NoteItem2 *newNote = [[NoteItem2 alloc] initNote:snapshot.value[key][@"data"][@"text"]
//                                        andPoint:point
//                                         andText:@""];


- (instancetype) initNote: (NSString *) key andValue: (NSDictionary *) value
{
    self = [super init];
    if (self) {

        Note2 *note = [[Note2 alloc] init];
        note.key = key;
        note.title = value[@"data"][@"text"];
        note.x = [value[@"data"][@"x"] floatValue];
        note.y = [value[@"data"][@"y"] floatValue];
        note.fontSize = [value[@"style"][@"font-size"] floatValue];
        [self setNote: note];
        
        self.noteTextView = [[UITextView alloc] init];
        [self.noteTextView setFont:[UIFont fontWithName: @"Arial" size:note.fontSize]];
        [self resizeToFit: note.title];
        [self addSubview: self.noteTextView];  // adds the text view to this note's super view
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
    if (!text) {
        text = self.noteTextView.text;
    }
    
    CGRect frame = self.noteTextView.frame;
    CGSize tempSize = self.noteTextView.bounds.size;
    tempSize.width = CGRectInfinite.size.width;
    frame.size = tempSize;
    [self.noteTextView setFrame: frame];
    
    [self.noteTextView setScrollEnabled: YES];
    [self.noteTextView setText: text];
    [self.noteTextView sizeToFit];
    [self.noteTextView setScrollEnabled: NO];

    frame = self.noteTextView.frame;
//    float x = self.note.x - (frame.size.width - self.note.width)/2;
//    float y = self.note.y - (frame.size.height - self.note.height)/2;
    float x = self.note.x;
    float y = self.note.y;
    
    [self setX: x andY: y andWidth: frame.size.width andHeight: frame.size.height];
    [self.note setX: x];
    [self.note setY: y];
    [self.note setWidth: frame.size.width];
    [self.note setHeight: frame.size.height];
}

- (void) saveToCoreData
{
    [self.moc save:nil];
}

- (void) translateTx: (float) tx andTy: (float) ty
{
//    float xCenter = self.note.centerX.floatValue + tx;
//    float yCenter = self.note.centerY.floatValue + ty;
//    [self.note setCenterX:xCenter andCenterY:yCenter];
    float x = [self.note x] + tx;
    float y = [self.note y] + ty;
    
    [self.note setX: x];
    [self.note setY: y];
    [self setX: x];
    [self setY: y];
    
    [[TransformUtil sharedManager] transformVisualItem: self];
}

- (void) setFontSize: (float) fontSize
{
    [self.note setFontSize: fontSize];
    [self.noteTextView setFont: [UIFont systemFontOfSize:fontSize]];
    [self resizeToFit:nil];
}

- (void) scaleFontSize: (float) scalar
{
    float newFontSize = self.note.fontSize * scalar;
    [self.note setFontSize: newFontSize];
    [self.noteTextView setFont: [UIFont systemFontOfSize: newFontSize]];
    
//    [self resizeToFit:nil];
    NSString *text = self.noteTextView.text;
    CGRect frame = self.noteTextView.frame;
    CGSize tempSize = self.noteTextView.bounds.size;
    tempSize.width = CGRectInfinite.size.width;
    frame.size = tempSize;
    [self.noteTextView setFrame: frame];
    
    [self.noteTextView setScrollEnabled: YES];
    [self.noteTextView setText: text];
    [self.noteTextView sizeToFit];
    [self.noteTextView setScrollEnabled: NO];
}

- (BOOL) isNote
{
    if([self isKindOfClass:[NoteItem2 class]]) {
        return YES;
    }
    return NO;
}

@end
