//
//  Group.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Person;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *manyPeople;
@property (nonatomic, retain) NSSet *manyEvents;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addManyPeopleObject:(Person *)value;
- (void)removeManyPeopleObject:(Person *)value;
- (void)addManyPeople:(NSSet *)values;
- (void)removeManyPeople:(NSSet *)values;

- (void)addManyEventsObject:(Event *)value;
- (void)removeManyEventsObject:(Event *)value;
- (void)addManyEvents:(NSSet *)values;
- (void)removeManyEvents:(NSSet *)values;

@end
