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

@property (weak, nonatomic) IBOutlet UILabel *labelForWordToRead;

@property UILabel *label;

@property float wordsPerMinute;

@property int index;

//@property (weak, nonatomic) IBOutlet UILabel *wordsPerMinuteLabel;

@property (weak, nonatomic) IBOutlet UITextField *wordsPerMinueTextField;


@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

@property (weak, nonatomic) IBOutlet UIView *progessViewContainer;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

- (IBAction)rewindButtonTapped:(id)sender;

- (IBAction)playPauseButtonTapped:(id)sender;

- (IBAction)fastForwardButtonTapped:(id)sender;

- (IBAction)minusButtonTapped:(id)sender;

- (IBAction)plusButtonTapped:(id)sender;

@end
