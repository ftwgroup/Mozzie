//
//  Event.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Person;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * attendees;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * ekEventsID;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSSet *manyPeople;
@property (nonatomic, retain) NSSet *manyGroups;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addManyPeopleObject:(Person *)value;
- (void)removeManyPeopleObject:(Person *)value;
- (void)addManyPeople:(NSSet *)values;
- (void)removeManyPeople:(NSSet *)values;

- (void)addManyGroupsObject:(Group *)value;
- (void)removeManyGroupsObject:(Group *)value;
- (void)addManyGroups:(NSSet *)values;
- (void)removeManyGroups:(NSSet *)values;

@end
