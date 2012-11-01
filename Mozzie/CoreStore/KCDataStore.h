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

+ (BOOL)saveEventWithName:(NSString* )eventName StartDate:(NSDate* )startDate EndDate:(NSDate* )endDate location:(NSString* )location status:(NSNumber* )statusSwitch people:(NSDictionary* )selectedObjects ekEventsID:(NSString* )ekEventsID;
+ (BOOL)groupHasUniqueName:(NSString* )name;
+ (BOOL)saveGroupWithName:(NSString* )name AndPeople:(NSArray* )people;
+ (BOOL)saveEntityFromPersonRecordRef:(ABRecordRef) person;
+ (BOOL)isInDB:(NSNumber* )ID Entity:(NSString *)entity;
+ (BOOL)removeDuplicatesByIDsAndSave:(NSArray* )ids;
@end
