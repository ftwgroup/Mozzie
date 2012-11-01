//
//  ContactsTableViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/7/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCContactsViewController.h"
#import "KCContactTableViewController.h"
#import "KCNewGroupTableViewController.h"
#import "KCAddEventTableViewController.h"
#import "KCDataStore.h"
#import "Group.h"
#import "Person.h"
#import "UIColor+FTWColors.h"
#import "KCConstants.h"

#import <FacebookSDK/FacebookSDK.h>

@interface KCContactsViewController ()
@property (strong, nonatomic) NSArray *friends;
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

#pragma mark Add Selected People to Event
- (void)addSelectedPeopleToEvent {
    
}

#pragma mark Display alterations for contact tableview
- (void)displayPersonSelect {
    self.contactTable.typeToDisplay = kPersonTag;
    [self.contactTable.tableView reloadData];
}

- (void)displayGroupSelect {
    self.contactTable.typeToDisplay = kGroupTag;
    [self.contactTable.tableView reloadData];
}

#pragma mark Done Selecting
- (void)doneSelecting {
    NSArray* viewControllersToInform = self.navigationController.viewControllers;
    for (UIViewController* vc in viewControllersToInform) {
        if ([vc class] == [KCAddEventTableViewController class]) {
            ((KCAddEventTableViewController *)vc).selectedObjects = self.contactTable.selectedObjects;
            [((KCAddEventTableViewController *)vc) displaySelectedPeople];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark Navigate to Manage Actions
- (void)newGroup {
    KCNewGroupTableViewController* newGroup = [KCNewGroupTableViewController new];
    newGroup.selectedObjects = self.contactTable.selectedObjects;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:newGroup];
    nav.navigationBar.tintColor = [UIColor headerColor];
    [self presentViewController:nav animated:YES completion:nil];
    
    //clear selection and update data source
    self.contactTable.selectedObjects = [NSMutableDictionary new];
    NSArray* selectionsToClear = [self.contactTable.tableView indexPathsForSelectedRows];
    for (NSIndexPath* indexPathToClear in selectionsToClear) {
        UITableViewCell* cell = [self.contactTable.tableView cellForRowAtIndexPath:indexPathToClear];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.contactTable.tableView deselectRowAtIndexPath:indexPathToClear animated:NO];
    }
    [self.contactTable.tableView reloadData];
}

- (void)deleteEntities {
    [self.contactTable.tableView beginUpdates];
    NSMutableArray* rowsToDelete = [NSMutableArray new];
    NSMutableArray* deletedObjects = [NSMutableArray new];
    for (NSManagedObjectID* objectID in self.contactTable.selectedObjects) {
        NSManagedObject* objectToDelete;
        NSIndexPath* rowToDelete;
        switch (self.contactTable.typeToDisplay) {
            case kPersonTag:
                objectToDelete = [[KCDataStore context] objectRegisteredForID:objectID];
                if ([objectToDelete class] == [Person class]) {
                    [[KCDataStore context] deleteObject:objectToDelete];
                    [deletedObjects addObject:objectID];
                    rowToDelete = [NSIndexPath indexPathForRow:[self.contactTable.personObjects indexOfObject:objectToDelete]inSection:0];
                    [rowsToDelete addObject:rowToDelete];
                }
                break;
            case kGroupTag:
                objectToDelete = [[KCDataStore context] objectRegisteredForID:objectID];
                if ([objectToDelete class] == [Group class]) {
                    [[KCDataStore context] deleteObject:objectToDelete];
                    [deletedObjects addObject:objectID];
                    rowToDelete = [NSIndexPath indexPathForRow:[self.contactTable.groupObjects indexOfObject:objectToDelete]inSection:0];
                    [rowsToDelete addObject:rowToDelete];
                }
                break;
            default:
                break;
        }
    }

    NSError* error;
    [[KCDataStore context] save:&error];
    if (!error) {
        [self.contactTable.tableView deleteRowsAtIndexPaths:rowsToDelete
                                           withRowAnimation:UITableViewRowAnimationFade];
        [self.contactTable queryDataStore];
    } else {
        NSLog(@"Failed to save deletions with error: %@", [error localizedDescription]);
    }
    for (NSManagedObjectID* deleted in deletedObjects) {
        [self.contactTable.selectedObjects removeObjectForKey:deleted];
    }
    self.contactTable.selectedObjects = [NSMutableDictionary new];
    [self.contactTable.tableView endUpdates];
}

#pragma mark Setup

- (void)setup {
    [self setUpBackGroundToolBar];
    [self setupContactSelectTableView];
    [self setupTabbar];
    [self setupNavButtons];
    [self setupSelectedObjects];
}

- (void)setupNavButtons {
    if (self.manageContacts) {
        UIBarButtonItem* contactsManageButton = [[UIBarButtonItem alloc] initWithTitle:@"Create Group"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(newGroup)];
        
        UIBarButtonItem* filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(deleteEntities)];
        
        self.navigationItem.rightBarButtonItems = @[contactsManageButton, filterButton];
    } else {
        UIBarButtonItem* doneSelecting = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(doneSelecting)];
        self.navigationItem.rightBarButtonItem = doneSelecting;
    }
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

- (void)setupSelectedObjects {
    NSArray* viewControllersHearFrom = self.navigationController.viewControllers;
    for (UIViewController* vc in viewControllersHearFrom) {
        if ([vc class] == [KCAddEventTableViewController class]) {
            self.contactTable.selectedObjects = ((KCAddEventTableViewController *)vc).selectedObjects;
            [self.contactTable.tableView reloadData];
        }
    }
    if (!self.contactTable.selectedObjects) {
        self.contactTable.selectedObjects = [NSMutableDictionary new];
    }
}


// Not currently using this
- (void)setupSearchBar
{
    CGRect searchFrame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchFrame];
    [self.view addSubview:searchBar];
}

#pragma mark - Tab Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
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

@end
