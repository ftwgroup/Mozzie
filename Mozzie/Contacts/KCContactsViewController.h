//
//  ContactsTableViewController.h
//  Mozzie
//
//  Created by Julian Threatt on 10/7/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "KCContactSelectTableViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "KCPeopleManageButtonsDelegate.h"

#define TOOL_BAR_HEIGHT 40
#define TOOL_BUTTON_WIDTH 40

@interface KCContactsViewController : UIViewController <UIAlertViewDelegate, UITabBarDelegate, KCPeopleManageButtonsDelegate>
@property BOOL manageContacts;
@property (strong, nonatomic) KCContactSelectTableViewController* contactTable;
@property (strong, nonatomic) Event* event;
@end
