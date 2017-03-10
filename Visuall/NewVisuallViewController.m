//
//  NewVisuallViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 2/24/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import "NewVisuallViewController.h"
#import "MyVisuallsViewController.h"

@interface NewVisuallViewController ()

@property (weak, nonatomic) IBOutlet UITextField *TitleTextField;

- (IBAction) onDeleteButtonPressed: (id)sender;

@end

@implementation NewVisuallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Cancel";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    if (self.metadata && self.metadata[@"key"])
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneEditingHandler)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.TitleTextField.text = self.metadata[@"title"];
    }
    else
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneHandler)];
        self.navigationItem.rightBarButtonItem = doneButton;
//        self.navigationController.navigationBar.topItem.rightBarButtonItem = doneButton;
        [self.TitleTextField becomeFirstResponder];
    }
}

- (void) doneEditingHandler
{
    [self performSegueWithIdentifier: @"doneEditingSegue" sender: self];
}

/*
 * Name: doneHandler
 * Description: Passes object of information (title, author, etc.)
 * http://stackoverflow.com/questions/12509422/how-to-perform-unwind-segue-programmatically?noredirect=1&lq=1
 */
- (void) doneHandler
{
//    UIStoryboardSegue *unwind = [self seguewith

//    MyVisuallsViewController *controller = (MyVisuallsViewController *) segue.destinationViewController;
    
    
    [self performSegueWithIdentifier: @"unwindToMyVisuallsVC" sender: self];
    
}
                                 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"unwindToMyVisuallsVC"])
    {
        MyVisuallsViewController *controller = (MyVisuallsViewController *)segue.destinationViewController;
        NSDictionary *info = @{
                               @"title": self.TitleTextField.text
                               };
        controller.infoFromNewVisuallVC = info;
        self.metadata = nil;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onDeleteButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: nil message:[NSString stringWithFormat:@"Delete this Visuall?"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"\n Confirm delete here");
        // TODO (Mar 10, 2017): Go back to list view and delete visuall from firebase
        [self performSegueWithIdentifier: @"deleteVisuall" sender: self];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"\n Cancel");
    }];
    
    [alertController addAction:alertAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
