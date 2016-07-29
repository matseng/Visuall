//
//  GroupItem.m
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "GroupItem.h"
#import "StateUtil.h"
#import "AppDelegate.h"

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [UIColor blackColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0
#define HANDLE_DIAMETER 40.0
#define HANDLE_COLOR [UIColor blueColor]
#define SELECTED_VIEW_BORDER_COLOR [[UIColor blueColor] CGColor]
#define SELECTED_VIEW_BORDER_WIDTH 2.0


@interface GroupItem ()
@property NSManagedObjectContext *moc;
@property UIView *innerGroupView;
@end


@implementation GroupItem

{
    UIView *handleTopLeft;
    UIView *handleTopRight;
    UIView *handleBottomLeft;
    UIView *handleBottomRight;
}
//- (instancetype) initGroup:(Group *)group
//{
//    self = [super init];
//    
//    if (self)
//    {
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        self.moc = appDelegate.managedObjectContext;
//        self.group = group;
//        [self renderGroup];
//        [[TransformUtil sharedManager] transformGroupItem: self];
// 
//    }
//    
//    return self;
//}

- (instancetype) initGroup: (NSString *) key andValue: (NSDictionary *) value
{
    self = [super init];
    if (self) {
        Group2 *group = [[Group2 alloc] init];
        group.key = key;
        group.x = [value[@"data"][@"x"] floatValue];
        group.y = [value[@"data"][@"y"] floatValue];
        
        if ( value[@"data"][@"width"] && value[@"data"][@"height"]) {
            group.width = [value[@"data"][@"width"] floatValue];
            group.height = [value[@"data"][@"height"] floatValue];
        } else {
            group.width = [value[@"style"][@"width"] floatValue];
            group.height = [value[@"style"][@"height"] floatValue];
        }

        [self setGroup: group];
        [self renderGroup];
        [self setViewAsNotSelected];
        [[StateUtil sharedManager] transformGroupItem: self];
    }
    return self;
}

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        self.moc = appDelegate.managedObjectContext;
//        
//        self.group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.moc];
//        [self.group setTopPoint:coordinate];
//        [self.group setHeight:height andWidth:width];
        
//        [self.group setX:coordinate.x andY:coordinate.y];
//        [self.group setWidth:width andHeight:height];
//        [self renderGroup];
//        [[TransformUtil sharedManager] transformGroupItem: self];
        
        Group2 *group = [[Group2 alloc] init];
        group.key = nil;
        group.x = coordinate.x;
        group.y = coordinate.y;
        group.width = width;
        group.height = height;
        [self setGroup: group];
        [self renderGroup];
        [self setViewAsNotSelected];
        [[StateUtil sharedManager] transformGroupItem: self];
    }

    return self;
}

- (void) renderGroup
{
    float scale = [[StateUtil sharedManager] zoom];
    
    [self setFrame: CGRectMake(
                               (-self.group.width/2 - HANDLE_DIAMETER / 2) * scale,
                               (-self.group.height / 2 - HANDLE_DIAMETER / 2) * scale,
                               (self.group.width + HANDLE_DIAMETER),
                               (self.group.height + HANDLE_DIAMETER) )];
    self.layer.borderWidth = GROUP_VIEW_BORDER_WIDTH;
    self.layer.borderColor = SELECTED_VIEW_BORDER_COLOR;
    
    UIView *innerGroupView = [[UIView alloc] initWithFrame:CGRectMake(HANDLE_DIAMETER / 2, HANDLE_DIAMETER / 2, self.group.width, self.group.height)];
    
    [innerGroupView setBackgroundColor:GROUP_VIEW_BACKGROUND_COLOR];
    [innerGroupView.layer setBorderColor:[GROUP_VIEW_BORDER_COLOR CGColor]];
    [innerGroupView.layer setBorderWidth:GROUP_VIEW_BORDER_WIDTH];
    innerGroupView.tag = 100;
    self.innerGroupView = innerGroupView;
    [self addSubview: innerGroupView];
    [self renderHandles];
}

- (void) updateGroupDimensions
{
    float scale = [[StateUtil sharedManager] zoom];
    
    [self setFrame: CGRectMake(
                               (-self.group.width/2 - HANDLE_DIAMETER / 2) * scale,
                               (-self.group.height / 2 - HANDLE_DIAMETER / 2) * scale,
                               (self.group.width + HANDLE_DIAMETER) * scale,
                               (self.group.height + HANDLE_DIAMETER) * scale)];
    
    [[self viewWithTag:100] setFrame:CGRectMake(HANDLE_DIAMETER / 2, HANDLE_DIAMETER / 2, self.group.width, self.group.height)];
    
//    [[self viewWithTag:777] setFrame:CGRectMake(self.group.width, self.group.height, HANDLE_DIAMETER, HANDLE_DIAMETER)];
    [self updateHandles];
    
}

- (void) renderHandles
{
    
//    UIView *handleTopLeft;
//    UIView *handleTopRight;
//    UIView *handleBottomLeft;
//    UIView *handleBottomRight;

    handleBottomRight = [self makeHandle: CGRectMake(self.group.width, self.group.height, HANDLE_DIAMETER, HANDLE_DIAMETER)];
    handleBottomRight.tag = 777;
    [self addSubview:handleBottomRight];
    
    handleTopLeft = [self makeHandle: CGRectMake(0, 0, HANDLE_DIAMETER, HANDLE_DIAMETER)];
    [self addSubview:handleTopLeft];

    handleTopRight = [self makeHandle: CGRectMake(self.group.width, 0, HANDLE_DIAMETER, HANDLE_DIAMETER)];
    [self addSubview:handleTopRight];
    
    handleBottomLeft = [self makeHandle: CGRectMake(0, self.group.height, HANDLE_DIAMETER, HANDLE_DIAMETER)];
    [self addSubview:handleBottomLeft];
}

- (void) updateHandles
{
    handleBottomRight.frame = CGRectMake(self.group.width, self.group.height, HANDLE_DIAMETER, HANDLE_DIAMETER);
    
    handleTopLeft.frame = CGRectMake(0, 0, HANDLE_DIAMETER, HANDLE_DIAMETER);
    
    handleTopRight.frame = CGRectMake(self.group.width, 0, HANDLE_DIAMETER, HANDLE_DIAMETER);
    
    handleBottomLeft.frame = CGRectMake(0, self.group.height, HANDLE_DIAMETER, HANDLE_DIAMETER);
    
}

- (UIView *) makeHandle: (CGRect) rect
{
    UIView *circleView = [[UIView alloc] initWithFrame: rect];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = HANDLE_DIAMETER / 2;
    circleView.layer.backgroundColor = [HANDLE_COLOR CGColor];
    return circleView;
}

-(void) handlePanGroup2: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        
        float x = self.group.x + translation.x;
        float y = self.group.y + translation.y;
        [self.group setX: x];
        [self.group setY: y];
        
        [[StateUtil sharedManager] transformGroupItem: self];
        
        for (NoteItem *ni in self.notesInGroup) {
            [ni translateTx: translation.x andTy:translation.y];
        }
        for (GroupItem *gi in self.groupsInGroup) {
            x = gi.group.x + translation.x;
            y = gi.group.y + translation.y;
            [gi.group setX: x andY: y];
//            [gi.group setX: x];
//            [gi.group setY: y];
            [[StateUtil sharedManager] transformGroupItem: gi];
        }
        
        
    }
}

- (void) resizeGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if (self.handleSelected == handleBottomRight)
        {
            CGPoint translation = [gestureRecognizer translationInView:self];
            [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
            float width = self.group.width + translation.x;
            float height = self.group.height + translation.y;
            //        [self.group setHeight:height andWidth:width];
            if ( width > HANDLE_DIAMETER )
            {
                [self.group setWidth: width];
            }
            if (height > HANDLE_DIAMETER * 1 ) {
                [self.group setHeight: height];
            }
            [self updateGroupDimensions];
            [[StateUtil sharedManager] transformGroupItem: self];
        } else if (self.handleSelected == handleTopLeft)
        {
            CGPoint translation = [gestureRecognizer translationInView:self];
            [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
            float width = self.group.width - translation.x;
            float height = self.group.height - translation.y;
            if ( width > HANDLE_DIAMETER )
            {
                [self.group setWidth: width];
                [self.group setX:self.group.x + translation.x];
            }
            if (height > HANDLE_DIAMETER * 1 ) {
                [self.group setHeight: height];
                [self.group setY:self.group.y + translation.y];
            }
            [self updateGroupDimensions];
            [[StateUtil sharedManager] transformGroupItem: self];
        } else if (self.handleSelected == handleTopRight)
        {
            CGPoint translation = [gestureRecognizer translationInView:self];
            [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
            float width = self.group.width + translation.x;
            float height = self.group.height - translation.y;
            if ( width > HANDLE_DIAMETER )
            {
                [self.group setWidth: width];
                [self.group setX:self.group.x];
            }
            if (height > HANDLE_DIAMETER * 1 ) {
                [self.group setHeight: height];
                [self.group setY:self.group.y + translation.y];
            }
            [self updateGroupDimensions];
            [[StateUtil sharedManager] transformGroupItem: self];
        } else if (self.handleSelected == handleBottomLeft)
        {
            CGPoint translation = [gestureRecognizer translationInView:self];
            [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
            float width = self.group.width - translation.x;
            float height = self.group.height + translation.y;
            if ( width > HANDLE_DIAMETER )
            {
                [self.group setWidth: width];
                [self.group setX:self.group.x + translation.x];
            }
            if (height > HANDLE_DIAMETER * 1 ) {
                [self.group setHeight: height];
                [self.group setY:self.group.y];
            }
            [self updateGroupDimensions];
            [[StateUtil sharedManager] transformGroupItem: self];
        }
    }
}

- (void) saveToCoreData
{
    [self.moc save:nil];
}

- (BOOL) isNoteInGroup: (NoteItem2 *) ni
{
    CGRect groupRect = CGRectMake(self.group.x, self.group.y, self.group.width, self.group.height);
    CGPoint noteCenterPoint = CGPointMake(ni.note.x + ni.note.width/2, ni.note.y + ni.note.height/2);
                                  
    if ( CGRectContainsPoint(groupRect, noteCenterPoint))
    {
        return YES;
    }
    return NO;
}

- (BOOL) isTitleNote: (NoteItem2 *) ni
{
//    if ( [self isNoteInGroup: ni] )
//    {
//        if ( !self.group.titleNote )
//        {
//            self.group.titleNote = ni.note;
//        } else if (ni.note.fontSize > self.group.titleNote.fontSize)
//        {
//            self.group.titleNote = ni.note;
//        } else if (ni.note.fontSize == self.group.titleNote.fontSize &&
//                   [ni.note getY] > [self.group.titleNote getY])
//        {
//            self.group.titleNote = ni.note;
//        }
//    }
    return NO;
}

- (BOOL) isGroupInGroup: (GroupItem *) gi
{
    
    float firstArea = self.group.height * self.group.width;
    float secondArea = gi.group.height * gi.group.width;
    if (self == gi || secondArea > firstArea){
        return NO;
    }
    
//    CGRect groupRect = CGRectMake([self.group.topX floatValue], [self.group.topY floatValue], [self.group.width floatValue], [self.group.height floatValue]);
    CGRect groupRect = CGRectMake(self.group.x, self.group.y, self.group.width, self.group.height);
    float centerX = gi.group.x + gi.group.width / 2;
    float centerY = gi.group.y + gi.group.height / 2;
    if ( CGRectContainsPoint(groupRect, (CGPoint){centerX, centerY} ) )
    {
        return YES;
    }
    
    return NO;
}

- (float) getRadius
{
    return HANDLE_DIAMETER;
}


- (float) getArea
{
    return self.group.width * self.group.height;
}

- (CGPoint) getCenterPoint
{
    return CGPointMake(self.group.x + self.group.width/2, self.group.y + self.group.height/2);
}

- (UIView *) hitTestOnHandles: (UIGestureRecognizer*) gestureRecognizer
{
    CGPoint location;
    UIView *result;
    
    location = [gestureRecognizer locationInView: handleBottomRight];
    result = [handleBottomRight hitTest:location withEvent:nil];
    if (result == handleBottomRight)
    {
        return handleBottomRight;
    }
    
    location = [gestureRecognizer locationInView: handleBottomLeft];
    result = [handleBottomLeft hitTest:location withEvent:nil];
    if (result == handleBottomLeft)
    {
        return handleBottomLeft;
    }
    
    location = [gestureRecognizer locationInView: handleTopLeft];
    result = [handleTopLeft hitTest:location withEvent:nil];
    if (result == handleTopLeft)
    {
        return handleTopLeft;
    }

    location = [gestureRecognizer locationInView: handleTopRight];
    result = [handleTopRight hitTest:location withEvent:nil];
    if (result == handleTopRight)
    {
        return handleTopRight;
    }
    
    return nil;
}

- (void) setViewAsSelected
{
    self.layer.borderWidth = SELECTED_VIEW_BORDER_WIDTH;
    if ( [[StateUtil sharedManager] editModeOn])
    {
        handleTopLeft.layer.backgroundColor = [HANDLE_COLOR CGColor];
        handleTopRight.layer.backgroundColor = [HANDLE_COLOR CGColor];
        handleBottomLeft.layer.backgroundColor = [HANDLE_COLOR CGColor];
        handleBottomRight.layer.backgroundColor = [HANDLE_COLOR CGColor];        
    }
}

- (void) setViewAsNotSelected
{
    self.layer.borderWidth = 0;
    handleTopLeft.layer.backgroundColor = [[UIColor clearColor] CGColor];
    handleTopRight.layer.backgroundColor = [[UIColor clearColor] CGColor];
    handleBottomLeft.layer.backgroundColor = [[UIColor clearColor] CGColor];
    handleBottomRight.layer.backgroundColor = [[UIColor clearColor] CGColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
