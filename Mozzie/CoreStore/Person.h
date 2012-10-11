//
//  Person.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * linkedinID;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSNumber * phoneNum;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * twitterHandle;


@end
