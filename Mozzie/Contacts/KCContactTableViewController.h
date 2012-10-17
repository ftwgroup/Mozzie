//
//  ContactsViewController.h
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

#import "NimbusAttributedLabel.h"
#import "NimbusModels.h"
#import "NimbusCore.h"

@interface KCContactTableViewController : UITableViewController <NIAttributedLabelDelegate>
@property (nonatomic) ABRecordRef person;
@property (nonatomic) NSArray *updates;
@end
