//
//  GroupItem.m
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "GroupItem.h"
#import "StateUtilFirebase.h"
#import "AppDelegate.h"
#import "NoteItem2.h"
#import "UserUtil.h"


#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [UIColor blackColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0
#define HANDLE_DIAMETER 40.0
#define HANDLE_COLOR [UIColor blueColor]
#define SELECTED_VIEW_BORDER_COLOR [[UIColor blueColor] CGColor]
#define SELECTED_VIEW_BORDER_WIDTH 2.0


@interface GroupItem ()
@property NSManagedObjectContext *moc;
//@property UIView *innerGroupView;
@end


@implementation GroupItem

{
    float _handleDiameter;
    //    UIView *self.innerGroupView;
    UIView *handleTopLeft;
    UIView *handleTopRight;
    UIView *handleBottomLeft;
    UIView *handleBottomRight;
}

//static StateUtilFirebase *visuallState;
//
//+ (StateUtilFirebase *) visuallState {return visuallState;}

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
        [self updateFrame];
    }
    return self;
}

- (void) updateGroupItem: (NSString *) key andValue: (NSDictionary *) value  // TODO (Sep 9, 2016): make public method for updating groups from firebase
{
    [self updateGroupModel: key andValue:value];
    [self updateHandles];
    [self updateFrame];
}

- (void) updateGroupModel: (NSString *) key andValue: (NSDictionary *) value
{
    self.group.key = key;
    self.group.x = [value[@"data"][@"x"] floatValue];
    self.group.y = [value[@"data"][@"y"] floatValue];
    
    if ( value[@"data"][@"width"] && value[@"data"][@"height"]) {
        self.group.width = [value[@"data"][@"width"] floatValue];
        self.group.height = [value[@"data"][@"height"] floatValue];
    } else {
        self.group.width = [value[@"style"][@"width"] floatValue];
        self.group.height = [value[@"style"][@"height"] floatValue];
    }
}

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float) width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
        
        Group2 *group = [[Group2 alloc] init];
        group.key = nil;
        group.x = coordinate.x;
        group.y = coordinate.y;
        group.width = width;
        group.height = height;
        [self setGroup: group];
        [self renderGroup];
        [self setViewAsNotSelected];
        [self updateFrame];
    }
    
    return self;
}

- (GroupItem *) initWithRect: (CGRect) rect
{
    return [self initWithPoint:rect.origin andWidth: rect.size.width andHeight:rect.size.height];
}

- (void) renderGroup
{
    _handleDiameter = [self getHandleDiameter];
    [self setFrame: CGRectMake(0, 0, (self.group.width + _handleDiameter), (self.group.height + _handleDiameter) )];
    if ( !self.innerGroupView ) self.innerGroupView = [[UIView alloc] initWithFrame: CGRectMake(_handleDiameter / 2, _handleDiameter / 2, self.group.width, self.group.height)];
    [self.innerGroupView setBackgroundColor:GROUP_VIEW_BACKGROUND_COLOR];
    self.innerGroupView.alpha = 0.2;
    [self.innerGroupView.layer setBorderColor:[GROUP_VIEW_BORDER_COLOR CGColor]];
    [self.innerGroupView.layer setBorderWidth: 0];
    self.innerGroupView.tag = 100;
    self.innerGroupView.autoresizesSubviews = YES;
    self.innerGroupView = self.innerGroupView;
    [self addSubview: self.innerGroupView];
    //    [self renderHandles];
}

/*
 * Name: updateGroupDimensions
 * Description: Updates the view when the group handles are dragged
 */
- (void) updateGroupDimensions
{
    [self setFrame: CGRectMake(
                               (-self.group.width/2 - _handleDiameter / 2),
                               (-self.group.height / 2 - _handleDiameter / 2),
                               (self.group.width + _handleDiameter),
                               (self.group.height + _handleDiameter))];
    
    [[self viewWithTag:100] setFrame:CGRectMake(_handleDiameter / 2, _handleDiameter / 2, self.group.width, self.group.height)];
    [self updateHandles];
}

- (void) renderHandles
{
    _handleDiameter = [self getHandleDiameter];
    
    handleBottomRight = [self makeHandle: CGRectMake(self.group.width, self.group.height, _handleDiameter, _handleDiameter)];
    [self insertSubview:handleBottomRight belowSubview:self.subviews[0]];
    
    handleTopLeft = [self makeHandle: CGRectMake(0, 0, _handleDiameter, _handleDiameter)];
    [self insertSubview:handleTopLeft belowSubview:self.subviews[0]];
    
    handleTopRight = [self makeHandle: CGRectMake(self.group.width, 0, _handleDiameter, _handleDiameter)];
    [self insertSubview:handleTopRight belowSubview:self.subviews[0]];
    
    handleBottomLeft = [self makeHandle: CGRectMake(0, self.group.height, _handleDiameter, _handleDiameter)];
    [self insertSubview:handleBottomLeft belowSubview:self.subviews[0]];
}

- (void) updateHandles
{
    handleBottomRight.frame = CGRectMake(self.group.width, self.group.height, _handleDiameter, _handleDiameter);
    
    handleTopLeft.frame = CGRectMake(0, 0, _handleDiameter, _handleDiameter);
    
    handleTopRight.frame = CGRectMake(self.group.width, 0, _handleDiameter, _handleDiameter);
    
    handleBottomLeft.frame = CGRectMake(0, self.group.height, _handleDiameter, _handleDiameter);
    
}

- (UIView *) makeHandle: (CGRect) rect
{
    UIView *circleView = [[UIView alloc] initWithFrame: rect];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = _handleDiameter / 2;
    circleView.layer.backgroundColor = [HANDLE_COLOR CGColor];
    return circleView;
}

- (BOOL) isHandle: (UIView *) subView
{
    BOOL result = (subView == handleTopLeft) || (subView == handleTopRight) || (subView == handleBottomRight) || (subView == handleBottomLeft);
    return result;
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
        [self updateFrame];
        
        for (NoteItem2 *ni in self.notesInGroup)
        {
            [ni translateTx: translation.x andTy:translation.y];
        }
        for (GroupItem *gi in self.groupsInGroup)
        {
            x = gi.group.x + translation.x;
            y = gi.group.y + translation.y;
            [gi.group setX: x andY: y];
            [gi updateFrame];
        }
        for (ArrowItem *ai in self.arrowsInGroup)
        {
            [ai translateArrowByDelta: translation];
            
        }
        for (PathItem *pi in self.pathsInGroup)
        {
            [[[[UserUtil sharedManager] getState] DrawView] translatePath: pi byPoint: translation];
        }
    }
}

- (void) resizeGroup: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gestureRecognizer translationInView:self];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        if (self.handleSelected == handleBottomRight)
        {
            if ( [self isImage] )
            {
                if ( fabs(translation.x / translation.y) > 1 )
                {
                    translation.x = translation.y * self.group.width / self.group.height;
                }
                else
                {
                    translation.y = translation.x * self.group.height / self.group.width;
                }
            }
            float width = self.group.width + translation.x;
            float height = self.group.height + translation.y;
            //        [self.group setHeight:height andWidth:width];
            if ( width > _handleDiameter )
            {
                [self.group setWidth: width];
            }
            if (height > _handleDiameter * 1 ) {
                [self.group setHeight: height];
            }
        } else if (self.handleSelected == handleTopLeft)
        {
            if ( [self isImage] )
            {
                if ( fabs(translation.x / translation.y) > 1 )
                {
                    translation.x = translation.y * self.group.width / self.group.height;
                }
                else
                {
                    translation.y = translation.x * self.group.height / self.group.width;
                }
            }
            float width = self.group.width - translation.x;
            float height = self.group.height - translation.y;
            if ( width > _handleDiameter )
            {
                [self.group setWidth: width];
                [self.group setX:self.group.x + translation.x];
            }
            if (height > _handleDiameter * 1 ) {
                [self.group setHeight: height];
                [self.group setY:self.group.y + translation.y];
            }
        } else if (self.handleSelected == handleTopRight)
        {
            if ( [self isImage] )
            {
                if ( (translation.x > 0 && translation.y < 0)
                    || (translation.x < 0 && translation.y > 0) )
                {
                    if ( fabs(translation.x / translation.y) > 1 )
                    {
                        translation.x = - translation.y * self.group.width / self.group.height;
                    }
                    else
                    {
                        translation.y = - translation.x * self.group.height / self.group.width;
                    }
                }
                else
                {
                    return;
                }
            }
            
            float width = self.group.width + translation.x;
            float height = self.group.height - translation.y;
            
            if ( width > _handleDiameter )
            {
                [self.group setWidth: width];
                [self.group setX: self.group.x];
            }
            if (height > _handleDiameter * 1 ) {
                [self.group setHeight: height];
                [self.group setY: self.group.y + translation.y];
            }
        } else if (self.handleSelected == handleBottomLeft)
        {
            if ( [self isImage] )
            {
                if ( (translation.x > 0 && translation.y < 0)
                    || (translation.x < 0 && translation.y > 0) )
                {
                    if ( fabs(translation.x / translation.y) > 1 )
                    {
                        translation.x = - translation.y * self.group.width / self.group.height;
                    }
                    else
                    {
                        translation.y = - translation.x * self.group.height / self.group.width;
                    }
                }
                else
                {
                    return;
                }
            }
            float width = self.group.width - translation.x;
            float height = self.group.height + translation.y;
            if ( width > _handleDiameter )
            {
                [self.group setWidth: width];
                [self.group setX:self.group.x + translation.x];
            }
            if (height > _handleDiameter * 1 ) {
                [self.group setHeight: height];
                [self.group setY:self.group.y];
            }
        }
        
        [self updateGroupDimensions];
        [self updateFrame];
    }
    else if ( gestureRecognizer.state == UIGestureRecognizerStateEnded )
    {
        float zoomScale =  [[[UserUtil sharedManager] getState] getZoomScale];
        [self setViewAsSelectedForEditModeOn: YES andZoomScale: zoomScale];
    }
}

- (void) saveToCoreData
{
    [self.moc save:nil];
}

- (BOOL) isNoteInGroup: (NoteItem2 *) ni
{
    CGRect groupRect = CGRectMake(self.group.x, self.group.y, self.group.width, self.group.height);
    CGPoint noteCenterPoint = CGPointMake(ni.frame.origin.x + ni.frame.size.width/2, ni.frame.origin.y + ni.frame.size.height/2);
    
    if ( CGRectContainsPoint(groupRect, noteCenterPoint))
    {
        return YES;
    }
    return NO;
}

- (BOOL) isArrowInGroup: (ArrowItem *) ai
{
    CGRect groupRect = CGRectMake(self.group.x, self.group.y, self.group.width, self.group.height);
    
    if ( CGRectContainsPoint(groupRect, ai.startPoint) && CGRectContainsPoint(groupRect, ai.endPoint))
    {
        return YES;
    }
    return NO;
}

- (BOOL) isPathInGroup: (PathItem *) pi
{
    CGRect groupRect = CGRectMake(self.group.x, self.group.y, self.group.width, self.group.height);
    NSUInteger count = pi.fdpath.points.count;
    CGPoint startPoint = [pi.fdpath.points[0] getCGPoint];
    CGPoint endPoint = [pi.fdpath.points[count - 1] getCGPoint];
    
    if ( CGRectContainsPoint(groupRect, startPoint)
        && CGRectContainsPoint( groupRect, endPoint))
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
    return _handleDiameter;
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

//- (void) setViewAsSelected: (StateUtilFirebase *) visuallState
- (void) setViewAsSelected
{
    //    if ( [visuallState editModeOn])
    if (YES)
    {
        //        [__innerGroupView removeFromSuperview];
        [self setViewAsNotSelected];
        //        [self renderGroup];
        [self renderHandles];
        [self updateFrame];
    }
    self.innerGroupView.layer.borderColor = SELECTED_VIEW_BORDER_COLOR;
}

- (void) setViewAsSelectedForEditModeOn: (BOOL) editModeOn andZoomScale: (float) zoomScale
{
    if ( editModeOn )
    {
        //        [__innerGroupView removeFromSuperview];
        [self setViewAsNotSelected];
        //        [self renderGroup];
        [self renderHandles];
        [self updateFrame];
    } else
    {
        [self setViewAsNotSelected];
    }
    self.innerGroupView.layer.borderColor = SELECTED_VIEW_BORDER_COLOR;
    self.innerGroupView.layer.borderWidth = floor(SELECTED_VIEW_BORDER_WIDTH / zoomScale);
}

- (void) setViewAsNotSelected
{
//    self.innerGroupView.layer.borderColor = [GROUP_VIEW_BORDER_COLOR CGColor];
    self.innerGroupView.layer.borderWidth = 0;
    [handleTopLeft removeFromSuperview];
    [handleTopRight removeFromSuperview];
    [handleBottomLeft removeFromSuperview];
    [handleBottomRight removeFromSuperview];
    
    handleBottomLeft = nil;
    handleTopRight = nil;
    handleBottomLeft = nil;
    handleBottomRight = nil;
}


- (float) getHandleDiameter
{
    _handleDiameter = HANDLE_DIAMETER;
    float groupWidth = self.group.width;
    float groupHeight = self.group.height;
    
    if (groupWidth <= groupHeight && _handleDiameter > 1/3 * groupWidth)
    {
        return (.333 * groupWidth);  // TODO: what type if groupWidth... bc 1/3 * groupWidth doesnt work. ALSO, what scale are we at?
    }
    else if (groupHeight < groupWidth && _handleDiameter > 1/3 * groupHeight)
    {
        return (.333 * groupHeight);
    }
    return _handleDiameter;
}

- (void) updateFrame
{
    float radiusOffset = [self getRadius] / 2;
    
    self.innerGroupView.frame = CGRectMake(radiusOffset, radiusOffset, self.group.width, self.group.height);
    
    CGRect frame = self.frame;
    frame.origin.x = self.group.x - radiusOffset;
    frame.origin.y = self.group.y - radiusOffset;
    [self setFrame: frame];
}

- (float) getWidth
{
    return self.innerGroupView.frame.size.width;
}

/*
 * Name:
 * Description: point should be given in local coordinates (i.e. already converted)
 */

- (UIView *) hitTestIncludingHandles: (CGPoint) point
{
    UIView *result;
    CGPoint convertedPoint;
    if (handleTopLeft)
    {
        if (CGRectContainsPoint(handleTopLeft.frame, point))
        {
            return handleTopLeft;
        }
    }
    
    if (handleTopRight)
    {
        if (CGRectContainsPoint(handleTopRight.frame, point))
        {
            return handleTopRight;
        }
    }
    
    if (handleBottomRight)
    {
        if (CGRectContainsPoint(handleBottomRight.frame, point))
        {
            return handleBottomRight;
        }
    }
    
    if (handleBottomLeft)
    {
        if (CGRectContainsPoint(handleBottomLeft.frame, point))
        {
            return handleBottomLeft;
        }
    }
    
    convertedPoint = [self.innerGroupView convertPoint:point fromView: self];
    result = [self.innerGroupView hitTest: convertedPoint withEvent:nil];
    return result;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
