//
//  KCContactSelectTableViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/17/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCContactSelectTableViewController.h"
#import "KCConstants.h"
#import "KCDataStore.h"
#import "KCAddEventTableViewController.h"
#import "Person.h"
#import "Group.h"

@interface KCContactSelectTableViewController ()
@property (nonatomic, strong) NSArray* personObjects;;
@property (nonatomic, strong) NSArray* groupObjects;
@end

@implementation KCContactSelectTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Contacts";
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableViewCellConfiguration:(UITableViewCell*)cell ForIndex:(NSInteger )index {
    
    Person* personAtIndex;
    Group* groupAtIndex;
    switch (self.typeToDisplay) {
        case kPersonTag:
            personAtIndex = [self.personObjects objectAtIndex:index];
            cell.textLabel.text = [personAtIndex valueForKey:@"firstName"];
            //check to see if this item is selected:
            if ([self.selectedObjects objectForKey:[personAtIndex objectID]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case kGroupTag:
            groupAtIndex = [self.groupObjects objectAtIndex:index];
            cell.textLabel.text = [groupAtIndex valueForKey:@"name"];

            if ([self.selectedObjects objectForKey:[groupAtIndex objectID]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (NSInteger)tableView:(UITableView* )tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.typeToDisplay) {
        case kPersonTag:
            return self.personObjects.count;
            break;
        case kGroupTag:
            return self.groupObjects.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self tableViewCellConfiguration:cell ForIndex:indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person* selectedPerson;
    Group* selectedGroup;
    // TODO allow multiple selections with custom animation
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (self.typeToDisplay) {
            case kPersonTag:
                selectedPerson = [self.personObjects objectAtIndex:indexPath.row];
                [self.selectedObjects removeObjectForKey:[selectedPerson
                                                 objectID]];
                break;
            case kGroupTag:
                selectedGroup = [self.groupObjects objectAtIndex:indexPath.row];
                [self.selectedObjects removeObjectForKey:[selectedGroup
                                                 objectID]];
                break;
            default:
                break;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        switch (self.typeToDisplay) {
            case kPersonTag:
                selectedPerson = [self.personObjects objectAtIndex:indexPath.row];
                [self.selectedObjects setObject:selectedPerson
                                         forKey:[selectedPerson
                                                 objectID]];
                break;
            case kGroupTag:
                selectedGroup = [self.groupObjects objectAtIndex:indexPath.row];
                [self.selectedObjects setObject:selectedGroup
                                         forKey:[selectedGroup
                                                 objectID]];
                break;
            default:
                break;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)queryDataStore {
    self.personObjects = [KCDataStore fetchEntity:@"Person"];
    self.groupObjects = [KCDataStore fetchEntity:@"Group"];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //multiple selection!
    self.tableView.allowsMultipleSelection = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self queryDataStore];
}

@end
