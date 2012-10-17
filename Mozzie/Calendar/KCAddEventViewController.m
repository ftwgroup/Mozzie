//
//  KCAddEventViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/16/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCAddEventViewController.h"
#import "UIColor+FTWColors.h"

@interface KCAddEventViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end

@implementation KCAddEventViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        NSArray* tableElements = [NSArray arrayWithObjects:@"Event",
                                   [NITextInputFormElement textInputElementWithID:0
                                                                  placeholderText:@"Name of event"
                                                                            value:nil],
                                   [NIDatePickerFormElement datePickerElementWithID:1 labelText:@"When" date:[NSDate date] datePickerMode:UIDatePickerModeDateAndTime], nil];
        self.model = [[NITableViewModel alloc] initWithSectionedArray:tableElements
                                                             delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Once the tableView has loaded we attach the model to the data source. As mentioned above,
    // NITableViewModel implements UITableViewDataSource so that you don't have to implement any
    // of the data source methods directly in your controller.
    self.tableView.dataSource = self.model;
    
    // What we're doing here is known as "delegate chaining". It uses the message forwarding
    // functionality of Objective-C to insert the actions object between the table view
    // and this controller. The actions object forwards UITableViewDelegate methods along and
    // selectively intercepts methods required to make user interactions work.
    //
    // Experiment: try commenting out this line. You'll notice that you can no longer tap any of
    // the cells in the table view and that they no longer show the disclosure accessory types.
    // Cool, eh? That this functionality is all provided to you in one line should make you
    // heel-click.
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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

@end
