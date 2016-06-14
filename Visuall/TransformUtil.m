//
//  NavigationUtil.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "TransformUtil.h"
#import "NoteItem.h"
#import "GroupItem.h"
#import "VisualItem.h"
#import "NoteItem2.h"

@interface TransformUtil()
//@property float zoomPreviousValue;
@property float noteTitleScale;
@property float timeElapsed;
@end

@implementation TransformUtil

+(id)sharedManager {
    
    static TransformUtil *sharedMyManager = nil;
    
    @synchronized(self) {
        if (sharedMyManager == nil) {
            sharedMyManager = [[self alloc] init];
            sharedMyManager.zoom = 1.0;
            sharedMyManager.pan = (CGPoint){0.0,0.0};
            NSLog(@"RESET ZOOM and PAN");
        }
    }
    return sharedMyManager;
}

-(void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
                 withNotes:(NotesCollection *) Notes
                 withGroups: (GroupsCollection *) groupsCollection
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        float panX = self.pan.x + translation.x;
        float panY = self.pan.y + translation.y;
        self.pan = CGPointMake(panX, panY);

        for (NSString *key in Notes.Notes2) {
            [self transformVisualItem: Notes.Notes2[key]];
        }
        
        for (NSString *key in groupsCollection.groups2) {
            [self transformGroupItem: groupsCollection.groups2[key] ];
        }
    }
}

-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer withNotes:(NotesCollection *) Notes andGroups: (GroupsCollection *) groupsCollection
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {

        float zoom = self.zoom * gestureRecognizer.scale;
        CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        float deltaX = gesturePoint.x - gesturePoint.x / self.zoom * zoom;
        float deltaY = gesturePoint.y - gesturePoint.y / self.zoom * zoom;
        
        CGFloat tx = self.pan.x / self.zoom * zoom + deltaX;
        CGFloat ty = self.pan.y / self.zoom * zoom + deltaY;
        self.pan = CGPointMake(tx, ty);
        
//        self.zoomPreviousValue = self.zoom;
        self.zoom = zoom;
        
        for (NSString *key in Notes.Notes2) {
            [self transformVisualItem: Notes.Notes2[key]];
        }
        
        for (NSString *key in groupsCollection.groups2) {
            [self transformGroupItem: groupsCollection.groups2[key] ];
        }
        
        [gestureRecognizer setScale:1.0];
    }
}

- (void) zoomToValue: (float) zoom atPoint: (CGPoint) point
{
    float deltaX = point.x - point.x / self.zoom * zoom;
    float deltaY = point.y - point.y / self.zoom * zoom;
    
    CGFloat tx = self.pan.x / self.zoom * zoom + deltaX;
    CGFloat ty = self.pan.y / self.zoom * zoom + deltaY;
    self.pan = CGPointMake(tx, ty);
    
    self.zoom = zoom;
    
    for (NSString *key in self.notesCollection.Notes2) {
        [self transformVisualItem: self.notesCollection.Notes2[key]];
    }
    
    for (NSString *key in self.groupsCollection.groups2) {
        [self transformGroupItem: self.groupsCollection.groups2[key] ];
    }
}

-(void)onTick:(NSTimer *) timer andZoom: (float) zoom {

//    float timerThreshold = 1.0;
//    if (self.timeElapsed == timerThreshold) {
//        [timer invalidate];
//        return;
//    }
//    
//    self.countDown = self.countDown - 0.1;
    
}

/*

*/
- (void) handleDoubleTapToZoom: (UITapGestureRecognizer *) gestureRecognizer
{
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                             target:self
//                                           selector:@selector(reloadPlotData)
//                                           userInfo:nil
//                                            repeats:YES];

    float zoom = 1.0;
    CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    [self zoomToValue: zoom atPoint:gesturePoint];
    
//    self.countDown = 1.0;
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                  target: self
                                                selector:@selector(onTick:)
                                                userInfo: nil
                                                 repeats:YES];
}

-(void) transformVisualItem: (id) visualItem0
{
    
    VisualItem *visualItem = (VisualItem *) visualItem0;
    CGAffineTransform matrix = visualItem.transform;
    matrix.a = self.zoom;
    matrix.d = self.zoom;
    
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
        }
    }
    
    [visualItem setTransform: matrix];
    
    CGRect frame = visualItem.frame;
    frame.origin.x = visualItem.x * self.zoom + self.pan.x;
    frame.origin.y = visualItem.y * self.zoom + self.pan.y;
    frame.size.width = visualItem.width * self.zoom;
    frame.size.height = visualItem.height * self.zoom;

//    frame.origin.x = visualItem.x * matrix.a + self.pan.x;
//    frame.origin.y = visualItem.y * matrix.d + self.pan.y;
//    frame.size.width = visualItem.width * matrix.a;
//    frame.size.height = visualItem.height * matrix.d;
    
    [visualItem setFrame: frame];
}

-(void) transformNoteItem: (NoteItem *) noteItem
{
    CGAffineTransform matrix = noteItem.transform;
    matrix.a = self.zoom;
    matrix.d = self.zoom;
//    matrix.tx = (noteItem.note.centerX.floatValue * self.zoom) + self.pan.x;
//    matrix.ty = (noteItem.note.centerY.floatValue * self.zoom) + self.pan.y;
//    NSLog(@"tx and ty %f, %f", matrix.tx, matrix.ty);
//    NSLog(@"pan.x and pan.y %f, %f", self.pan.x, self.pan.y);
//    NSLog(@"zoom %f", self.zoom);
//    NSLog(@"Check frame %f, %f", noteItem.frame.origin.x, noteItem.frame.origin.y);
//    noteItem.transform = matrix;
    
//    CGRectApplyAffineTransform(noteItem.frame , matrix);
//    NSLog(@"Check frame %f, %f", noteItem.frame.origin.x, noteItem.frame.origin.y);
    [noteItem setTransform: matrix];
    
    CGRect frame = noteItem.frame;
    frame.origin.x = (-noteItem.note.width.floatValue/2 + noteItem.note.centerX.floatValue ) * self.zoom + self.pan.x;
    frame.origin.y = (-noteItem.note.height.floatValue/2 + noteItem.note.centerY.floatValue ) * self.zoom + self.pan.y;

    NSLog(@"Transformed %f, %f", noteItem.note.width.floatValue, noteItem.note.height.floatValue);
    frame.size.width = noteItem.note.width.floatValue * self.zoom;  // Why do I do this?
    frame.size.height = noteItem.note.height.floatValue * self.zoom;  // Why do I do this?
//    noteItem.frame = frame;
    [noteItem setFrame: frame];

}

-(void) transformGroupItem: (GroupItem *) groupItem
{
    CGAffineTransform matrix = groupItem.transform;
    matrix.a = self.zoom;
    matrix.d = self.zoom;
//    float tx = (groupItem.group.topX.floatValue + groupItem.group.width.floatValue / 2) * self.zoom + self.pan.x;
//    float ty = (groupItem.group.topY.floatValue + groupItem.group.height.floatValue / 2) * self.zoom + self.pan.y;
//    NSLog(@"tx and ty %f, %f", matrix.tx, matrix.ty);
//    NSLog(@"pan.x and pan.y %f, %f", self.pan.x, self.pan.y);
//    NSLog(@"zoom %f", self.zoom);
    
    [groupItem setTransform: matrix];

    float radiusOffset = [groupItem getRadius] / 2;
    float tx = (groupItem.group.x - radiusOffset) * self.zoom + self.pan.x;
    float ty = (groupItem.group.y - radiusOffset) * self.zoom + self.pan.y;
    
    CGRect frame = groupItem.frame;
    frame.origin.x = tx;
    frame.origin.y = ty;
    [groupItem setFrame: frame];
}


-(CGPoint) getGlobalCoordinate: (CGPoint) point
{
    float x = (point.x - self.pan.x) / self.zoom;
    float y = (point.y - self.pan.y) / self.zoom;
    return (CGPoint){x,y};
}

- (float) getGlobalDistance: (float) distance
{
    return (distance / self.zoom);
}

- (BOOL) isTitleNote: (NoteItem2 *) ni
{
    GroupItem *parentGroup = [self.groupsCollection getGroupItemFromKey: ni.note.key];
    if ([ni.note.key isEqualToString: parentGroup.group.titleNoteKey]) {
        return YES;
    }
    return NO;
}

@end

