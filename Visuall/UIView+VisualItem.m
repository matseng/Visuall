//
//  UIView+VisualItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/13/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "UIView+VisualItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (VisualItem)


-(void) setRoundedCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    CGRect rect = self.bounds;
    
    // Create the path
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
}

- (BOOL) isNoteItem
{
    return [self isKindOfClass:[NoteItem2 class]] || [self.superview isKindOfClass:[NoteItem2 class]];
}

- (BOOL) isGroupItem
{
    return [self isKindOfClass:[GroupItem class]]  || [ [self superview] isKindOfClass:[GroupItem class]];
}

- (BOOL) isGroupItemSubview
{
    return ( ![self isKindOfClass:[GroupItem class]]  && [ [self superview] isKindOfClass:[GroupItem class]] );
}

- (BOOL) isGroupHandle
{
    if ([self isGroupItem])
    {
        GroupItem *gi = [self getGroupItem];
        if( [gi isHandle: self] )
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isArrowItem
{
    return [self isKindOfClass:[ArrowItem class]] || [[self superview] isKindOfClass:[ArrowItem class]];
}

- (BOOL) isPathItem
{
    return [self isKindOfClass:[FDDrawView class]];
}

- (GroupItem *) getGroupItem
{
    if ( [self isKindOfClass:[GroupItem class]] )
    {
        return (GroupItem *) self;
    } else if ( [[self superview] isKindOfClass:[GroupItem class]] )
    {
        return (GroupItem *) [self superview];
    }
    return nil;
}

- (NoteItem2 *) getNoteItem
{
    UIView *viewHit = self;
    NoteItem2 *ni = nil;
    if ( [viewHit isKindOfClass: [NoteItem2 class]])
    {
        ni = (NoteItem2 *) viewHit;
    } else if ( [[viewHit superview] isKindOfClass: [NoteItem2 class]] )
    {
        ni = (NoteItem2*)[viewHit superview];
    }
    return ni;
}

- (ArrowItem *) getArrowItem
{
    if ( [self isKindOfClass:[ArrowItem class]] )
    {
        return (ArrowItem *) self;
    } else if ( [[self superview] isKindOfClass:[ArrowItem class]] )
    {
        return (ArrowItem *) [self superview];
    }
    return nil;
}

- (PathItem *) getPathItem
{
    if ( [self isPathItem] )
    {
        FDDrawView *dv = (FDDrawView *) self;
        return dv.selectedPath;
    }
    return nil;
}

- (BOOL) isInBoundsOfView: (UIView *) parentView
{
    CGRect rect = self.frame;
    CGRect parentRect = parentView.frame;
    CGPoint bottomRight = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
//    CGPoint convertedOrigin = [parentView convertPoint: rect.origin fromView:self.superview];
//    CGPoint convertedBottomLeft = [parentView convertPoint: bottomLeft fromView:self.superview];
    CGPoint convertedOrigin = [parentView.superview convertPoint: CGPointZero fromView:self];
    CGPoint convertedBottomRight = [parentView.superview convertPoint: CGPointMake(rect.size.width, rect.size.height) fromView:self];
    
    if ( convertedOrigin.x < parentRect.origin.x || parentRect.origin.y < parentRect.origin.y)
    {
        return NO;
    }
    
    if ( convertedBottomRight.x > parentRect.origin.x + parentRect.size.width || convertedBottomRight.y > parentRect.origin.y + parentRect.size.height)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL) isPartiallyInBoundsOfView: (UIView *) parentView
{
//    int counter = 0;
//    CGPoint topLeft = [parentView.superview convertPoint: CGPointZero fromView:self];
//    CGPoint topRight = [parentView.superview convertPoint: CGPointMake(self.frame.size.width, 0) fromView:self];
//    CGPoint bottomRight = [parentView.superview convertPoint: CGPointMake(self.frame.size.width, self.frame.size.height) fromView:self];
//    CGPoint bottomLeft = [parentView.superview convertPoint: CGPointMake(0, self.frame.size.height) fromView:self];
//    
//    if (CGRectContainsPoint(parentView.frame, topLeft)) counter++;
//    if (CGRectContainsPoint(parentView.frame, topRight)) counter++;
//    if (CGRectContainsPoint(parentView.frame, bottomRight)) counter++;
//    if (CGRectContainsPoint(parentView.frame, bottomLeft)) counter++;
//    if (counter >= 2) return YES;
//    return NO;
    CGRect boundsA = [self convertRect:self.bounds toView:nil];
    CGRect boundsB = [parentView convertRect:parentView.bounds toView:nil];
    BOOL viewsOverlap = CGRectIntersectsRect(boundsA, boundsB);
    return viewsOverlap;
}

- (BOOL) isImage
{
    if ( [self isKindOfClass: [GroupItemImage class]] )
    {
        return YES;
    }
    return NO;
}

- (GroupItemImage *) getGroupItemImage
{
    if ( [self isImage] )
    {
        return (GroupItemImage *) self;
    }
    return nil;
}

- (UIViewController *) firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}


@end
