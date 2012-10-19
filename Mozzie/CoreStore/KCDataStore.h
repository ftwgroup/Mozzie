//
//  DataStore.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>

@interface KCDataStore : NSObject
+ (NSArray* )userTwitterHandle;
+ (NSArray* )fetchPeople;
+ (BOOL)saveEntityFromPersonRecordRef:(ABRecordRef) person;
@end
