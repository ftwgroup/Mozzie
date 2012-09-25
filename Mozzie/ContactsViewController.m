//
//  ContactsViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "ContactsViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

@interface ContactsViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel *model;
@end

@implementation ContactsViewController

@synthesize model = _model;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // This controller uses the Nimbus table view model. In loose terms, Nimbus models implement
        // data source protocols. They encapsulate standard delegate functionality and will make your
        // life a lot easier. In this particular case we're using NITableViewModel with a list of
        // objects.
        //
        // Each of these objects implements the NICellObject protocol which requires the object to
        // implement the method "cellClass". This method is called by the NICellFactory to determine
        // which UITableViewCell implementation should be used to display this object.
        //
        // When a cell is about to be created, the model asks its delegate to create a cell with the
        // given object. In most cases the delegate is [NICellFactory class]. NICellFactory implements
        // the NITableViewModelDelegate protocol as static methods, allowing us to use it as a delegate
        // without instantiating it.
        //
        // Once the cell is created, shouldUpdateCellWithObject: is called on the cell, giving it the
        // opportunity to update itself accordingly.
    
        NSArray* tableContents =
        [NSArray arrayWithObjects:
         // Shows a cell with a title.
         [NITitleCellObject objectWithTitle:@"Row 1"],
         [NITitleCellObject objectWithTitle:@"Row 2"],
         
         // Shows a cell with a title and subtitle.
         [NISubtitleCellObject objectWithTitle:@"Row 3" subtitle:@"Subtitle"],
         nil];
        
        // NITableViewModel may be initialized with two types of arrays: list and sectioned.
        // A list array is a list of objects, where each object in the array will map to a cell in
        // the table view.
        // A sectioned array is a list of NSStrings and objects, where each NSString starts a new
        // section and any other type of object is a cell.
        //
        // As discussed above, we provide the model with the NICellFactory class as its delegate.
        // In a future example we will show how you can create a NICellFactory object to override the
        // default mappings that the cell objects return from their cellClass implementation.
        //
        // Further exploration:
        // Check out the NICellFactory implementation and notice how the NITableViewModelDelegate
        // methods are implemented twice. First as class methods (+ as a prefix), second as
        // instance methods (- as a prefix). This allows you to use NICellFactory's class object as
        // the delegate or to instantiate the NICellFactory as an object and provide explicit mappings.
        _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                    delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.dataSource = _model;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NIIsSupportedOrientation(toInterfaceOrientation);
}
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
//}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

@end
