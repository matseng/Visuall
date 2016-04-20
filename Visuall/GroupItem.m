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
#define HANDLE_RADIUS 40.0

@interface GroupItem ()
@property NSManagedObjectContext *moc;
@property UIView *innerGroupView;
@end


@implementation GroupItem

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
        group.width = [value[@"style"][@"width"] floatValue];
        group.height = [value[@"style"][@"width"] floatValue];
        [self setGroup: group];
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
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        self.moc = appDelegate.managedObjectContext;
//        
//        self.group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.moc];
//        [self.group setTopPoint:coordinate];
//        [self.group setHeight:height andWidth:width];
        [self.group setX:coordinate.x andY:coordinate.y];
        [self.group setWidth:width andHeight:height];
        [self renderGroup];
        [[TransformUtil sharedManager] transformGroupItem: self];
    }

    return self;
}

- (void) renderGroup
{
    float scale = [[TransformUtil sharedManager] zoom];
    
    [self setFrame: CGRectMake(
                               (-self.group.width/2 - HANDLE_RADIUS / 2) * scale,
                               (-self.group.height / 2 - HANDLE_RADIUS / 2) * scale,
                               (self.group.width + HANDLE_RADIUS),
                               (self.group.height + HANDLE_RADIUS) )];
    
    UIView *innerGroupView = [[UIView alloc] initWithFrame:CGRectMake(HANDLE_RADIUS / 2, HANDLE_RADIUS / 2, self.group.width, self.group.height)];
    
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
    float scale = [[TransformUtil sharedManager] zoom];
    
    [self setFrame: CGRectMake(
                               (-self.group.width/2 - HANDLE_RADIUS / 2) * scale,
                               (-self.group.height / 2 - HANDLE_RADIUS / 2) * scale,
                               (self.group.width + HANDLE_RADIUS) * scale,
                               (self.group.height + HANDLE_RADIUS) * scale)];
    
    [[self viewWithTag:100] setFrame:CGRectMake(HANDLE_RADIUS / 2, HANDLE_RADIUS / 2, self.group.width, self.group.height)];
    
    [[self viewWithTag:777] setFrame:CGRectMake(self.group.width, self.group.height, HANDLE_RADIUS, HANDLE_RADIUS)];
    
}

- (void) renderHandles
{
    float radius = HANDLE_RADIUS;
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(self.group.width, self.group.height, radius, radius)];
    circleView.alpha = 0.5;
    circleView.layer.cornerRadius = radius / 2;
    circleView.backgroundColor = [UIColor blueColor];
    circleView.tag = 777;
    [self addSubview:circleView];
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
        
        [[TransformUtil sharedManager] transformGroupItem: self];
        
        
        for (NoteItem *ni in self.notesInGroup) {
            [ni translateTx: translation.x andTy:translation.y];
        }
        for (GroupItem *gi in self.groupsInGroup) {
            x = gi.group.x + translation.x;
            y = gi.group.y + translation.y;
            [gi.group setX: x andY: y];
            [gi.group setX: x];
            [gi.group setY: y];
            [[TransformUtil sharedManager] transformGroupItem: gi];
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
        float width = self.group.width + translation.x;
        float height = self.group.height + translation.y;
//        [self.group setHeight:height andWidth:width];
        [self.group setWidth: width];
        [self.group setHeight: height];
        [self updateGroupDimensions];
        [[TransformUtil sharedManager] transformGroupItem: self];
    }
}

- (void) saveToCoreData
{
    [self.moc save:nil];
}

- (BOOL) isNoteInGroup: (NoteItem2 *) ni
{
    CGRect groupRect = self.innerGroupView.frame;
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
    return HANDLE_RADIUS;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
