//
//  EmailAddresses.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface EmailAddresses : NSManagedObject

@property (nonatomic, retain) NSString * primary;
@property (nonatomic, retain) NSString * secondary;
@property (nonatomic, retain) NSString * ternary;
@property (nonatomic, retain) Person *person;

@end
