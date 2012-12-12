//
//  CalendarEventList.m
//  TcacTest
//
//  Created by JJ Weber on 10/2/12.
//
//

#import "KCCalendarEventListTableView.h"
#import "KCCalendarStore.h"
#import "KCAddEventTableViewController.h"
#import <EventKit/EventKit.h>
#import "UIColor+FTWColors.h"
#import "KCConstants.h"
#import "KalLogic.h"

@interface KCCalendarEventListTableView ()
@property (strong, nonatomic) NSArray* compositeCalendar;
@property (strong, nonatomic) NSArray* sectionArray;
@property (strong, nonatomic) NSMutableArray* sectionSizes;

-(NSInteger)getIndex:(NSIndexPath*)indexPath;
@end

@implementation KCCalendarEventListTableView

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupAppearance {
    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.tableView.backgroundView = [UIView new];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
}

- (NSInteger)getIndex:(NSIndexPath *)indexPath
{
    NSInteger addPrevious = 0;
    NSInteger untilNow = indexPath.section;
    for (NSInteger i = 0; i < untilNow; i++) {
        //NSLog(@"%d", [[self.sectionSizes objectAtIndex:i] integerValue]);
        addPrevious = addPrevious + [[self.sectionSizes objectAtIndex:i] integerValue];
    }
    
    NSInteger index = indexPath.row + addPrevious;
    return index;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.compositeCalendar = [KCCalendarStore fetchEvents];
    self.sectionArray = [KCCalendarStore getSectionArrayForCompositeCalendar:self.compositeCalendar];
    self.sectionSizes = [[NSMutableArray alloc] initWithCapacity:self.sectionArray.count];
    for (int i = 0; i < self.sectionArray.count; i++) {
        [self.sectionSizes addObject:[NSNumber numberWithInt:0]];
    }
    NSUInteger scheduledSections = self.sectionArray.count;
    if (!self.freeTimeView) {
        return scheduledSections;
    } else {
        NSUInteger freeSections = scheduledSections * 2;
        return freeSections + 1;
    }
}

- (void)tableViewCellConfiguration:(UITableViewCell*)cell ForIndex:(NSIndexPath* )indexPath {
    EKEvent* eventAtIndex;
    
    if (!self.freeTimeView) {
        eventAtIndex = [self.compositeCalendar objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor colorWithCGColor:eventAtIndex.calendar.CGColor];
    } else {
        if ((indexPath.section % 2) == 0) {
            eventAtIndex = nil;
            cell.backgroundColor = [UIColor grayColor];
        } else {
            //continue from here
            NSUInteger adjustedIndex = (indexPath.row - 1) / 2;
            eventAtIndex = [self.compositeCalendar objectAtIndex:adjustedIndex];
            cell.backgroundColor = [UIColor colorWithCGColor:eventAtIndex.calendar.CGColor];
        }
    }

    NSString* displayDate;
    KalLogic* displayLogic = [[KalLogic alloc] initForDate:[NSDate date]];
    //set basedate explcicitly, otherwise it is the beginning of the month
    if (!eventAtIndex) {
        displayDate = @"Freedom";
    } else {
        displayLogic.baseDate = eventAtIndex.startDate;
        switch ([KCCalendarStore sharedStore].calendarUnit) {
            case NSDayCalendarUnit:
                displayDate = [displayLogic selectedHourName];
                break;
            case NSWeekCalendarUnit:
                displayDate = [displayLogic selectedDayName];
                break;
            case NSMonthCalendarUnit:
                displayDate = [displayLogic selectedDayName];
                break;
            default:
                break;
        }
    }
    
    NSString* title;
    if (!eventAtIndex.title) {
        title = @"";
    } else {
        title = eventAtIndex.title;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", displayDate ,title];
}

- (NSInteger)tableView:(UITableView* )tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.freeTimeView) {
        //section is the group
        NSInteger calSection = [[self.sectionArray objectAtIndex:section] integerValue];
        NSInteger sectionSize = [KCCalendarStore getEventsCountForSection:calSection InCompositeCalendar:self.compositeCalendar];
        
        [self.sectionSizes insertObject:[NSNumber numberWithInt:sectionSize] atIndex:section];
        return sectionSize;
    } else {
        if ((section % 2) == 0) {
            return 1;
        } else {
            NSUInteger adjustedSection = (section - 1) / 2;
            NSInteger calSection = [[self.sectionArray objectAtIndex:adjustedSection] integerValue];
            NSInteger sectionSize = [KCCalendarStore getEventsCountForSection:calSection InCompositeCalendar:self.compositeCalendar];
            
            [self.sectionSizes insertObject:[NSNumber numberWithInt:sectionSize] atIndex:section];
            return sectionSize;
        }
    }
}

//continue from here:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSIndexPath* fullPath = [NSIndexPath indexPathForRow:[self getIndex:indexPath]
                                               inSection:indexPath.section];
    [self tableViewCellConfiguration:cell ForIndex:fullPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO (julian) we need to add options for doing more than just editing an event
    EKEvent* eventAtIndex = [self.compositeCalendar objectAtIndex:[self getIndex:indexPath]];

    KCAddEventTableViewController *eventForm = [[KCAddEventTableViewController alloc] initWithEvent:eventAtIndex];
    [self.navigationController pushViewController:eventForm animated:YES];
    NSLog(@"selected");
}

#pragma mark - View Did 

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAppearance];
}

@end
