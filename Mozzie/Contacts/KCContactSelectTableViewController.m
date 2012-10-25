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
#import "Person.h"
#import "Group.h"

@interface KCContactSelectTableViewController ()
@property (nonatomic, strong) NSArray* personObjects;;
@property (nonatomic, readwrite, retain) NSArray* groupObjects;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self queryDataStore];
}

- (void)queryDataStore {
    
//    if (self.typeToDisplay == kPersonTag) {
//        for (Person *contact in [KCDataStore fetchEntity:@"Person"]) {
//            if (contact.firstName) {
//                NSString* fullName = [[contact.firstName stringByAppendingString:@" "] stringByAppendingString:contact.lastName];
//                [nameArr addObject:[NISubtitleCellObject objectWithTitle:fullName subtitle:contact.nickName]];
//            }
//        }
//    } else {
//        for (Group *group in [KCDataStore fetchEntity:@"Group"]) {
//            if (group.name) {
//                [nameArr addObject:[NITitleCellObject objectWithTitle:group.name]];
//            }
//        }
//    }
    self.personObjects = [KCDataStore fetchEntity:@"Person"];
    self.groupObjects = [KCDataStore fetchEntity:@"Group"];
    
    
    [self.tableView reloadData];
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
    
    switch (self.typeToDisplay) {
        case kPersonTag:
            cell.textLabel.text = [[self.personObjects objectAtIndex:index] valueForKey:@"firstName"];
            break;
        case kGroupTag:
            cell.textLabel.text = [[self.groupObjects objectAtIndex:index] valueForKey:@"name"];
            break;
        default:
            break;
    }    
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
    // TODO allow multiple selections with custom animation and store them
}



@end
