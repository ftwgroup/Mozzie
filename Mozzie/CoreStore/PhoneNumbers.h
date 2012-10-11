//
//  PhoneNumbers.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface PhoneNumbers : NSManagedObject

@property (nonatomic, retain) NSNumber * home;
@property (nonatomic, retain) NSNumber * cell;
@property (nonatomic, retain) NSNumber * work;
@property (nonatomic, retain) Person *person;

@end
