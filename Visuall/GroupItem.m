//
//  GroupItem.m
//  Visuall
//
//  Created by Lawrence May on 11/21/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "GroupItem.h"
#import "TransformUtil.h"

#define GROUP_VIEW_BACKGROUND_COLOR [UIColor lightGrayColor]
#define GROUP_VIEW_BORDER_COLOR [[UIColor blackColor] CGColor]
#define GROUP_VIEW_BORDER_WIDTH 1.0

@implementation GroupItem

- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float)width andHeight:(float)height
{
    self = [super init];
    
    if (self)
    {
        self.group = [[Group alloc] initWithPoint:coordinate andWidth:width andHeight:height];
//        [self setFrame:CGRectMake(coordinate.x, coordinate.y, width, height)];
//        [self setFrame:CGRectMake(0, 0, width, height)];
        [self setFrame:CGRectMake(-width/2, -height/2, width, height)];
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
        float x = self.group.coordinate.x + translation.x;
        float y = self.group.coordinate.y + translation.y;
        self.group.coordinate = CGPointMake(x, y);
        [[TransformUtil sharedManager] transformGroupItem: self];
    }
}

//- (BOOL) isNoteInGroup: (NoteItem *) noteItem andGroup: (GroupItem*) groupItem
//{
//    CGRect groupRect = CGRectMake(groupItem.group.coordinate.x, groupItem.group.coordinate.y, groupItem.group.width, groupItem.group.height);
//    if (CGRectContainsPoint(groupRect, noteItem.note.centerPoint))
//    {
//        return YES;
//    }
//    return NO;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
