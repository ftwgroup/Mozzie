//
//  Event.h
//  Mozzie
//
//  Created by FTWGroup on 10/31/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Person;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * ekEventsID;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSSet *manyGroups;
@property (nonatomic, retain) NSSet *manyPeople;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addManyGroupsObject:(Group *)value;
- (void)removeManyGroupsObject:(Group *)value;
- (void)addManyGroups:(NSSet *)values;
- (void)removeManyGroups:(NSSet *)values;

- (void)addManyPeopleObject:(Person *)value;
- (void)removeManyPeopleObject:(Person *)value;
- (void)addManyPeople:(NSSet *)values;
- (void)removeManyPeople:(NSSet *)values;

@end
