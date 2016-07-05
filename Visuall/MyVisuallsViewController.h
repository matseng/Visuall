//
//  MyVisuallsViewController.h
//  Visuall
//
//  Created by Michael Tseng MacBook on 7/5/16.
//  Copyright © 2016 Visuall. All rights reserved.
//

//#import "ViewController.h"
#import <UIKit/UIKit.h>

@interface MyVisuallsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
