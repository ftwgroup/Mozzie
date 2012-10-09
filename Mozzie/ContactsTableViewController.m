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
-(void)setupPeoplePicker;
-(void)setupSearchBar;
-(void)postAction:(NSString *)actionPath tryReauthIfNeeded:(BOOL)tryReauthIfNeeded;
-(void)postPerson:(ABRecordRef)person tryReauthIfNeeded:(BOOL)tryReauthIfNeeded;

@end

@implementation ContactsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Contacts";
    [self setupPeoplePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Temporary Methods for selecting contacts to view
- (void)pushToPerson:(ABRecordRef)person
{
    [self postPerson:person tryReauthIfNeeded:YES];
    ContactsViewController *personView = [[ContactsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    personView.person = person;
    [self.navigationController pushViewController:personView animated:YES];
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

- (void)postPerson:(ABRecordRef)person tryReauthIfNeeded:(BOOL)tryReauthIfNeeded
{
    // if we have a valid session, then we get the action, else noop
    if (FBSession.activeSession.isOpen) {
        
        // if we don't have permissions, then address that first
        if ([FBSession.activeSession.permissions indexOfObject:@"read_stream"] == NSNotFound) {
            [FBSession.activeSession reauthorizeWithReadPermissions:[NSArray arrayWithObject:@"read_stream"] completionHandler:^(FBSession *session, NSError *error) {
                if (!error) {
                    // re-call assuming we now have the permission
                    [self postPerson:person tryReauthIfNeeded:YES];
                }
            }];
        }
        CFStringRef socialLabel, socialNetwork;
        ABMutableMultiValueRef socialMulti = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        socialMulti = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(socialMulti); i++) {
            socialLabel = ABMultiValueCopyLabelAtIndex(socialMulti, i);
            socialNetwork = ABMultiValueCopyValueAtIndex(socialMulti, i);
        }
        // post the action using a lightweight static start method
        [FBRequestConnection startWithGraphPath:@"me/home" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                for (NSMutableDictionary *update in [result objectForKey:@"data"]) {
                    NSLog(@"result: %@", update);
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    } else {
        
    }
}

- (void)postAction:(NSString *)actionPath tryReauthIfNeeded:(BOOL)tryReauthIfNeeded
{
    // if we have a valid session, then we get the action, else noop
    if (FBSession.activeSession.isOpen) {
        
        // if we don't have permissions, then address that first
        if ([FBSession.activeSession.permissions indexOfObject:@"read_stream"] == NSNotFound) {
            [FBSession.activeSession reauthorizeWithReadPermissions:[NSArray arrayWithObject:@"read_stream"] completionHandler:^(FBSession *session, NSError *error) {
                if (!error) {
                    // re-call assuming we now have the permission
                    [self postAction:actionPath tryReauthIfNeeded:YES];
                }
            }];
        }
        // post the action using a lightweight static start method
        [FBRequestConnection startWithGraphPath:@"me/home" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                for (NSMutableDictionary *update in [result objectForKey:@"data"]) {
                    NSLog(@"result: %@", update);
                }
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
