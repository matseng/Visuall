//
//  NoteItem2.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "NoteItem2.h"

#import "Note+CoreDataProperties.h"
#import "AppDelegate.h"

@interface NoteItem2()
@property NSManagedObjectContext *moc;
@end

# define DEFAULT_FONTSIZE 12.0;

@implementation NoteItem2

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype) initNote:(NSString *) title withPoint:(CGPoint) point
{
    self = [super init];
    if (self) {
        
        Note2 *note = [[Note2 alloc] init];
        NSNumber *myDoubleNumber = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
        note.key = [myDoubleNumber stringValue];  // Placeholder value until get a key from Firebase
        note.title = title;
        note.x = point.x;
        note.y = point.y;
        note.fontSize = DEFAULT_FONTSIZE;
        [self setNote: note];
        
//        self.noteTextView = [[UITextView alloc] init];
//        [self.noteTextView setFont:[UIFont fontWithName: @"Arial" size:note.fontSize]];
//        [self resizeToFit: note.title];
//        [self addSubview: self.noteTextView];  // adds the text view to this note's super view
        [self addTextView];
    }
    return self;
}


- (instancetype) initNoteFromFirebase: (NSString *) key andValue: (NSDictionary *) value
{
    self = [super init];
    if (self) {

        Note2 *note = [[Note2 alloc] init];
        note.key = key;
        if (value[@"data"][@"title"]) {
                note.title = value[@"data"][@"title"];
        } else {
            note.title = value[@"data"][@"text"];
        }
        note.x = [value[@"data"][@"x"] floatValue];
        note.y = [value[@"data"][@"y"] floatValue];
        note.fontSize = [value[@"data"][@"font-size"] floatValue];
        [self setNote: note];
        [self addTextView];
    }
    return self;
}

- (void) addTextView
{
    self.noteTextView = [[UITextView alloc] init];
    [self.noteTextView setFont:[UIFont fontWithName: @"Arial" size: self.note.fontSize]];
    [self resizeToFit: self.note.title];
    self.noteTextView.editable = NO;
    self.noteTextView.selectable = NO;
    [self addSubview: self.noteTextView];
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView: [self superview]];  // amount translated in the NotesView, which is effectively the user's screen
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        [self translateTx: translation.x andTy: translation.y];  // scale translation
    }
}

- (void) resizeToFit: (NSString *) text;
{
    if (!text) {
        text = self.noteTextView.text;
    }
    
    CGRect frame = self.noteTextView.frame;
//    CGSize tempSize = self.noteTextView.bounds.size;
//    tempSize.width = CGRectInfinite.size.width;
//    frame.size = tempSize;
    frame.size.width = CGRectInfinite.size.width;
    self.noteTextView.frame = frame;
    
    [self.noteTextView setScrollEnabled: YES];
    [self.noteTextView setText: text];
    [self.noteTextView sizeToFit];
    [self.noteTextView setScrollEnabled: NO];

    frame = self.noteTextView.frame;
//    float x = self.note.x - (frame.size.width - self.note.width)/2;
//    float y = self.note.y - (frame.size.height - self.note.height)/2;
//    float x = self.note.x;
//    float y = self.note.y;
    
    [self setX: self.note.x andY: self.note.y andWidth: frame.size.width andHeight: frame.size.height];
//    [self.note setX: x];
//    [self.note setY: y];
    [self.note setWidth: frame.size.width];
    [self.note setHeight: frame.size.height];
    
//    self.frame = frame;
    self.frame = CGRectMake(self.note.x, self.note.y, frame.size.width, frame.size.height);
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
    
    [self transformVisualItem];
}

-(void) transformVisualItem
{
    
    VisualItem *visualItem = self;
    CGRect frame = visualItem.frame;
    CGAffineTransform matrix = visualItem.transform;
//    matrix.a = self.zoom;
//    matrix.d = self.zoom;
    
    /*
    if ([visualItem isKindOfClass: [NoteItem2 class]]) {
        NoteItem2 *ni = (NoteItem2 *) visualItem;
        if (ni.note.isTitleOfParentGroup && self.zoom < 0.5) {
            if (!self.noteTitleScale) self.noteTitleScale = self.zoom;
            float noteWidthScaled = ni.note.width * self.noteTitleScale;
            GroupItem *gi = [self.groupsCollection getGroupItemFromKey: ni.note.parentGroupKey];
            float groupWidthScaled = gi.group.width * self.zoom;
            if (noteWidthScaled < groupWidthScaled)
            {
                self.noteTitleScale = .5 + (.5 - self.zoom) / self.zoom;
                matrix.a = self.noteTitleScale;  // TODO 1 of 2 fix jumpiness
                matrix.d = self.noteTitleScale;
            } else
            {
                matrix.a = groupWidthScaled / ni.note.width; // TODO 2 of 2 fix jumpiness
                matrix.d = groupWidthScaled / ni.note.width;
            }
            [visualItem setTransform: matrix];
            float centerDeltaX = (visualItem.width * matrix.a - visualItem.width * self.zoom) / 2;
            frame.origin.x = visualItem.x * self.zoom + self.pan.x - centerDeltaX;
            frame.origin.y = visualItem.y * self.zoom + self.pan.y;
            frame.size.width = visualItem.width * matrix.a;
            frame.size.height = visualItem.height * matrix.d;
            [visualItem setFrame: frame];
            return;
        }
    }
     */
    
    [visualItem setTransform: matrix];
    frame.origin.x = visualItem.x;
    frame.origin.y = visualItem.y;
    frame.size.width = visualItem.width;
    frame.size.height = visualItem.height;
    [visualItem setFrame: frame];
    
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

- (NSString *) getKey
{
    return self.note.key;
}

- (CGPoint) getCenterPoint
{
    CGPoint pt = CGPointMake(self.note.x + 0.5 * self.note.width, self.note.y + 0.5 * self.note.height);
    return pt;
}

- (CGPoint) getRelativeCenterPoint
{
    CGPoint pt = CGPointMake(0.5 * self.note.width, 0.5 * self.note.height);
    return pt;
}

//- (void) updateView
//{
//    self.frame = CGRectMake(self., <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//}

@end
