//
//  GroupItemImage.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 8/22/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import "GroupItemImage.h"
#import "UIImage+Extras.h"

#define THUMBNAIL_WIDTH 292.0

@implementation GroupItemImage

- (instancetype) initGroupWithImage: (UIImage *) img andPoint: (CGPoint) point
//- (instancetype) initWithPoint:(CGPoint)coordinate andWidth:(float) width andHeight:(float)height
{
    self = [super init];
    float thumbnailHeight;
    
    if (self)
    {
        self.image = img;
        thumbnailHeight = THUMBNAIL_WIDTH / img.size.width * img.size.height;
        self.thumbnail = [img imageByScalingAndCroppingForSize: CGSizeMake(THUMBNAIL_WIDTH, thumbnailHeight)];
        CGRect rect = CGRectMake(point.x, point.y, THUMBNAIL_WIDTH, thumbnailHeight);
        Group2 *group = [[Group2 alloc] init];
        group.key = nil;
        group.x = rect.origin.x;
        group.y = rect.origin.y;
        group.width = THUMBNAIL_WIDTH;
        group.height = thumbnailHeight;
        [self setGroup: group];
        [self renderGroup];
        [self setViewAsNotSelected];
        [self updateFrame];
        UIImageView *imageView = [self makeImageViewFromImage: img
                                                    withWidth: THUMBNAIL_WIDTH
                                                    andHeight: thumbnailHeight];
        [self.innerGroupView addSubview: imageView];
        
    }
    return self;
}

- (void) addImage: (UIImage *) img
{
    UIImageView *imageView = [self makeImageViewFromImage: img
                                                withWidth: self.group.width
                                                andHeight: self.group.height];
    
    [self.innerGroupView addSubview: imageView];
}

- (UIImageView *) makeImageViewFromImage: (UIImage *) img withWidth: (float) width andHeight: (float) height
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0, 0, width, height);
    [imageView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    self.innerGroupView.alpha = 1.0;
    return imageView;
}


@end
