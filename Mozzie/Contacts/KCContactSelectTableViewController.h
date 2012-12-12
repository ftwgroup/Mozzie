//
//  KCContactSelectTableViewController.h
//  Mozzie
//
//  Created by JJ Weber on 10/17/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCore.h"
#import "NimbusModels.h"
#import <AddressBook/AddressBook.h>
#import "KCPeopleManageButtonsDelegate.h"

@interface KCContactSelectTableViewController : UITableViewController <KCPeopleManageButtonsDelegate>
- (void)queryDataStore;
@property (nonatomic, strong) NSArray* personObjects;;
@property (nonatomic, strong) NSArray* groupObjects;
@property NSInteger typeToDisplay;
@property NSMutableDictionary* selectedObjects;
@property (nonatomic, weak) id <KCPeopleManageButtonsDelegate> buttonDelegate;
@end
