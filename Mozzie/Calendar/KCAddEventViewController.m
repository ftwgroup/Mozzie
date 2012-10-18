//
//  KCAddEventViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/16/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCAddEventViewController.h"
#import "UIColor+FTWColors.h"
#import "KCContactsTableViewController.h"

@interface KCAddEventViewController ()
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@property (nonatomic, strong) NSIndexPath* indexPathForDeletion;
@property (strong, nonatomic) NSDate* startDate;
//location is only a string for now
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* eventName;
@property (strong, nonatomic) NSNumber* status1confirmed0pending;
@end

@implementation KCAddEventViewController


#pragma mark DatePicker
- (void)datePickerDidChangeValue:(UIDatePicker *)picker {
    self.startDate = picker.date;
    NSLog(@"selected date: %@, ", [NSDateFormatter localizedStringFromDate:picker.date
                                            dateStyle:NSDateFormatterNoStyle
                                            timeStyle:NSDateFormatterShortStyle]);
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
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"End Time"
                                                     date:event.endDate
                                           datePickerMode:UIDatePickerModeDateAndTime
                                          didChangeTarget:self
                                        didChangeSelector:@selector(datePickerDidChangeValue:)],
         @"People",
         [NITitleCellObject objectWithTitle:@"Add a contact or group"],
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
                                        placeholderText:@"Name"
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
         @"People",
         [NITitleCellObject objectWithTitle:@"Add a contact or group"],
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
- (void)navAddPersonOrGroup {
    [self.navigationController pushViewController:[KCContactsTableViewController new] animated:YES];
}

- (void)navCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navDone {
    //save
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Segmented Control
 - (void)segmentedControlDidChangeValue:(UISegmentedControl *)segmentedControl {
     self.status1confirmed0pending = [NSNumber numberWithInteger:segmentedControl.selectedSegmentIndex];
 }

#pragma mark Setup
- (void)setupNavBar {
    UIBarButtonItem* addPerson = [[UIBarButtonItem alloc] initWithTitle:@"Peeps"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(navAddPersonOrGroup)];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(navDone)];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(navCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItems = @[doneButton, addPerson];
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

//remove people/groups
- (BOOL)tableViewModel:(NIMutableTableViewModel *)tableViewModel
         canEditObject:(id)object
           atIndexPath:(NSIndexPath *)indexPath
           inTableView:(UITableView *)tableView {
    if (indexPath.section == 1 && indexPath.row > 0) {
        return YES;
    } else {
        return NO;
    }
}

//example code
- (BOOL)tableViewModel:(NIMutableTableViewModel *)tableViewModel
    shouldDeleteObject:(id)object
           atIndexPath:(NSIndexPath *)indexPath
           inTableView:(UITableView *)tableView {
    // We're going to store the index path that wants to be deleted so that we can delete the correct
    // cell after the alert view has been dismissed.
    self.indexPathForDeletion = indexPath;
    
    // Rather than allow the model to simply delete the object, we're going to present a prompt that
    // confirms with the user that they want to delete this object.
    UIAlertView *confirmationAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                                    message:@"Are you that sure you want to delete this cell?"
                                                                   delegate:self
                                                          cancelButtonTitle:@"No"
                                                          otherButtonTitles:@"Yes", nil];
    [confirmationAlertView show];
    return NO;
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
    [self setupNavBar];
    
    //cancel editing gesture
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

@end
