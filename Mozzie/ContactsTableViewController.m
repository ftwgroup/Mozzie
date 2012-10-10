//
//  ContactsTableViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/7/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactsViewController.h"
#import "UIColor+FTWColors.h"

#import <FacebookSDK/FacebookSDK.h>

@interface ContactsTableViewController ()
@property (nonatomic) NSArray *friends;

-(void)setupPeoplePicker;
-(void)setupSearchBar;
-(void)postAction:(NSString *)actionPath tryReauthIfNeeded:(BOOL)tryReauthIfNeeded;
-(void)postPerson:(ABRecordRef)person facebookID:(NSString *)facebookID tryReauthIfNeeded:(BOOL)tryReauthIfNeeded;

@end

@implementation ContactsTableViewController

@synthesize friends = _friends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    // grab setup the facebook array
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"got friends");
        self.friends = friends;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupPeoplePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Temporary Methods for selecting contacts to view
- (void)getFriend:(ABRecordRef)person
{
    CFStringRef name = ABRecordCopyCompositeName(person);
    NSString *newName = (__bridge NSString *)(name);
    
    CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *NSfirstName = (__bridge NSString*)(firstName);
    NSString *NSlastName = (__bridge NSString*)(lastName);
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        NSLog(@"friend is %@",newName);
        
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSString *testFirstName = [friend valueForKey:@"first_name"];
            NSString *testLastName = [friend valueForKey:@"last_name"];
            if ([NSfirstName isEqualToString:testFirstName] && [NSlastName isEqualToString:testLastName]) {
                NSLog(@"we found %@",friend.first_name);
                // TODO (julian) still need to save and cache what we download
            }
        }
    }];
}

- (void)pushToPerson:(ABRecordRef)person
{
    NSString *facebookID;
    CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *NSfirstName = (__bridge NSString*)(firstName);
    NSString *NSlastName = (__bridge NSString*)(lastName);
    for (NSDictionary<FBGraphUser>* friend in self.friends) {
        NSString *testFirstName = [friend valueForKey:@"first_name"];
        NSString *testLastName = [friend valueForKey:@"last_name"];
        if ([NSfirstName isEqualToString:testFirstName] && [NSlastName isEqualToString:testLastName]) {
            NSLog(@"we found %@",friend.first_name);
            facebookID = friend.id;
        }
    }
    [self postPerson:person facebookID:facebookID tryReauthIfNeeded:YES];

}

- (void)setupNavButtons {
    
}

- (void)setupPeoplePicker
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.navigationBar.tintColor = [UIColor headerColor];
    peoplePicker.peoplePickerDelegate = self;
    peoplePicker.navigationBar.hidden = YES;
    [self.view addSubview:peoplePicker.view];
    [self addChildViewController:peoplePicker];
}

// Not currently using this
- (void)setupSearchBar
{
    CGRect searchFrame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchFrame];
    [self.view addSubview:searchBar];
}

- (void)postPerson:(ABRecordRef)person facebookID:(NSString *)facebookID tryReauthIfNeeded:(BOOL)tryReauthIfNeeded
{
    // if we have a valid session, then we get the action, else noop
    if (FBSession.activeSession.isOpen) {
        
        // if we don't have permissions, then address that first
        if ([FBSession.activeSession.permissions indexOfObject:@"read_stream"] == NSNotFound) {
            [FBSession.activeSession reauthorizeWithReadPermissions:[NSArray arrayWithObject:@"read_stream"] completionHandler:^(FBSession *session, NSError *error) {
                if (!error) {
                    // re-call assuming we now have the permission
                    [self postPerson:person facebookID:facebookID tryReauthIfNeeded:YES];
                }
            }];
        }

        // post the action using a lightweight static start method
        [FBRequestConnection startWithGraphPath:[facebookID stringByAppendingString:@"/feed"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                for (NSMutableDictionary *update in [result objectForKey:@"data"]) {
                    NSLog(@"result: %@", update);
                }
                ContactsViewController *personView = [[ContactsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                personView.person = person;
                personView.updates = [result objectForKey:@"data"];
                [self.navigationController pushViewController:personView animated:NO];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    } else {
        
    }
}

# pragma marker - People picker delegate methods
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self pushToPerson:person];
    return NO;
}

// This is called once a contact has been selected when we select a particular attribute
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}
@end
