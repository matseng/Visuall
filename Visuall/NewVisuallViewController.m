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
    
    if (self.metadata && self.metadata[@"key"])
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save & Close"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneEditingHandler)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.TitleTextField.text = self.metadata[@"title"];
        self.navigationItem.title = self.TitleTextField.text;
        if ( self.metadata[@"shared-with"] != [NSNull null])
        {
            self.sharedWithTextArea.text = [[[self.metadata[@"shared-with"] allKeys] componentsJoinedByString: @", "] stringByReplacingOccurrencesOfString:@"%2E" withString:@"."];
        }
    }
    else  // setup for new visuall
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save & Close"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneHandler)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [self.deleteButton removeFromSuperview];
        [self.TitleTextField becomeFirstResponder];
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.outerContainer addGestureRecognizer: tap];
    
//    self.createdByLabel.text = [NSString stringWithFormat:@" %@ (%@) ", [[UserUtil sharedManager] displayName], [[UserUtil sharedManager] email]];
    self.createdByLabel.text = [NSString stringWithFormat:@" %@ %@ (%@) ", self.metadata[@"created-by-first-name"], self.metadata[@"created-by-last-name"], self.metadata[@"created-by-email"]];
//    [self.createdByLabel sizeToFit];
    self.createdByLabel.adjustsFontSizeToFitWidth = true;
//    self.createdByLabel.text =  [[[UserUtil sharedManager] displayName] stringByAppendingString: [[UserUtil sharedManager] email]]; // TODO (Apr 20, 2017): replace later in above if else (if visuall was created by another)
//    self.createdByLabel.layer.borderWidth = 1.0f;
//    self.createdByLabel.layer.borderColor = self.TitleTextField.layer.borderColor;
//    self.createdByLabel.layer.cornerRadius = self.TitleTextField.layer.cornerRadius;
//    self.createdByLabel.layer.cornerRadius = 8.0f;
    
    self.TitleTextField.delegate = self;
    [self.TitleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.sharedWithTextArea.layer.borderWidth = 1.0f;
    self.sharedWithTextArea.layer.cornerRadius = 4.0f;
    self.sharedWithTextArea.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.sharedWithTextArea.delegate = self;
    self.sharedWithArrayOfEmailAddresses = [NSNull null];
    
//    self.scrollView.frame = self.view.bounds;
//    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview: self.outerContainer];
    self.scrollView.contentSize = self.outerContainer.frame.size;
    
    [self updateSubviews];
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
//    [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray* words = [string componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString: delimiter];
    NSArray *arrayOfStrings = [nospacestring componentsSeparatedByString: delimiter];
    for (NSString *str in arrayOfStrings)
    {
        if ([str containsString: @"@"] && [str containsString:@"."])
        {
            [result setObject: @1 forKey: [str stringByReplacingOccurrencesOfString: @"." withString: @"%2E"]];
        }
    }
    if ( [result count] == 0)
    {
        result = nil;
    }
    return result;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
//    CGRect rect = self.outerContainer.frame;
//    self.outerContainer.center = self.view.center;
//    rect = self.outerContainer.frame;
//    rect.origin.y = 0;
//    self.outerContainer.frame = rect;
    
    [self resizeBackgroundScrollView];
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

- (void) resizeBackgroundScrollView
{
    float x = 0;
    float y = 0;
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    float h0 = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float h1 = self.navigationController.navigationBar.frame.size.height;
    float h2 = self.tabBarController.tabBar.frame.size.height;
    height = height - h0 - h1 - h2;
    self.scrollView.frame = CGRectMake(x, h0 + h1, width, height);
//    self.scrollView.frame = CGRectMake(x, y, width, height);
    
    CGRect rect = self.outerContainer.frame;
    rect.origin.x = (width - rect.size.width) / 2;
    rect.origin.y = -h0 - h1;  // hack... not sure why this doesn't work with 0
    self.outerContainer.frame = rect;
}

- (void) dismissKeyboard
{
    [self.sharedWithTextArea resignFirstResponder];
}

@end
