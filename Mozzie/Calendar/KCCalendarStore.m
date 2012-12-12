//
//  KCCalendarStore.m
//  TcacTest
//
//  Created by JJ Weber on 10/3/12.
//
//

#import "KCCalendarStore.h"
#import "KalLogic.h"
#import "NSDate+KalAdditions.h"
#import "KCConstants.h"

static KCCalendarStore* sharedStore = nil;
static dispatch_once_t pred;

@implementation KCCalendarStore

+ (KCCalendarStore* )sharedStore
{
    //from the apple docs: "An EKEventStore object requires a relatively large amount of time to initialize and release. Consequently, you should not initialize and release a separate event store for each event-related task. Instead, initialize a single event store when your app loads, and use it repeatedly to ensure that your connection is long-lived."
    
    dispatch_once(&pred, ^{
        sharedStore = [[KCCalendarStore alloc] init];
        sharedStore.EKEvents = [[EKEventStore alloc] init];
    });
    
    return sharedStore;
}

+ (NSDate* ) indexedDate {
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comps = [cal components:NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    switch (sharedStore.calendarUnit) {
        case NSDayCalendarUnit:
            comps.day += sharedStore.calendarIndex;
            break;
        case NSWeekCalendarUnit:
            comps.week += sharedStore.calendarIndex;
            //necessary for date object, which only knows its month and day
            comps.day += sharedStore.calendarIndex * 7;
            break;
        case NSMonthCalendarUnit:
            comps.month += sharedStore.calendarIndex;
            break;
        default:
            break;
    }
    
    return [cal dateFromComponents:comps];
}

+ (NSArray* )fetchEvents; {
    
    NSDate* indexedDate = [self indexedDate];
    NSDate* startOfUnit;
    NSDate* endOfUnit;

    switch (sharedStore.calendarUnit) {
        case NSDayCalendarUnit:
            startOfUnit = [indexedDate cc_dateByMovingToBeginningOfDay];
            endOfUnit = [indexedDate cc_dateByMovingToEndOfDay];
            break;
        case NSWeekCalendarUnit:
            startOfUnit = [indexedDate cc_dateByMovingToFirstDayOfTheWeek];
            endOfUnit = [indexedDate cc_dateByMovingToFirstDayOfTheFollowingWeek];
            break;
        case NSMonthCalendarUnit:
            startOfUnit = [indexedDate cc_dateByMovingToFirstDayOfTheMonth];
            endOfUnit = [indexedDate cc_dateByMovingToFirstDayOfTheFollowingMonth];
            break;
        default:
            break;
    }
    NSArray* calendarIndentifiers = [[NSUserDefaults standardUserDefaults] valueForKey:kUserSelectedCalendarIndentifiers];
    NSMutableArray* calendars = [[NSMutableArray alloc] init];
    for (NSString* calendarIndentifier in calendarIndentifiers) {
        [calendars addObject:[[KCCalendarStore sharedStore].EKEvents calendarWithIdentifier:calendarIndentifier]];
    }
    
    NSPredicate *eventPredicate = [sharedStore.EKEvents predicateForEventsWithStartDate:startOfUnit
                                                                           endDate:endOfUnit
                                                                         calendars:calendars];
    //NSPredicate * reminderPredicate =[sharedStore.EKEvents predicateForIncompleteRemindersWithDueDateStarting:startOfUnit
                                                                      //ending:endOfUnit
                                                                   //calendars:sharedStore.calendars];
    return [sharedStore.EKEvents eventsMatchingPredicate:eventPredicate];
}

+ (NSArray* )getSectionArrayForCompositeCalendar:(NSArray *)compCal {
    NSMutableArray* sections = [NSMutableArray new];
    for (EKEvent* event in compCal) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents* comps = [cal components:NSHourCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:event.startDate];
        NSInteger hour = comps.hour;
        NSInteger day = comps.day;

        switch (sharedStore.calendarUnit) {
            case NSDayCalendarUnit:
                if (![sections containsObject:[NSNumber numberWithInt:hour]])
                    [sections addObject:[NSNumber numberWithInt:hour]];
                break;
            case NSWeekCalendarUnit:
                if (![sections containsObject:[NSNumber numberWithInt:day]])
                    [sections addObject:[NSNumber numberWithInt:day]];
                break;
            case NSMonthCalendarUnit:
                if (![sections containsObject:[NSNumber numberWithInt:day]])
                    [sections addObject:[NSNumber numberWithInt:day]];
                break;
                
            default:
                break;
        }
    }
    return [NSArray arrayWithArray:sections];
}

+ (NSInteger )getEventsCountForSection:(NSInteger)section InCompositeCalendar:(NSArray *)compCal {
    NSInteger calendarSectionCount = 0;
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    for (EKEvent* event in compCal) {
        NSDateComponents* comps = [cal components:NSHourCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:event.startDate];
        NSInteger hour = comps.hour;
        NSInteger day = comps.day;
        
        switch (sharedStore.calendarUnit) {
            case NSDayCalendarUnit:
                if (hour == section) {
                    calendarSectionCount++;
                }
                break;
            case NSWeekCalendarUnit:
                if (day == section) {
                    calendarSectionCount++;
                }
                break;
            case NSMonthCalendarUnit:

                if (day == section) {
                    calendarSectionCount++;
                }
                break;
            default:
                break;
        }
    }
    return calendarSectionCount;
}

+ (NSString* )newEventWithName:(NSString *)eventName StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate calendar:(NSCalendar *)selectedCalendar {
    EKEvent* newEvent = [EKEvent eventWithEventStore:sharedStore.EKEvents];
    newEvent.title = eventName;
    newEvent.startDate = startDate;
    newEvent.endDate = endDate;
    newEvent.calendar = selectedCalendar;
    NSError* error;
    
    [sharedStore.EKEvents saveEvent:newEvent span:EKSpanThisEvent error:&error];
    if (!error) {
        return [[NSString alloc] initWithFormat:@"%@", newEvent.eventIdentifier];
    } else {
        return @"";
    }
}

@end
