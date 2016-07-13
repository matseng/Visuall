//
//  UIView+VisualItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/13/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "UIView+VisualItem.h"


@implementation UIView (VisualItem)

- (BOOL) isNoteItem
{
    return [self isKindOfClass:[NoteItem2 class]];
}

- (NoteItem2 *) getNoteItem
{
    if ([self isNoteItem])
    {
        return (NoteItem2 *) self;
    }
    return nil;
}

- (BOOL) isGroupItem
{
    return [self isKindOfClass:[GroupItem class]]  || [ [self superview] isKindOfClass:[GroupItem class]];
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

@end
