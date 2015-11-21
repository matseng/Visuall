//
//  NoteView.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/12/15.
//  Copyright © 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note+CoreDataProperties.h"

@interface NoteItem : UITextField

//@property (weak, nonatomic) IBOutlet UITextField *tfield;
@property Note *note;

- (instancetype) initNote: (NSString *) title andPoint: (CGPoint) point;

- (void) handlePan2: (UIPanGestureRecognizer *) gestureRecognizer;

@end
