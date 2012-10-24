//
//  Person.h
//  Mozzie
//
//  Created by FTWGroup on 10/23/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailAddress, Event, Group, PhoneNumber;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * abRecordID;
@property (nonatomic, retain) NSNumber * facebookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * linkedinID;
@property (nonatomic, retain) NSString * mozzieIdentifier;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSNumber * onPhone;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * twitterHandle;
@property (nonatomic, retain) NSSet *emailAddresses;
@property (nonatomic, retain) NSSet *manyEvents;
@property (nonatomic, retain) NSSet *manyGroups;
@property (nonatomic, retain) NSSet *phoneNumbers;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addEmailAddressesObject:(EmailAddress *)value;
- (void)removeEmailAddressesObject:(EmailAddress *)value;
- (void)addEmailAddresses:(NSSet *)values;
- (void)removeEmailAddresses:(NSSet *)values;

- (void)addManyEventsObject:(Event *)value;
- (void)removeManyEventsObject:(Event *)value;
- (void)addManyEvents:(NSSet *)values;
- (void)removeManyEvents:(NSSet *)values;

- (void)addManyGroupsObject:(Group *)value;
- (void)removeManyGroupsObject:(Group *)value;
- (void)addManyGroups:(NSSet *)values;
- (void)removeManyGroups:(NSSet *)values;

- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;

@end
