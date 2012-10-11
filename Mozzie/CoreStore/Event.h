//
//  Events.h
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * attendees;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * ekEventsID;
@property (nonatomic, retain) NSString * endTime;

@end
