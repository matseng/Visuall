//
//  Note.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/9/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import "Note.h"

@implementation Note

- (instancetype) initWithString:(NSString *)text andCenterX:(float)centerX andCenterY:(float)centerY
{
    self = [super init];
    if (self) {
        self.text = text;
        self.centerPointView = (CGPoint){ centerX, centerY };
    }
    return self;
}

//- (UITextField *) getView
//{
//    if (!self.view) {
//        UITextField *utf = [[UITextField alloc] initWithFrame:CGRectMake(self.centerPoint.x, self.centerPoint.y, 300, 25)];
//        utf.text = self.text;
//        self.view = utf;
//    }
//    return self.view;
//}

//- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
//        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
//        
//        [gestureRecognizer.view setTransform:
//         CGAffineTransformTranslate(gestureRecognizer.view.transform, translation.x, translation.y)];
//        [gestureRecognizer setTranslation: CGPointZero inView:gestureRecognizer.view];
//        NSLog(@"%f, %f", translation.x, translation.y);
//    }
//}

@end

//- (instancetype) initWithDictionary: (NSDictionary *) dictionary
//{
//    self = [super init];
//    if (self) {
//        self.name = [dictionary objectForKey: @"name"];
//        self.textDescription = [dictionary objectForKey:@"description"];
//        self.avatarURL = [dictionary objectForKey:@"avatar_url"];
//    }
//    return self;
//}