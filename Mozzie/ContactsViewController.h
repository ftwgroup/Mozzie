//
//  ContactsViewController.h
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ContactsViewController : UITableViewController
@property (nonatomic) ABRecordRef person;
@end
