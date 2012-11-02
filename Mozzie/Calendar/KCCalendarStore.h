//
//  KCCalendarStore.h
//  TcacTest
//
//  Created by JJ Weber on 10/3/12.
//
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface KCCalendarStore : NSObject
+ (KCCalendarStore* )sharedStore;
+ (NSArray* )fetchEvents;
+ (NSDate* )indexedDate;
+ (NSArray* )getSectionArrayForCompositeCalendar:(NSArray* )compCal;
+ (NSInteger )getEventsCountForSection:(NSInteger)section InCompositeCalendar:(NSArray *)compCal;
+ (NSString* )newEventWithName:(NSString* )eventName StartDate:(NSDate* )startDate EndDate:(NSDate* )endDate calendar:(NSCalendar* )selectedCalendar;
@property (nonatomic, strong) EKEventStore* EKEvents;
@property NSUInteger calendarUnit;
@property NSInteger calendarIndex;
@end
