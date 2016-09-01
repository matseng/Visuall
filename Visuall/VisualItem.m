//
//  VisualItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 4/8/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "VisualItem.h"
//#import "GroupItemImage.h"
#import "UserUtil.h"

@implementation VisualItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) setX:(float)x andY:(float)y andWidth: (float) width andHeight:(float) height
{
    self.x = x;
    self.y = y;
    self.width = width;
    self.height = height;
}

- (void) handlePan: (UIPanGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView: [self superview]];  // amount translated in the NotesView, which is effectively the user's screen
        [gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
        self.x = self.x + translation.x;
        self.y = self.y + translation.y;
        CGRect rect = self.frame;
        rect.origin.x = self.x;
        rect.origin.y = self.y;
        self.frame = rect;
    }
}

- (BOOL) isNote  // Note: This method is overwritten in NoteItem2.m
{
    return NO;
}

- (NSString *) getKey
{
    return nil;
}

////@property NSMutableDictionary *items;
//- (NSMutableDictionary*) findOverlappingItems: (Collection *) collection
//{
//    
//    /*
//    if (CGRectIntersectsRect(CGRect rectOne, CGRect rectTwo))
//    {
//        // Rects intersect...
//    }
//     */
//    
//    NSMutableDictionary *items;
//    [[[[UserUtil sharedManager] getState] notesCollection] myForIn:^(NoteItem2 *ni) {
//        
//    }];
//    
//    return items;
//}



@end
