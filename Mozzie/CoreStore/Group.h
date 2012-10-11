//
//  Group.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Person *people;

@end
