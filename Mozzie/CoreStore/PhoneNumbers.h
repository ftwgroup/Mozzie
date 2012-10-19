//
//  PhoneNumbers.h
//  Mozzie
//
//  Created by JJ Weber on 10/18/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface PhoneNumbers : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) Person *person;

@end
