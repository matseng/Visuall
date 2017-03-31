//
//  SpeedReadingViewController.h
//  
//
//  Created by Michael Tseng MacBook on 3/27/17.
//
//

#import <UIKit/UIKit.h>
#import "GroupItem.h"
#import "StateUtilFirebase.h"

@interface SpeedReadingViewController : UIViewController

@property (nonatomic, strong) StateUtilFirebase *visuallState;

@property UILabel *label;

@property float wordsPerMinute;

@property int index;

@end
