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
+ (NSManagedObjectContext*) context;
+ (NSManagedObjectModel *) model;

+ (NSArray* )userTwitterHandle;
+ (NSArray* )fetchEntity:(NSString *)entity;

+ (BOOL)saveEntityFromPersonRecordRef:(ABRecordRef) person;
+ (BOOL)isInDB:(NSNumber* )ID Entity:(NSString *)entity;
+ (BOOL)removeDuplicatesByIDsAndSave:(NSArray* )ids;
@end
