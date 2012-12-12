//
//  CalendarViewController.m
//  TcacTest
//
//  Created by JJ Weber on 10/1/12.
//
//

#import "KCCalendarViewController.h"
#import "KCCalendarStore.h"
#import "UIColor+FTWColors.h"
#import "KalDate.h"
#import "KalLogic.h"
#import "KCConstants.h"
#import "KCContactsViewController.h"
#import "KCAddEventTableViewController.h"

@interface KCCalendarViewController ()
@property UITapGestureRecognizer* tapRec;
@end

@implementation KCCalendarViewController

#pragma mark - Add Events
- (void)addEvent {
    KCAddEventTableViewController* addEvent = [[KCAddEventTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    addEvent.eventStore = [KCCalendarStore sharedStore].EKEvents;
    addEvent.tableView.backgroundColor = [UIColor backgroundColor];
    [self.navigationController pushViewController:addEvent animated:YES];
    //UINavigationController* modalNav = [[UINavigationController alloc] initWithRootViewController:addEvent];
    //modalNav.navigationBar.tintColor = [UIColor headerColor];
    //modalNav.modalTransitionStyle = kAppWideModalStyle;
    //[self presentViewController:modalNav
    //                   animated:YES
    //                 completion:nil];
}

#pragma mark - Calendar chooser methods

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [calendarChooser dismissViewControllerAnimated:YES completion:nil];
    [self.calendarTable.tableView reloadData];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    NSArray* selectedCalendars = [NSArray arrayWithArray:[calendarChooser.selectedCalendars allObjects]];
    NSMutableArray* selectedCalendarIndentifiers = [NSMutableArray new];
    for (EKCalendar* calendar in selectedCalendars) {
        [selectedCalendarIndentifiers addObject:calendar.calendarIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] setObject:selectedCalendarIndentifiers forKey:kUserSelectedCalendarIndentifiers];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.calendarTable.tableView reloadData];
    [calendarChooser dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    //NSArray* selectedCalendars = [calendarChooser.selectedCalendars allObjects];
}

#pragma mark - Calendar methods

- (void)calIndexUpOne {
    [KCCalendarStore sharedStore].calendarIndex++;
    NSDate* indexedDate = [KCCalendarStore indexedDate];
    [self updateCalendarTitleToDate:indexedDate];
    [self.calendarTable.tableView reloadData];
}

- (void)calIndexCalDownOne {
    [KCCalendarStore sharedStore].calendarIndex--;
    NSDate* indexedDate = [KCCalendarStore indexedDate];
    [self updateCalendarTitleToDate:indexedDate];
    [self.calendarTable.tableView reloadData];
}

#pragma mark Configurations
- (void)calendarSelect {
    EKCalendarChooser* calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple
                                                                              displayStyle:EKCalendarChooserDisplayAllCalendars
                                                                                entityType:EKEntityTypeEvent
                                                                                eventStore:[KCCalendarStore sharedStore].EKEvents];
    NSArray* selectedCalendarIndentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSelectedCalendarIndentifiers];
    NSMutableArray* selectedCalendars = [NSMutableArray new];
    for (NSString* calendarIndentifier in selectedCalendarIndentifiers) {
        [selectedCalendars addObject:[[KCCalendarStore sharedStore].EKEvents calendarWithIdentifier:calendarIndentifier]];
    }
    calendarChooser.selectedCalendars = [NSSet setWithArray:selectedCalendars];
    calendarChooser.showsCancelButton = YES;
    calendarChooser.showsDoneButton = YES;
    calendarChooser.delegate = self;
    calendarChooser.modalTransitionStyle = kAppWideModalStyle;
    UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
    cntrol.navigationBar.tintColor =[UIColor headerColor];
    cntrol.delegate = self;
    [self presentViewController:cntrol animated:YES completion:nil];
}

- (void)contactsManage {
    KCContactsViewController* contactsManage = [KCContactsViewController new];
    contactsManage.manageContacts = YES;
    [self.navigationController pushViewController:contactsManage animated:YES];
}

#pragma mark - Fill in

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Recognizer Delegates
- (void)handleTap:(UITapGestureRecognizer* )sender {
    // insert free sections between all unfilled time spaces.
    self.calendarTable.freeTimeView = !self.calendarTable.freeTimeView;
    [self.calendarTable.tableView reloadData];
}

#pragma mark - Event edit delegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action   {
    [controller dismissViewControllerAnimated:YES completion:^{
        [self.calendarTable.tableView reloadData];
    }];
}

//- (EKCalendar* )eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
//}


#pragma mark - Nav Delegate

- (void)navConfigTableView:(UITableView* )tv {
    tv.backgroundColor = [UIColor backgroundColor];
    tv.backgroundView = [UIView new];
    tv.backgroundView.backgroundColor = [UIColor backgroundColor];
}

//this is to access the tableview inside the EventKit's UI
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController.view isKindOfClass:[UITableView class]]) {
        [self navConfigTableView:((UITableView *)viewController.view)];
    }
    
    for (UIViewController* childView in [viewController childViewControllers]) {
        if ([childView isKindOfClass:[UITableView class]]) {
            [self navConfigTableView:((UITableViewController*)childView).tableView];
        }
    }
    
    for (UIView* subView in [viewController view].subviews) {
        if ([subView isKindOfClass:[UITableView class]]) {
            [self navConfigTableView:((UITableView *)subView)];
        }
    }
}

#pragma mark - Setup methods

- (void)setupAppearance {
    self.view.backgroundColor = [UIColor backgroundColor];
    //nav delegate accesses the tableviews
}

//currently unused
- (void)setupUserCalendars {
}

//currently unused
- (void)setupActionsToolbar {
    [self.navigationController setToolbarHidden:NO];
    
    self.navigationController.toolbar.tintColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    UIBarButtonItem* filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Cals"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(calendarSelect)];
    
    UIBarButtonItem* createButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(addEvent)];
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    
    
    separator.width = self.view.bounds.size.width - (TOOL_BUTTON_WIDTH * 2);
    NSArray* toolbarItems = @[createButton, separator, filterButton];
    [self setToolbarItems:toolbarItems];
}

- (void)setupCalToolbar {
    
    CGRect toolBarFrame = CGRectMake(0, 0, self.view.bounds.size.width, TOOL_BAR_HEIGHT);
    UIToolbar* calTool = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    
    UIBarButtonItem* rightArrow = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"kal_right_arrow.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(calIndexUpOne)];
    rightArrow.width = TOOL_BUTTON_WIDTH;
    UIBarButtonItem* leftArrow = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"kal_left_arrow.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(calIndexCalDownOne)];
    leftArrow.width = TOOL_BUTTON_WIDTH;
    
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    
    
    separator.width = self.view.bounds.size.width - (TOOL_BUTTON_WIDTH * 2);
    calTool.items = @[leftArrow, separator, rightArrow];
    
    calTool.tintColor = [UIColor clearColor];
    calTool.backgroundColor = [UIColor clearColor];
    [self.view addSubview:calTool];
}

- (void)setupEventList {
    [self tabToDay];
    self.calendarTable = [[KCCalendarEventListTableView alloc] initWithStyle:UITableViewStyleGrouped];
    self.calendarTable.tableView.frame = CGRectMake(0, TOOL_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TOOL_BAR_HEIGHT);
    
    [self.view addSubview:self.calendarTable.tableView];
    [self addChildViewController:self.calendarTable];
    
    //iOS 6 requires permissions, not sure how this plays out?    
}

- (void)setupNavbar {
    UIBarButtonItem* contactsManageButton = [[UIBarButtonItem alloc] initWithTitle:@"Peeps"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(contactsManage)];
    
    UIBarButtonItem* filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Cals"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(calendarSelect)];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addEvent)];
    self.navigationItem.rightBarButtonItems = @[addButton, filterButton];
    self.navigationItem.leftBarButtonItem = contactsManageButton;
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(informedOfCalendarPermissions:)
                                                 name:kCalendarPermissionsNotification
                                               object:nil];
}

- (void)setupGestureRecognizers {
    self.tapRec = [UITapGestureRecognizer new];
    self.tapRec.delegate = self;
    self.tapRec.numberOfTapsRequired = 2;
    [self.tapRec addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:self.tapRec];
}

- (void)setupTabbar {
    CGRect tabBarFrame = CGRectMake(TOOL_BUTTON_WIDTH * 2, 0, self.view.bounds.size.width - (TOOL_BUTTON_WIDTH * 4), TOOL_BAR_HEIGHT);
    UITabBar* calTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    
    UITabBarItem* day = [[UITabBarItem alloc] initWithTitle:@"Day"
                                                      image:nil
                                                        tag:NSDayCalendarUnit];
    UITabBarItem* week = [[UITabBarItem alloc] initWithTitle:@"Week"
                                                       image:nil
                                                         tag:NSWeekCalendarUnit];
    UITabBarItem* month = [[UITabBarItem alloc] initWithTitle:@"Month"
                                                        image:nil
                                                          tag:NSMonthCalendarUnit];
    
    calTab.backgroundColor = [UIColor clearColor];
    calTab.tintColor = [UIColor clearColor];
    calTab.items = @[day, week, month];
    calTab.selectedItem = day;
    calTab.delegate = self;
    
    [self.view addSubview:calTab];
}

- (void)setupView {
    [self setupAppearance];
    self.navigationController.delegate = self;
    [self setupCalToolbar];
    //[self setupActionsToolbar];
    [self setupTabbar];
    [self setupNavbar];
    [self setupUserCalendars];
    [self setupEventList];
}

#pragma mark - Tab Delegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case NSDayCalendarUnit:
            [self tabToDay];
            break;
        case NSWeekCalendarUnit:
            [self tabToWeek];
            break;
        case NSMonthCalendarUnit:
            [self tabToMonth];
            break;
            
        default:
            break;
    }
}

#pragma mark - Tab Methods

- (void)tabToDay {
    [self titleForDay:[NSDate date]];
    [KCCalendarStore sharedStore].calendarIndex = 0;
    [KCCalendarStore sharedStore].calendarUnit = NSDayCalendarUnit;
    [self.calendarTable.tableView reloadData];
    
}

- (void)titleForDay:(NSDate* )date {
    KalDate* day = [KalDate dateFromNSDate:date];
    self.title = [day description];
}

- (void)tabToMonth {
    [self titleForMonth:[NSDate date]];
    [KCCalendarStore sharedStore].calendarIndex = 0;
    [KCCalendarStore sharedStore].calendarUnit = NSMonthCalendarUnit;
    [self.calendarTable.tableView reloadData];
    
}

- (void)titleForMonth:(NSDate* )date {
    KalLogic* titleLogic = [[KalLogic alloc] initForDate:date];
    self.title = [titleLogic selectedMonthNameAndYear];
}

- (void)tabToWeek {
    [KCCalendarStore sharedStore].calendarIndex = 0;
    [KCCalendarStore sharedStore].calendarUnit = NSWeekCalendarUnit;
    [self titleForWeek:[NSDate date]];
    [self.calendarTable.tableView reloadData];
}

- (void)titleForWeek:(NSDate* )date {
    NSCalendar *currentCal = [NSCalendar currentCalendar];
    NSDateComponents* weekComp = [currentCal components:NSWeekCalendarUnit fromDate:date];
    self.title = [NSString stringWithFormat:@"Week %d",weekComp.week];
}

- (void)updateCalendarTitleToDate:(NSDate*) date {
    switch ([KCCalendarStore sharedStore].calendarUnit) {
        case NSDayCalendarUnit:
            [self titleForDay:date];
            break;
        case NSWeekCalendarUnit:
            [self titleForWeek:date];
            break;
        case NSMonthCalendarUnit:
            [self titleForMonth:date];
            break;
        default:
            break;
    }
}

#pragma Mark - ViewDid methods 
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self setupGestureRecognizers];
    [self setupNotifications];
}

//show calendar options
- (void)viewWillAppear:(BOOL)animated {
    [self.calendarTable.tableView reloadData];
}

//hide calendar options
- (void)viewWillDisappear:(BOOL)animated {
    //unset some key properties
    //[self.calendarTable removeFromParentViewController];
    NSLog(@"viewWillDisappear");
    //especially this delegate, which will try to call some methods after dealloc if we are not careful. 
    //self.navigationController.delegate = nil;
    //[self.navigationController setToolbarHidden:YES];
}

@end
