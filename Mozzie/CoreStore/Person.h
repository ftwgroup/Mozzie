//
//  Person.h
//  Mozzie
//
//  Created by JJ Weber on 10/18/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailAddresses, Event, Group, PhoneNumbers;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * linkedinID;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * twitterHandle;
@property (nonatomic, retain) EmailAddresses *emailAddresses;
@property (nonatomic, retain) NSSet *manyEvents;
@property (nonatomic, retain) NSSet *manyGroups;
@property (nonatomic, retain) PhoneNumbers *phoneNumbers;
@property (nonatomic) NSInteger abRecordID;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addManyEventsObject:(Event *)value;
- (void)removeManyEventsObject:(Event *)value;
- (void)addManyEvents:(NSSet *)values;
- (void)removeManyEvents:(NSSet *)values;

- (void)addManyGroupsObject:(Group *)value;
- (void)removeManyGroupsObject:(Group *)value;
- (void)addManyGroups:(NSSet *)values;
- (void)removeManyGroups:(NSSet *)values;

@end
