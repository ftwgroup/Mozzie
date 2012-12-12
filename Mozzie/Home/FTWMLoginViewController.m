//
//  FTWMLoginViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/2/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "FTWMLoginViewController.h"
#import "UIColor+FTWColors.h"
#import "KCConstants.h"
#import "FTWMAppDelegate.h"
#import "KCImportViewController.h"
#import "STKeychain.h"

#define KEYBOARD_ANIMATION_DURATION 0.3
#define MINIMUM_SCROLL_FRACTION 0.2
#define MAXIMUM_SCROLL_FRACTION 0.8
#define PORTRAIT_KEYBOARD_HEIGHT 216
#define LANDSCAPE_KEYBOARD_HEIGHT 162

@interface FTWMLoginViewController ()
@property CGFloat animatedDistance;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
- (IBAction)createButton:(UIButton *)sender;

@end

@implementation FTWMLoginViewController

- (IBAction)cancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@synthesize spinner = _spinner;

#pragma mark Alerts
- (void)throwAlertForMessage:(NSString* )message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Information"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark Check for validity
- (BOOL)checkThatFieldsAreValid {
    //copied email regex
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailTest evaluateWithObject:self.emailField.text]) {
        //
    } else {
        [self throwAlertForMessage:@"Unrecognized email address format."];
        return NO;
    }
    
    if ([self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        if (self.passwordField.text.length < 6) {
            [self throwAlertForMessage:@"Password should be at least 6 characters in length."];
            return NO;
        }
    } else {
        [self throwAlertForMessage:@"Passwords do not match."];
        return NO;
    }
    return YES;
}

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
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmPasswordField.delegate = self;
    self.title = @"Create Account";
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
    // TODO This is a bug waiting to happen
    NSError* error;
    [sender becomeFirstResponder];
    if ([self checkThatFieldsAreValid]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.emailField.text forKey:kUserEmail];
        [STKeychain storeUsername:self.emailField.text
                      andPassword:self.passwordField.text
                   forServiceName:kServiceMozzieApp
                   updateExisting:NO
                            error:&error];
        [self.navigationController pushViewController:[KCImportViewController new] animated:YES];
    }
    if (!error) {
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        NSLog(@"Failed to save user in Key Chain");
    }
    
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
//prevent keyboard from obscuring text fields
//http://www.cocoawithlove.com/2008/10/sliding-uitextfields-around-to-avoid.html

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else {
        _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

@end
