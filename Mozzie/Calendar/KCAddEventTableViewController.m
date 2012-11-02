//  KCAddEventViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/16/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCAddEventTableViewController.h"
#import "UIColor+FTWColors.h"
#import "KCDataStore.h"
#import "KCCalendarStore.h"
#import "KCContactsViewController.h"
#import "Person.h"
#import "Group.h"

@interface KCAddEventTableViewController ()
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@property (nonatomic, strong) NSIndexPath* indexPathForDeletion;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSDate* endDate;
//location is only a string for now
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* eventName;
//todo, add calendar selector to this view
@property (strong, nonatomic) NSCalendar* selectedCalendar; 
@property (strong, nonatomic) NSNumber* status1confirmed0pending;
//for comparision with latest instance of selected people
@property (strong, nonatomic) NSMutableDictionary* displayedPeople;
@end

@implementation KCAddEventTableViewController


#pragma mark DatePicker
- (void)datePickerDidChangeValue:(UIDatePicker *)picker {
    if (picker.tag == 0) {
        self.startDate = picker.date;
        if ([self.endDate earlierDate:self.startDate] == self.endDate) {
            self.endDate = self.startDate;
        }
    } else {
        self.endDate = picker.date;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Recognizers

- (void)didTapTableView {
    [self.view endEditing:YES];
}

#pragma mark - Display Selected People
- (void)displayCleanup {
    NSMutableArray* displayedIDstoRemove = [NSMutableArray new];
    NSArray* iteratedCopy = [self.displayedPeople allKeys];
    
    for (NSManagedObjectID* objectID in iteratedCopy) {
        if ([self.selectedObjects objectForKey:objectID]) {
            continue;
        }
        //remove
        NSIndexPath* pathToRemove = [self.displayedPeople objectForKey:objectID];
        NSArray* indexPathsToRemove = [self.model removeObjectAtIndexPath:pathToRemove];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:UITableViewRowAnimationNone];
        [self.displayedPeople removeObjectForKey:objectID];
        [displayedIDstoRemove addObject:objectID];
        
        for (NSManagedObjectID* objectID in self.displayedPeople) {
            NSIndexPath* indexPathToUpdate = [self.displayedPeople objectForKey:objectID];
            if ([indexPathToUpdate compare:pathToRemove] == NSOrderedDescending) {
                indexPathToUpdate = [NSIndexPath indexPathForRow:indexPathToUpdate.row - 1 inSection:indexPathToUpdate.section];
                [self.displayedPeople setObject:indexPathToUpdate forKey:objectID];
            }
        }
    }
}

- (void)displayRefresh {
    for (NSManagedObjectID* objectID in self.selectedObjects) {
        if (![self.displayedPeople objectForKey:objectID]) {
            //add
            NSManagedObject* objectToAdd = [[KCDataStore context] objectWithID:objectID];
            NITitleCellObject* titleCell;
            if ([objectToAdd class] == [Person class]) {
                titleCell = [NITitleCellObject objectWithTitle:[objectToAdd valueForKey:@"firstName"]];
            } else {
                titleCell = [NITitleCellObject objectWithTitle:[objectToAdd valueForKey:@"name"]];
            }
            
            NSIndexPath* addedCellLocation = [[self.model addObject:titleCell toSection:1] objectAtIndex:0];
            [self.displayedPeople setObject:addedCellLocation forKey:objectID];
        }
    }
    
    [self.model updateSectionIndex];
    [self.tableView reloadData];
}

- (void)displaySelectedPeople {
    [self displayCleanup];
    [self displayRefresh];
}

-(id)initWithEvent:(EKEvent*)event
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"New Event";
        
        self.actions = [[NITableViewActions alloc] initWithController:self];
        // TODO (julian) needs to be able to handle the case of an all day event
        NSArray* tableElements =
        [NSArray arrayWithObjects:@"Details",
         [NITextInputFormElement textInputElementWithID:0
                                        placeholderText:@"Name"
                                                  value:event.title
                                               delegate:self],
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"Start Time"
                                                     date:event.startDate
                                           datePickerMode:UIDatePickerModeDateAndTime
                                          didChangeTarget:self
                                        didChangeSelector:@selector(datePickerDidChangeValue:)],
         [NIDatePickerFormElement datePickerElementWithID:1
                                                labelText:@"End Time"
                                                     date:event.endDate
                                           datePickerMode:UIDatePickerModeDateAndTime
                                          didChangeTarget:self
                                        didChangeSelector:@selector(datePickerDidChangeValue:)],
         @"People",
         @"Status",
         [NISegmentedControlFormElement segmentedControlElementWithID:0
                                                            labelText:@"Status"
                                                             segments:[NSArray arrayWithObjects:
                                                                       @"Pending", @"Confirmed", nil]
                                                        selectedIndex:0
                                                      didChangeTarget:self
                                                    didChangeSelector:@selector(segmentedControlDidChangeValue:)],
         @"Location",
         [NITextInputFormElement textInputElementWithID:1
                                        placeholderText:@"TBD"
                                                  value:event.location
                                               delegate:self],
         nil];
        
        self.model = [[NIMutableTableViewModel alloc] initWithSectionedArray:tableElements
                                                                    delegate:(id)[NICellFactory class]];
    }
    return self;
}

#pragma init Nimbus Style
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"New Event";
        
        self.actions = [[NITableViewActions alloc] initWithController:self];
        
        NSArray* tableElements =
        [NSArray arrayWithObjects:@"Details",
         [NITextInputFormElement textInputElementWithID:0
                                        placeholderText:@"Title"
                                                  value:nil
                                               delegate:self],
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"Start Time"
                                                     date:[NSDate date]
                                           datePickerMode:UIDatePickerModeDateAndTime
                                          didChangeTarget:self
                                        didChangeSelector:@selector(datePickerDidChangeValue:)],
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"End Time"
                                                     date:[NSDate date]
                                           datePickerMode:UIDatePickerModeDateAndTime
                                          didChangeTarget:self
                                        didChangeSelector:@selector(datePickerDidChangeValue:)],
         @"Attendees",
         [self.actions attachNavigationAction:NIPushControllerAction([KCContactsViewController class])
                                     toObject:[NITitleCellObject
                                               objectWithTitle:@"Edit attendee list"]],
         @"Status",
         [NISegmentedControlFormElement segmentedControlElementWithID:0
                                                            labelText:@"Status"
                                                             segments:[NSArray arrayWithObjects:
                                                                       @"Pending", @"Confirmed", nil]
                                                        selectedIndex:0
                                                      didChangeTarget:self
                                                    didChangeSelector:@selector(segmentedControlDidChangeValue:)],
         @"Location",
         [NITextInputFormElement textInputElementWithID:1
                                        placeholderText:@"TBD"
                                                  value:nil
                                               delegate:self],
         nil];
        
        self.model = [[NIMutableTableViewModel alloc] initWithSectionedArray:tableElements
                                                             delegate:(id)[NICellFactory class]];
    }
    return self;
}

#pragma mark Nav Methods

//unused
- (void)navAddPersonOrGroup {
    KCContactsViewController* contactSelect = [KCContactsViewController new];
    contactSelect.contactTable.selectedObjects = self.selectedObjects;
    
    [self.navigationController pushViewController:contactSelect animated:YES];
}

- (void)navCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navDone {
    NSString* eventID = [KCCalendarStore newEventWithName:_eventName
                                                StartDate:_startDate
                                                  EndDate:_endDate
                                                 calendar:_selectedCalendar];
    [KCDataStore saveEventWithName:_eventName
                         StartDate:_startDate
                           EndDate:_endDate
                          location:_location
                            status:_status1confirmed0pending
                            people:_selectedObjects
                        ekEventsID:eventID];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Segmented Control
 - (void)segmentedControlDidChangeValue:(UISegmentedControl *)segmentedControl {
     self.status1confirmed0pending = [NSNumber numberWithInteger:segmentedControl.selectedSegmentIndex];
 }

#pragma mark Setup
- (void)setupNavBar {
//    UIBarButtonItem* addPerson = [[UIBarButtonItem alloc] initWithTitle:@"Peeps"
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:self
//                                                                 action:@selector(navAddPersonOrGroup)];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(navDone)];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(navCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
}


#pragma mark - shouldAutorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}

#pragma mark - TableViewCell Config
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Customize the presentation of certain types of cells.
    // example code:
//    if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
//        NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
//        if (1 == cell.tag) {
//            // Make the disabled input field look slightly different.
//            textInputCell.textField.textColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
//            
//        } else {
//            // We must always handle the else case because cells can be reused.
//            textInputCell.textField.textColor = [UIColor blackColor];
//        }
//    }
}


#pragma mark - NIMutableTableViewModelDelegate

//example code

- (BOOL)tableViewModel:(NIMutableTableViewModel *)tableViewModel
         canEditObject:(id)object
           atIndexPath:(NSIndexPath *)indexPath
           inTableView:(UITableView *)tableView {
    return NO;
}


- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
    return [NICellFactory tableViewModel:tableViewModel
                        cellForTableView:tableView
                             atIndexPath:indexPath
                              withObject:object];
}


#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        self.eventName = textField.text;
    } else if (textField.tag == 1) {
        self.location = textField.text;
    }
    return YES;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - View did
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self.model;
    self.tableView.delegate = [self.actions forwardingTo:self];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
    self.displayedPeople = [NSMutableDictionary new];
    [self setupNavBar];
    
    //cancel editing gesture
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(didTapTableView)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

@end
