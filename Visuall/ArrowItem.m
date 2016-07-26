//
//  EdgeItem.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/25/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "ArrowItem.h"
#import "NoteItem2.h"

@implementation ArrowItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initArrowWithSoruceNoteItem: (NoteItem2*) ni0 andTargetNoteItem: (NoteItem2*) ni1
{
    self = [super init];
    if (self) {
        self.arrow = [[Arrow alloc] init];
        self.arrow.sourceKey = [ni0 getKey];
        self.arrow.targetKey = [ni1 getKey];
        self.arrow.sourcePoint = [ni0 getCenterPoint];
        self.arrow.targetPoint = [ni1 getCenterPoint];
        float dist = sqrtf( powf(self.arrow.targetPoint.x - self.arrow.sourcePoint.x, 2) + powf(self.arrow.targetPoint.y - self.arrow.sourcePoint.y, 2) );
        self.arrow.length = dist;
        self.arrow.width = dist;  // TODO auto size width
        
        self.backgroundColor = [UIColor greenColor];
        self.frame = CGRectMake(self.arrow.sourcePoint.x, self.arrow.sourcePoint.y, dist, dist);

    }
    return self;
}

@end
