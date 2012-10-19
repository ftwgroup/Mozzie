//
//  KCProfileViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/16/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "UIColor+FTWColors.h"
#import "KCProfileTableViewController.h"
#import "KCFaceView.h"
#import "KCDataStore.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface KCProfileTableViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel *model;
@property (strong, nonatomic) ACAccountStore* accountStore;
@property (strong, nonatomic) NSDictionary* pulledTweets;
@end

@implementation KCProfileTableViewController

- (id)initWithStyle:(UITableViewStyle)style

{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = @"User name";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.accountStore) {
        self.accountStore = [[ACAccountStore alloc] init];
        [self pullTwitterFeed];
    }
    
    [self synchAlert];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Pull Feeds

-(void) pullTwitterFeed {
    ACAccount* userTwitterAccount;
    ACAccountType* twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    //check for access first
    if (!twitterAccountType.accessGranted) {
        return;
    }
    
    //proceed with request
    NSArray* twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
    //check for the users selected account
    NSArray* checkForUserAccount = [KCDataStore userTwitterHandle];
    if (checkForUserAccount.count == 0) {
        userTwitterAccount = [twitterAccounts objectAtIndex:0];
    } else {
        for (ACAccount* account in twitterAccounts) {
            if (account.username == [checkForUserAccount objectAtIndex:0]) {
                userTwitterAccount = account;
            }
        }
    }
    
    NSURL* userTimeLine = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
    NSDictionary* params = [NSDictionary dictionaryWithObject:@"1" forKey:@"count"];
    SLRequest* twitRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodGET
                                                          URL:userTimeLine
                                                   parameters:params];
    twitRequest.account = userTwitterAccount;
    [twitRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSLog(@"Twitter timeline request failed with error: %@", [error localizedDescription]);
        }
        if (urlResponse.statusCode == 200) {
            NSError* JSONerror;
            self.pulledTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&JSONerror];
            NSLog(@"Pulled tweets:%@", self.pulledTweets);
            [self.tableView reloadData];
        } else {
            NSLog(@"Twitter HTTP error code: %d", urlResponse.statusCode);
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NIIsSupportedOrientation(toInterfaceOrientation);
}

# pragma mark - Setup

- (void) setupTableView {
    
    //self.model = [[NITableViewModel alloc] initWithSectionedArray:tableContents delegate:(id)[NICellFactory class]];
    
    self.tableView.dataSource = self.model;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
    [self setupTableHeaderView];
}


- (void) setupTableHeaderView
{
    KCFaceView *faceView = [[KCFaceView alloc] initWithNibName:nil bundle:nil];
    faceView.view.backgroundColor = [UIColor backgroundColor];
    self.tableView.tableHeaderView = faceView.view;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done Synching!"
                                                            message:nil
                                                       delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end
