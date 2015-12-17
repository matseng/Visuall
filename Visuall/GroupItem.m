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
#define RADIUS 100.0

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
        CGRect rect = CGRectMake(-group.width.floatValue/2 - RADIUS/4, -group.height.floatValue / 2 - RADIUS/4, group.width.floatValue + RADIUS/2, group.height.floatValue + RADIUS/2);
        [self setFrame: rect];
//        [self setBackgroundColor:GROUP_VIEW_BACKGROUND_COLOR];
//        [self.layer setBorderColor:[GROUP_VIEW_BORDER_COLOR CGColor]];
//        [self.layer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
//        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(0, 0, group.width.floatValue, group.height.floatValue);
        [shapeLayer setBorderColor:[GROUP_VIEW_BORDER_COLOR CGColor]];
        [shapeLayer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
        [shapeLayer setBackgroundColor: [GROUP_VIEW_BACKGROUND_COLOR CGColor]];
        [self.layer addSublayer:shapeLayer];
        [self drawCircleOnGroup:CGRectMake(group.width.floatValue - RADIUS / 2,
                                           group.height.floatValue - RADIUS / 2,
                                           RADIUS,
                                           RADIUS)];
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
//        self.group.bgcolor = GROUP_VIEW_BACKGROUND_COLOR;
        self.group.bordercolor = GROUP_VIEW_BORDER_COLOR;
        self.group.borderwidth = [NSNumber numberWithFloat:GROUP_VIEW_BORDER_WIDTH];
        self.group.alpha = [NSNumber numberWithFloat:0.0];
        
        CGRect rect = CGRectMake(-width/2, -height / 2, width, height);
        [self setFrame: rect];

        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = CGRectMake(0, 0, width, height);
        [shapeLayer setBorderColor:[GROUP_VIEW_BORDER_COLOR CGColor]];
        [shapeLayer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
        [shapeLayer setBackgroundColor:[GROUP_VIEW_BACKGROUND_COLOR CGColor]];
        [self.layer addSublayer:shapeLayer];
        [self drawCircleOnGroup:CGRectMake(width - RADIUS / 2,
                                           height - RADIUS / 2,
                                           RADIUS,
                                           RADIUS)];
        
        [[TransformUtil sharedManager] transformGroupItem: self];
    }

    return self;
}

-(void) onFocusHandler
{
    
}

-(void) drawCircleOnGroup: (CGRect) rect
{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:rect] CGPath]];
    [[self layer] insertSublayer:circleLayer atIndex:0];
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
