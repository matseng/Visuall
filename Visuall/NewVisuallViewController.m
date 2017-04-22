//
//  NewVisuallViewController.m
//  Visuall
//
//  Created by Michael Tseng MacBook on 2/24/17.
//  Copyright © 2017 Visuall. All rights reserved.
//

#import "NewVisuallViewController.h"
#import "MyVisuallsViewController.h"
#import "UserUtil.h"

@interface NewVisuallViewController ()

@property (weak, nonatomic) IBOutlet UITextField *TitleTextField;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction) onDeleteButtonPressed: (id)sender;

@property (weak, nonatomic) IBOutlet UIView *outerContainer;

@property NSArray *sharedWithArrayOfEmailAddresses;

@end

@implementation NewVisuallViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Cancel";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    [self updateSubviews];
    
    if (self.metadata && self.metadata[@"key"])
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneEditingHandler)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.TitleTextField.text = self.metadata[@"title"];
        self.navigationItem.title = self.TitleTextField.text;
//        self.sharedWithTextArea.text = self.metadata[@"sharedWith"];
    }
    else  // setup for new visuall
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneHandler)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [self.deleteButton removeFromSuperview];
        [self.TitleTextField becomeFirstResponder];
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    
    self.createdByLabel.text =  [[UserUtil sharedManager] displayName]; // TODO (Apr 20, 2017): replace later in above if else (if visuall was created by another)
    [self.TitleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.sharedWithTextArea.layer.borderWidth = 1.0f;
    self.sharedWithTextArea.layer.borderColor = [[UIColor grayColor] CGColor];
    self.sharedWithTextArea.delegate = self;
    self.sharedWithArrayOfEmailAddresses = [NSNull null];
}

- (void) textFieldDidChange: (UITextField *) textField
{
    self.navigationItem.title = textField.text;
    
}

- (void) textViewDidChange:(UITextView *) textView
{
}

- (void) doneEditingHandler
{
    [self performSegueWithIdentifier: @"unwindFromEditVisuall" sender: self];
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
    
    
    [self performSegueWithIdentifier: @"unwindFromNewVisuall" sender: self];
    
}
                                 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString: @"unwindToMyVisuallsVC"])
//    {
//        MyVisuallsViewController *controller = (MyVisuallsViewController *) segue.destinationViewController;
//        NSDictionary *info = @{
//                               @"title": self.TitleTextField.text
//                               };
//        controller.metadataOfCurrentVisuall = info;
//        self.metadata = nil;
//    }
    
    MyVisuallsViewController *controller = (MyVisuallsViewController *) segue.destinationViewController;
    NSDictionary *info;
//    if (self.metadata)
//    {
//        info = @{
//                 @"key": self.metadata[@"key"],
//                 @"title": self.TitleTextField.text,
//                 @"sharedWith": self.sharedWithArrayOfEmailAddresses
//                 };
//    }
//    else
//    {
//        info = @{
//                 @"title": self.TitleTextField.text,
//                 @"sharedWith": self.sharedWithArrayOfEmailAddresses
//                 };
//    }
    self.metadata[@"title"] = self.TitleTextField.text;
//    self.sharedWithArrayOfEmailAddresses = [[NSArray alloc] initWithObjects: self.sharedWithTextArea.text, nil];
//    NSDictionary *emailAddressesAreKeys = [[NSDictionary alloc] initWithObjectsAndKeys:@1, self.sharedWithArrayOfEmailAddresses[0], nil];
    NSDictionary *emailAddressesAreKeys = [self getEmailAddressesDictFromString: self.sharedWithTextArea.text withDelimiter: @","];
    self.metadata[@"shared-with"] = emailAddressesAreKeys ? emailAddressesAreKeys : [NSNull null];

    controller.metadataOfCurrentVisuall = self.metadata;
//    self.metadata = nil;
}

- (NSMutableDictionary *) getEmailAddressesDictFromString: (NSString *) string withDelimiter: (NSString *) delimiter
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSString *strTemp;
    NSArray *arrayOfStrings = [string componentsSeparatedByString: delimiter];
    for (NSString *str in arrayOfStrings)
    {
        if ([str containsString: @"@"] && [str containsString:@"."])
        {
            strTemp = [str stringByReplacingOccurrencesOfString: @"." withString: @"%2E"];
            [result setObject: @1 forKey: strTemp];
            
        }
    }
    if ( [result count] == 0)
    {
        result = nil;
    }
    return result;
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
        [self performSegueWithIdentifier: @"unwindFromDeleteVisuall" sender: self];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"\n Cancel");
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 * Name: updateSubviews
 * Description: Re-centers subviews upon change of device orientation
 */
- (void) updateSubviews
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        self.outerContainer.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 1 / 4);
    }
    else
    {
//        self.outerContainer.center = self.view.center;
        self.outerContainer.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 1 / 3);
    }
    
}

- (void) OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        [self updateSubviews];
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        [self updateSubviews];
    }
}

@end
