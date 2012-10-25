//
//  KCImportViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/24/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCImportViewController.h"
#import "KCCalendarViewController.h"
#import "FTWMAppDelegate.h"
#import "KCDataStore.h"

@interface KCImportViewController ()
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@end

@implementation KCImportViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initiatePermissions {
    // The user has initiated a login, so ask for permissions
    FTWMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSessionWithAllowLoginUI:YES];
    [appDelegate permissionsCalendar];
    [appDelegate permissionsTwitter];
    [appDelegate permissionAddressBook];
}

- (void)pullFB {
    //
}

- (void)pushToCalendar {
    [self.navigationController pushViewController:[KCCalendarViewController new] animated:YES];
}

- (void)pullTwitter {
    //
}

- (void)cloneContacts {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [self synchAppDBWithAddressBook];
}

- (void)setupNavbar {
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(pushToCalendar)];
    doneButton.title = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)setupPeopleImportButtons {
    CGRect fbFrame = CGRectMake(20, 50, 280, 40);
    UIButton* fbButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fbButton.frame = fbFrame;
    [fbButton setTitle:@"Facebook"
                    forState:UIControlStateNormal];
    [fbButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.view addSubview:fbButton];
    
    [fbButton addTarget:self
                       action:@selector(pullFB)
             forControlEvents:UIControlEventTouchUpInside];
    
    CGRect twFrame = CGRectMake(20, 100, 280, 40);
    UIButton* twButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    twButton.frame = twFrame;
    [twButton setTitle:@"Twitter"
                 forState:UIControlStateNormal];
    [twButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.view addSubview:twButton];
    
    [twButton addTarget:self
                    action:@selector(pullTwitter)
          forControlEvents:UIControlEventTouchUpInside];
    
    CGRect calFrame = CGRectMake(20, 150, 280, 40);
    UIButton* calButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    calButton.frame = calFrame;
    [calButton setTitle:@"AddressBook"
                    forState:UIControlStateNormal];
    [calButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; ;
    [self.view addSubview:calButton];
    
    [calButton addTarget:self
                       action:@selector(cloneContacts)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect spinnerFrame = CGRectMake((self.view.bounds.size.width / 2) - 25, (self.view.bounds.size.height / 2) - 25, 50, 50);
    self.spinner.frame = spinnerFrame;
    self.spinner.hidesWhenStopped = YES;
}

# pragma mark - Synch
# pragma mark - Contacts
- (void)synchAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Would you like to synch your contacts with Mozzie?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [alertView resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 0) {
        [self synchAppDBWithAddressBook];
    }
    [alertView resignFirstResponder];
}

- (void)synchAppDBWithAddressBook {
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        CFErrorRef *abError = NULL;
    //        CFArrayRef personArr;
    //        ABAddressBookRef myAB = ABAddressBookCreateWithOptions(nil, abError);
    //        if (abError) {
    //            NSLog(@"AddressBook failed to init with error %@", CFErrorCopyDescription(*abError));
    //        } else {
    //            personArr = ABAddressBookCopyArrayOfAllPeople(myAB);
    //            for (int i = 0; i < CFArrayGetCount(personArr); i++) {
    //                [KCDataStore saveEntityFromPersonRecordRef:CFArrayGetValueAtIndex(personArr, i)];
    //            }
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done Synching!"
    //                                                                message:nil delegate:self
    //                                                      cancelButtonTitle:@"Ok"
    //                                                      otherButtonTitles:nil, nil];
    //                [alert show];
    //            });
    //        }
    //    });
    //non-asynch
    CFErrorRef *abError = NULL;
    CFArrayRef personArr;
    ABAddressBookRef myAB = ABAddressBookCreateWithOptions(nil, abError);
    if (abError) {
        NSLog(@"AddressBook failed to init with error %@", CFErrorCopyDescription(*abError));
    } else {
        personArr = ABAddressBookCopyArrayOfAllPeople(myAB);
        for (int i = 0; i < CFArrayGetCount(personArr); i++) {
            [KCDataStore saveEntityFromPersonRecordRef:CFArrayGetValueAtIndex(personArr, i)];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done synching Addressbook!"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [self.spinner stopAnimating];
        [alert show];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Import";
    [self setupPeopleImportButtons];
    [self setupNavbar];
    [self initiatePermissions];
}



@end
