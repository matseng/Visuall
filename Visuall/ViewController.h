//
//  ViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 11/4/15.
//  Copyright (c) 2015 Visuall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) NSString *firebaseURL;

@property (strong, nonatomic) IBOutlet UIView *Background;

@property (strong, nonatomic) UIScrollView *scrollViewButtonList;

- (void) backButtonHandler;

- (void) switchChanged:(id) sender;

- (void) buttonTapped: (id) sender;

@end

