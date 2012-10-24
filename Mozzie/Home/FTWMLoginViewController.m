//
//  FTWMLoginViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/2/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "FTWMLoginViewController.h"
#import "UIColor+FTWColors.h"
#import "FTWMAppDelegate.h"

@interface FTWMLoginViewController ()


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
- (IBAction)createButton:(UIButton *)sender;

- (IBAction)performLogin:(id)sender;

@end

@implementation FTWMLoginViewController

- (IBAction)cancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@synthesize spinner = _spinner;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.spinner stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createButton:(UIButton *)sender {
    
}

-(void)loginFailed
{
    // Our UI is quite simple so all we need to do in this case of the user
    // getting back to this screen without having been successfull authorized
    // is to stop showing our activity indicator.
    [self.spinner stopAnimating];
}

#pragma mark - Gesture Recognizers

- (void)didTapTableView {
    [self.view endEditing:YES];
}

#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (IBAction)performLogin:(id)sender {
    [self.spinner startAnimating];
    
    // The user has initiated a login, so call the openSession method
    FTWMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];
}

@end
