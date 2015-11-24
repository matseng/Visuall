//
//  GroupItem.m
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "GroupItem.h"
#import "TransformUtil.h"
#import "AppDelegate.h"

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0

@interface GroupItem ()
@property NSManagedObjectContext *moc;
@end


@implementation GroupItem

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
        
        self.group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.moc];
        [self.group setTopPoint:coordinate];
        [self.group setHeight:height andWidth:width];
        [ self setFrame: CGRectMake(-width/2, -height / 2, width, height)];
        [self setBackgroundColor:GROUP_VIEW_BACKGROUND_COLOR];
        [self.layer setBorderColor:GROUP_VIEW_BORDER_COLOR];
        [self.layer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
        [[TransformUtil sharedManager] transformGroupItem: self];
    }

    return self;
}

-(void) handlePanGroup2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        
        float x = self.group.topX.floatValue + translation.x;
        float y = self.group.topY.floatValue + translation.y;
        [self.group setTopX:x andTopY:y];
        
        [[TransformUtil sharedManager] transformGroupItem: self];
        for (NoteItem *ni in self.notesInGroup) {
            [ni translateTx: translation.x andTy:translation.y];
        }
    }
}

- (void) saveToCoreData
{
    [self.moc save:nil];
}

- (BOOL) isNoteInGroup: (NoteItem *) noteItem
{
    CGRect groupRect = CGRectMake([self.group.topX floatValue], [self.group.topY floatValue], [self.group.width floatValue], [self.group.height floatValue]);
    if ( CGRectContainsPoint(groupRect, (CGPoint){[noteItem.note.centerX floatValue], [noteItem.note.centerY floatValue]} ) )
    {
        return YES;
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
