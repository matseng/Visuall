//
//  NavigationUtil.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/17/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "StateUtil.h"
#import "GroupItem.h"
#import "VisualItem.h"
#import "NoteItem2.h"
#import "SegmentedControlMod.h"

@interface StateUtil()
//@property float zoomPreviousValue;
@property float noteTitleScale;
@property float timeElapsed;
@property float timerThreshold;
@property UIView *rootView;
@end

@implementation StateUtil

//+(id)sharedManager {
//    
//    static StateUtil *sharedMyManager = nil;
//    
//    @synchronized(self) {
//        if (sharedMyManager == nil) {
//            sharedMyManager = [[self alloc] init];
//            sharedMyManager.zoom = 1.0;
//            sharedMyManager.pan = (CGPoint){0.0,0.0};
//            NSLog(@"RESET ZOOM and PAN");
//        }
//    }
//    return sharedMyManager;
//}

//- (void) transfromAllItems
//{
//    for (NSString *key in self.notesCollection.Notes2) {
//        [self transformVisualItem: self.notesCollection.Notes2[key]];
//    }
//    
//    for (NSString *key in self.groupsCollection.groups2) {
//        [self transformGroupItem: self.groupsCollection.groups2[key] ];
//    }
//}

//-(void) handlePanBackground: (UIPanGestureRecognizer *) gestureRecognizer
//                 withNotes:(NotesCollection *) Notes
//                 withGroups: (GroupsCollection *) groupsCollection
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
//        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
////        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
////        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
//        CGPoint translation = [gestureRecognizer translationInView: self.rootView];
//        [gestureRecognizer setTranslation:CGPointZero inView: self.rootView];
//        float panX = self.pan.x + translation.x;
//        float panY = self.pan.y + translation.y;
//        self.pan = CGPointMake(panX, panY);  // these coordinates exists in transformed space
//
//        for (NSString *key in Notes.Notes2) {
//            [self transformVisualItem: Notes.Notes2[key]];
//        }
//        
//        for (NSString *key in groupsCollection.groups2) {
//            [self transformGroupItem: groupsCollection.groups2[key] ];
//        }
//    }
//}


//-(void) handlePinchBackground: (UIPinchGestureRecognizer *) gestureRecognizer withNotes:(NotesCollection *) Notes andGroups: (GroupsCollection *) groupsCollection
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//
//        float zoom = self.zoom * gestureRecognizer.scale;
//        CGPoint gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
//        float deltaX = gesturePoint.x - gesturePoint.x / self.zoom * zoom;
//        float deltaY = gesturePoint.y - gesturePoint.y / self.zoom * zoom;
//        
//        CGFloat tx = self.pan.x / self.zoom * zoom + deltaX;
//        CGFloat ty = self.pan.y / self.zoom * zoom + deltaY;
//        self.pan = CGPointMake(tx, ty);
//        
////        self.zoomPreviousValue = self.zoom;
//        self.zoom = zoom;
//        
//        for (NSString *key in Notes.Notes2) {
//            [self transformVisualItem: Notes.Notes2[key]];
//        }
//        
//        for (NSString *key in groupsCollection.groups2) {
//            [self transformGroupItem: groupsCollection.groups2[key] ];
//        }
//        
//        [gestureRecognizer setScale:1.0];
//    }
//}

//- (void) zoomToValue: (float) zoom atPoint: (CGPoint) point
//{
//    float deltaX = point.x - point.x / self.zoom * zoom;
//    float deltaY = point.y - point.y / self.zoom * zoom;
//    
//    CGFloat tx = self.pan.x / self.zoom * zoom + deltaX;
//    CGFloat ty = self.pan.y / self.zoom * zoom + deltaY;
//    self.pan = CGPointMake(tx, ty);
//    
//    self.zoom = zoom;
//    
//    for (NSString *key in self.notesCollection.Notes2) {
//        [self transformVisualItem: self.notesCollection.Notes2[key]];
//    }
//    
//    for (NSString *key in self.groupsCollection.groups2) {
//        [self transformGroupItem: self.groupsCollection.groups2[key] ];
//    }
//}

//-(void)onTick:(NSTimer *) timer {
//
//
//    if (self.timeElapsed >= self.timerThreshold) {
//        self.timeElapsed = 0.0;
//        [timer invalidate];
//        return;
//    }
//    
//    self.timeElapsed = self.timeElapsed + 0.1;
//    float slope = [timer.userInfo[@"slope"] floatValue];
//    float yIntercept = [timer.userInfo[@"yIntercept"] floatValue];
//    //    NSLog(@"timer on blast, %f", [zoom floatValue]);
//    CGPoint gesturePoint = [timer.userInfo[@"gesturePointValue"] CGPointValue];
//    float zoom = slope * self.timeElapsed + yIntercept;
//    [self zoomToValue:zoom atPoint: gesturePoint];
//    
//    NSLog(@"New zoom value: ,%f", slope * self.timeElapsed + yIntercept);
//    
//}

- (UIView *)rootView: (UIView *) view {
//    UIView *view = self;
    while (view.superview != Nil) {
        view = view.superview;
    }
    return view;
}
//
//- (void) translateToPoint: (CGPoint) point
//{
//    
//    float tx = -point.x * self.zoom + self.rootView.frame.size.width/2;
//    float ty = -point.y * self.zoom + self.rootView.frame.size.height/2;
//    CGPoint transformedPoint = CGPointMake(tx, ty);
//    [self setPan: transformedPoint];
//    [self transfromAllItems];
//}
/*

*/
/*
- (void) handleDoubleTapToZoom: (UITapGestureRecognizer *) gestureRecognizer andTargetView:(UIView *) view
{
    CGPoint gesturePoint;
    self.timeElapsed = 0.0;
    float zoomInitial = self.zoom;
    float zoomFinal;

    if([[view superview] respondsToSelector:@selector(handlePanGroup2:)])
    {
        GroupItem *gi = (GroupItem *) [view superview];
        UIView *rootView = [self rootView: gi];
        self.rootView = rootView;
        zoomFinal = rootView.frame.size.width / gi.group.width * 0.9;
        NSLog(@"Group width: %f", gi.group.width);
        CGPoint centerPoint = [gi getCenterPoint];
        [self translateToPoint: centerPoint];
        gesturePoint = CGPointMake(self.rootView.frame.size.width / 2, self.rootView.frame.size.height / 2);
        
    } else {
        zoomFinal = zoomInitial * 2.5;
        gesturePoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    }
    
    self.timerThreshold = 0.66;
    float slope = (zoomFinal - zoomInitial) / (self.timerThreshold - 0);
    
    
    NSDictionary *dictionary = @{
                                 @"slope": [NSNumber numberWithFloat: slope],
                                 @"yIntercept" : [NSNumber numberWithFloat: self.zoom],
                                 @"gesturePointValue" : [NSValue valueWithCGPoint: gesturePoint],
                                 };
    
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 0.05
                                                  target: self
                                                selector: @selector(onTick:)
                                                userInfo: dictionary
                                                 repeats:YES];
}
*/
//-(void) transformVisualItem: (id) visualItem0
//{
//    
//    VisualItem *visualItem = (VisualItem *) visualItem0;
//    CGRect frame = visualItem.frame;
//    CGAffineTransform matrix = visualItem.transform;
//    matrix.a = self.zoom;
//    matrix.d = self.zoom;
//    
//    
//    if ([visualItem isKindOfClass: [NoteItem2 class]]) {
//        NoteItem2 *ni = (NoteItem2 *) visualItem;
//        if (ni.note.isTitleOfParentGroup && self.zoom < 0.5) {
//            if (!self.noteTitleScale) self.noteTitleScale = self.zoom;
//            float noteWidthScaled = ni.note.width * self.noteTitleScale;
//             GroupItem *gi = [self.groupsCollection getGroupItemFromKey: ni.note.parentGroupKey];
//            float groupWidthScaled = gi.group.width * self.zoom;
//            if (noteWidthScaled < groupWidthScaled)
//            {
//                self.noteTitleScale = .5 + (.5 - self.zoom) / self.zoom;
//                matrix.a = self.noteTitleScale;  // TODO 1 of 2 fix jumpiness
//                matrix.d = self.noteTitleScale;
//            } else
//            {
//                matrix.a = groupWidthScaled / ni.note.width; // TODO 2 of 2 fix jumpiness
//                matrix.d = groupWidthScaled / ni.note.width;
//            }
//            [visualItem setTransform: matrix];
//            float centerDeltaX = (visualItem.width * matrix.a - visualItem.width * self.zoom) / 2;
//            frame.origin.x = visualItem.x * self.zoom + self.pan.x - centerDeltaX;
//            frame.origin.y = visualItem.y * self.zoom + self.pan.y;
//            frame.size.width = visualItem.width * matrix.a;
//            frame.size.height = visualItem.height * matrix.d;
//            [visualItem setFrame: frame];
//            return;
//        }
//    }
//    
//    [visualItem setTransform: matrix];
//    frame.origin.x = visualItem.x * self.zoom + self.pan.x;
//    frame.origin.y = visualItem.y * self.zoom + self.pan.y;
//    frame.size.width = visualItem.width * self.zoom;
//    frame.size.height = visualItem.height * self.zoom;
//    [visualItem setFrame: frame];
//    
//}

- (void) scaleNoteTitleSize: (NoteItem2 *) ni
{
    CGRect frame = ni.frame;
    CGAffineTransform matrix = ni.transform;
    float zoom = [self getZoomScale];
    matrix.a = 1.0;
    matrix.d = 1.0;
    float scaleFactor = 1.0;
    
    if (zoom < 0.2) {
        scaleFactor = 1.0 + (.2 - zoom) / zoom;
        GroupItem *gi = [self.groupsCollection getGroupItemFromKey: ni.note.parentGroupKey];
        if ( ni.note.width * scaleFactor > gi.group.width )
        {
            scaleFactor = gi.group.width / ni.note.width;
        }
    }
    
    ni.fontSizeScaleFactor = scaleFactor;
    [ni transformVisualItem];
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

- (float) getZoomScale
{
    return self.BackgroundScrollView.zoomScale;
}

-(id) getItemFromKey: (NSString *) key
{
    if ([self.notesCollection getNoteFromKey: key])
    {
        return [self.notesCollection getNoteFromKey: key];
    }
    if ([self.groupsCollection getGroupItemFromKey: key])
    {
        return [self.groupsCollection getGroupItemFromKey: key];
    }
    return nil;
}

- (BOOL) isDrawButtonSelected
{
    SegmentedControlMod *scm = (SegmentedControlMod *) self.topMenuViews[@"segmentControlVisualItem"];
    return [self.topMenuViews[@"editSwitch"] isOn] && [[scm getMyTitleForCurrentlySelectedSegment] isEqualToString:@"draw"];
}

- (void) setDefaultSizes
{
    self.textFontSize = 12.0f;
    self.arrowHeadSize = 24.0f;
    self.pathLineWidth = 4.0f;
    
}



@end

