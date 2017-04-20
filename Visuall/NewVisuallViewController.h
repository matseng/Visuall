//
//  NewVisuallViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 2/24/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewVisuallViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *metadata;

@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;

@property (weak, nonatomic) IBOutlet UITextView *sharedWithTextArea;

@end
