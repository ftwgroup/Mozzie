//
//  CalendarEventList.m
//  TcacTest
//
//  Created by JJ Weber on 10/2/12.
//
//

#import "KCCalendarEventListTableView.h"
#import "KCCalendarStore.h"
#import <EventKit/EventKit.h>
#import "UIColor+FTWColors.h"
#import "KalLogic.h"

@interface KCCalendarEventListTableView ()
@property (strong, nonatomic) NSArray* compositeCalendar;
@property (strong, nonatomic) NSArray* sectionArray;
@property (strong, nonatomic) NSMutableArray* sectionSizes;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.compositeCalendar = [KCCalendarStore fetchEvents];
    self.sectionArray = [KCCalendarStore getSectionArrayForCompositeCalendar:self.compositeCalendar];
    self.sectionSizes = [[NSMutableArray alloc] initWithCapacity:self.sectionArray.count];
    for (int i = 0; i < self.sectionArray.count; i++) {
        [self.sectionSizes addObject:[NSNumber numberWithInt:0]];
    }
    return self.sectionArray.count;
}

- (void)tableViewCellConfiguration:(UITableViewCell*)cell ForIndex:(NSInteger )index {

    EKEvent* eventAtIndex = [self.compositeCalendar objectAtIndex:index];
    cell.backgroundColor = [UIColor colorWithCGColor:eventAtIndex.calendar.CGColor];

    NSString* displayDate;
    KalLogic* displayLogic = [[KalLogic alloc] initForDate:[NSDate date]];
    //set basedate explcicitly, otherwise it is the beginning of the month
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", displayDate ,eventAtIndex.title];
}

- (NSInteger)tableView:(UITableView* )tableView numberOfRowsInSection:(NSInteger)section
{
    //section is the group
    NSInteger calSection = [[self.sectionArray objectAtIndex:section] integerValue];
    NSInteger sectionSize = [KCCalendarStore getEventsCountForSection:calSection InCompositeCalendar:self.compositeCalendar];

    [self.sectionSizes insertObject:[NSNumber numberWithInt:sectionSize] atIndex:section];
    return sectionSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger addPrevious = 0;
    NSInteger untilNow = indexPath.section;
    for (NSInteger i = 0; i < untilNow; i++) {
        //NSLog(@"%d", [[self.sectionSizes objectAtIndex:i] integerValue]);
        addPrevious = addPrevious + [[self.sectionSizes objectAtIndex:i] integerValue];
    }
    
    NSInteger index = indexPath.row + addPrevious;
    [self tableViewCellConfiguration:cell ForIndex:index];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Nothing for now...
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - View Did 

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAppearance];
}

@end
