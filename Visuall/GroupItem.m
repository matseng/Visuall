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
#define GROUP_VIEW_BORDER_COLOR [UIColor blackColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0

@interface GroupItem ()
@property NSManagedObjectContext *moc;
@end


@implementation GroupItem

- (instancetype) initGroup:(Group *)group
{
    self = [super init];
    
    if (self)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.moc = appDelegate.managedObjectContext;
        self.group = group;
        [self renderGroup];
        [[TransformUtil sharedManager] transformGroupItem: self];
 
    }
    
    return self;
}

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
        [self renderGroup];
        [[TransformUtil sharedManager] transformGroupItem: self];
    }

    return self;
}

- (void) renderGroup
{
    [self setFrame: CGRectMake(-self.group.width.floatValue/2, -self.group.height.floatValue / 2, self.group.width.floatValue, self.group.height.floatValue)];
    [self setBackgroundColor:GROUP_VIEW_BACKGROUND_COLOR];
    [self.layer setBorderColor:[GROUP_VIEW_BORDER_COLOR CGColor]];
    [self.layer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
    [self renderHandles];
}

- (void) renderHandles
{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(50, 50, 100, 100)] CGPath]];
    [[self layer] addSublayer:circleLayer];
}

-(void) handlePanGroup2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        
        float x = self.group.topX.floatValue + translation.x;
        float y = self.group.topY.floatValue + translation.y;
        [self.group setTopX:x andTopY:y];
        
        [[TransformUtil sharedManager] transformGroupItem: self];
        for (NoteItem *ni in self.notesInGroup) {
            [ni translateTx: translation.x andTy:translation.y];
        }
        for (GroupItem *gi in self.groupsInGroup) {
            x = gi.group.topX.floatValue + translation.x;
            y = gi.group.topY.floatValue + translation.y;
            [gi.group setTopPoint: CGPointMake(x, y)];
            [[TransformUtil sharedManager] transformGroupItem: gi];
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

- (BOOL) isGroupInGroup: (GroupItem *) gi
{
    
    float firstArea = self.group.height.floatValue * self.group.width.floatValue;
    float secondArea = gi.group.height.floatValue * gi.group.width.floatValue;
    if (self == gi || secondArea > firstArea){
        return NO;
    }
    
    CGRect groupRect = CGRectMake([self.group.topX floatValue], [self.group.topY floatValue], [self.group.width floatValue], [self.group.height floatValue]);
    float centerX = gi.group.topX.floatValue + gi.group.width.floatValue / 2;
    float centerY = gi.group.topY.floatValue + gi.group.height.floatValue / 2;
    if ( CGRectContainsPoint(groupRect, (CGPoint){centerX, centerY} ) )
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
