//
//  ContactsTableViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/7/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCContactsViewController.h"
#import "KCContactTableViewController.h"
#import "KCContactSelectTableViewController.h"
#import "KCDataStore.h"
#import "UIColor+FTWColors.h"
#import "KCConstants.h"

#import <FacebookSDK/FacebookSDK.h>

@interface KCContactsViewController ()
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) KCContactSelectTableViewController* contactTable;
-(void)setupPeoplePicker;
-(void)setupSearchBar;
-(void)postAction:(NSString *)actionPath tryReauthIfNeeded:(BOOL)tryReauthIfNeeded;
-(void)postPerson:(ABRecordRef)person facebookID:(NSString *)facebookID tryReauthIfNeeded:(BOOL)tryReauthIfNeeded;

@end

//C Function for ABAddressbook API
//to access objective C methods we pass in this refToSelf
//void *refToStore;
//void storeContactsInCoreData(ABRecordRef personRecordRef, KCContactsViewController *refToSelf) {
//    [[(__bridge KCDataStore *)refToStore dataStore] saveEntityFromPersonRecordRef:personRecordRef];
//};

@implementation KCContactsViewController

@synthesize friends = _friends;

#pragma mark Display alterations for contact tableview
- (void)displayPersonSelect {
    self.contactTable.typeToDisplay = kPersonTag;
    [self.contactTable.tableView reloadData];
}

- (void)displayGroupSelect {
    self.contactTable.typeToDisplay = kGroupTag;
    [self.contactTable.tableView reloadData];
}

#pragma mark Facebook Methods

- (void)pullMyFriends {
    // check before request
    if (FBSession.activeSession.isOpen) {
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
}

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
                // Setup and save facebook data
                // this will need to harness core data
            }
        }
    }];
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
                //for (NSMutableDictionary *update in [result objectForKey:@"data"]) {
                //    NSLog(@"result: %@", update);
                //}
                KCContactTableViewController *personView = [[KCContactTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                personView.person = person;
                personView.updates = [result objectForKey:@"data"];
                [self.navigationController pushViewController:personView animated:NO];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    } else {
        
    }
}


# pragma mark - Temporary Methods for selecting contacts to view
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

    if (!self.friends) {
        [self pullMyFriends];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Setup

- (void)setup {
    [self setUpBackGroundToolBar];
    [self setupContactSelectTableView];
    [self setupTabbar];
}

- (void)setupNavButtons {
    //currently unused
}

- (void)setUpBackGroundToolBar {
    CGRect toolBarFrame = CGRectMake(0, 0, self.view.bounds.size.width, TOOL_BAR_HEIGHT);
    UIToolbar* backgroundTool = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    backgroundTool.tintColor = [UIColor clearColor];
    backgroundTool.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundTool];
}

- (void)setupTabbar {
    CGRect tabBarFrame = CGRectMake(TOOL_BUTTON_WIDTH * 2, 0, self.view.bounds.size.width - (TOOL_BUTTON_WIDTH * 4), TOOL_BAR_HEIGHT);
    UITabBar* calTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    
    UITabBarItem* people = [[UITabBarItem alloc] initWithTitle:@"People" image:nil tag:kPersonTag];
    UITabBarItem* groups = [[UITabBarItem alloc] initWithTitle:@"Groups" image:nil tag:kGroupTag];
    
    calTab.backgroundColor = [UIColor clearColor];
    calTab.tintColor = [UIColor clearColor];
    calTab.items = @[people, groups];
    calTab.selectedItem = people;
    calTab.delegate = self;
    
    [self.view addSubview:calTab];
}

- (void)setupContactSelectTableView {
    self.contactTable = [KCContactSelectTableViewController new];
    self.contactTable.tableView.frame = CGRectMake(0, TOOL_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TOOL_BAR_HEIGHT);
    self.contactTable.typeToDisplay = kPersonTag;
    [self.view addSubview:self.contactTable.view];
    [self addChildViewController:self.contactTable];
}

// Not currently using this
- (void)setupSearchBar
{
    CGRect searchFrame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchFrame];
    [self.view addSubview:searchBar];
}

#pragma mark - Tab Delegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case kPersonTag:
            [self displayPersonSelect];
            break;
        case kGroupTag:
            [self displayGroupSelect];
            break;
        default:
            break;
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
