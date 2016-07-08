//
//  UIImage+Extras.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/7/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extras)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end