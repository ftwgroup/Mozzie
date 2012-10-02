//
//  FTWMLoginViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/2/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "FTWMLoginViewController.h"
#import "FTWMAppDelegate.h"

@interface FTWMLoginViewController ()

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)performLogin:(id)sender;

@end

@implementation FTWMLoginViewController

@synthesize loginButton = _loginButton;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)performLogin:(id)sender {
    [self.spinner startAnimating];
    
    // The user has initiated a login, so call the openSession method
    FTWMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];
}

-(void)loginFailed
{
    // Our UI is quite simple so all we need to do in this case of the user
    // getting back to this screen without having been successfull authorized
    // is to stop showing our activity indicator.
    [self.spinner stopAnimating];
}
@end
