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

//- (NoteItem2 *) getNoteItem
//{
//    if ([self isNoteItem])
//    {
//        return (NoteItem2 *) self;
//    }
//    return nil;
//}

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

@end
