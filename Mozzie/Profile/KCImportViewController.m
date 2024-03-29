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
#import "KCConstants.h"
#import "UIColor+FTWColors.h"
#import "KCDataStore.h"
#import "KCCalendarStore.h"

@interface KCImportViewController ()
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (strong, nonatomic) FTWMAppDelegate* appDelegate;
@end

@implementation KCImportViewController

- (void)cloneContacts {
    [self.appDelegate permissionAddressBook];
    self.spinner.hidden = NO;
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    [self.view setUserInteractionEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self synchAppDBWithAddressBook];
    });
}

#pragma mark - Calendar chooser methods

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [calendarChooser dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    NSArray* selectedCalendars = [NSArray arrayWithArray:[calendarChooser.selectedCalendars allObjects]];
    NSMutableArray* selectedCalendarIndentifiers = [NSMutableArray new];
    for (EKCalendar* calendar in selectedCalendars) {
        [selectedCalendarIndentifiers addObject:calendar.calendarIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] setObject:selectedCalendarIndentifiers forKey:kUserSelectedCalendarIndentifiers];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [calendarChooser dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    //ok...
}

- (void)calendarSelect {
    [self.appDelegate permissionsCalendar];
    
    //clone of method in Calendar View
    EKCalendarChooser* calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple
                                                                              displayStyle:EKCalendarChooserDisplayAllCalendars
                                                                                entityType:EKEntityTypeEvent
                                                                                eventStore:[KCCalendarStore sharedStore].EKEvents];
    NSArray* selectedCalendarIndentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSelectedCalendarIndentifiers];
    NSMutableArray* selectedCalendars = [NSMutableArray new];
    for (NSString* calendarIndentifier in selectedCalendarIndentifiers) {
        [selectedCalendars addObject:[[KCCalendarStore sharedStore].EKEvents calendarWithIdentifier:calendarIndentifier]];
    }
    calendarChooser.selectedCalendars = [NSSet setWithArray:selectedCalendars];
    calendarChooser.showsCancelButton = YES;
    calendarChooser.showsDoneButton = YES;
    calendarChooser.view.backgroundColor = [UIColor backgroundColor];
    calendarChooser.delegate = self;
    calendarChooser.modalTransitionStyle = kAppWideModalStyle;
    UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
    cntrol.navigationBar.tintColor =[UIColor headerColor];
    cntrol.delegate = self;
    [self presentViewController:cntrol animated:YES completion:nil];
    //[self presentViewController:calendarChooser animated:YES completion:nil];
    //[self.navigationController pushViewController:calendarChooser animated:YES];
}

#pragma mark - Nav Delegate

- (void)navConfigTableView:(UITableView* )tv {
    tv.backgroundColor = [UIColor backgroundColor];
    tv.backgroundView = [UIView new];
    tv.backgroundView.backgroundColor = [UIColor backgroundColor];
}

//this is to access the tableview inside the EventKit's UI
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([viewController.view isKindOfClass:[UITableView class]]) {
        [self navConfigTableView:((UITableView *)viewController.view)];
    }
    
    for (UIViewController* childView in [viewController childViewControllers]) {
        if ([childView isKindOfClass:[UITableView class]]) {
            [self navConfigTableView:((UITableViewController*)childView).tableView];
        }
    }
    
    for (UIView* subView in [viewController view].subviews) {
        if ([subView isKindOfClass:[UITableView class]]) {
            [self navConfigTableView:((UITableView *)subView)];
        }
    }
    
}

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

- (void)pullFB {
    [self.appDelegate openSessionWithAllowLoginUI:YES];
}

- (void)pushToCalendar {
    [self.navigationController pushViewController:[KCCalendarViewController new] animated:YES];
}

- (void)pullTwitter {
    [self.appDelegate permissionsTwitter];
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
    [calButton setTitle:@"Calendar"
                    forState:UIControlStateNormal];
    [calButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; ;
    [self.view addSubview:calButton];
    
    [calButton addTarget:self
                       action:@selector(calendarSelect)
             forControlEvents:UIControlEventTouchUpInside];
    
    CGRect abFrame = CGRectMake(20, 200, 280, 40);
    UIButton* abButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    abButton.frame = abFrame;
    [abButton setTitle:@"AddressBook"
               forState:UIControlStateNormal];
    [abButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; ;
    [self.view addSubview:abButton];
    
    [abButton addTarget:self
                  action:@selector(cloneContacts)
        forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)setupSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    NSInteger spinnerHeight = self.view.bounds.size.height - (self.view.bounds.size.height / 4);
    CGRect spinnerFrame = CGRectMake((self.view.bounds.size.width / 2) - 25, spinnerHeight, 50, 50);
    self.spinner.frame = spinnerFrame;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
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
    CFErrorRef *abError = NULL;
    CFArrayRef personArr;
    ABAddressBookRef myAB = ABAddressBookCreateWithOptions(nil, abError);
    if (abError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"AddressBook failed to init with error %@", CFErrorCopyDescription(*abError));
        });
    } else {
        personArr = ABAddressBookCopyArrayOfAllPeople(myAB);
        for (int i = 0; i < CFArrayGetCount(personArr); i++) {
            [KCDataStore saveEntityFromPersonRecordRef:CFArrayGetValueAtIndex(personArr, i)];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done importing AddressBook!"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [alert show];
            [self.view setUserInteractionEnabled:YES];
        });
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Import";
    [self setupSpinner];
    [self setupPeopleImportButtons];
    [self setupNavbar];
    self.navigationController.delegate = self; 
    self.appDelegate = [UIApplication sharedApplication].delegate;
}



@end
