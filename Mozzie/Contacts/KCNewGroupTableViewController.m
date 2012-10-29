//
//  KCNewGroupTableViewController.m
//  Mozzie
//
//  Created by FTWGroup on 10/29/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCNewGroupTableViewController.h"
#import "KCDataStore.h"
#import "UIColor+FTWColors.h"
#import "Person.h"
#import "Group.h"

@interface KCNewGroupTableViewController ()
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, strong) NITableViewActions* actions;
@property (nonatomic, strong) NSString* groupName;
@property (nonatomic, strong) NSMutableArray* addedObjects;
@end

@implementation KCNewGroupTableViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"New Group";        
        NSArray* tableElements = [NSArray arrayWithObjects:@"Name of Group",
                                  [NITextInputFormElement textInputElementWithID:0
                                                                 placeholderText:@"The Greatest Group in the Universe"
                                                                           value:nil
                                                                        delegate:self], nil];
        self.model = [[NIMutableTableViewModel alloc] initWithSectionedArray:tableElements
                                                                    delegate:(id)[NICellFactory class]];
    }
    return self;
}


- (void)navCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navDone {
    //save
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Setup
- (void)setupNavBar {    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(navDone)];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(navCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)setupMembersArray {
    //extract displayable information from objects
    self.addedObjects = [NSMutableArray new];
    for (NSManagedObjectID* objectID in self.selectedObjects) {
        NSManagedObject* objectToAdd = [[KCDataStore context] objectRegisteredForID:objectID];
        [self.addedObjects addObject:objectToAdd];
    }
    
    NSMutableArray* addedObjectNames = [NSMutableArray arrayWithCapacity:self.addedObjects.count];
    
    NITitleCellObject* titleCell;
    for (NSManagedObject* objectToAdd in self.addedObjects) {
        if ([objectToAdd class] == [Person class]) {
            titleCell = [NITitleCellObject objectWithTitle:[objectToAdd valueForKey:@"firstName"]];
            [addedObjectNames addObject:titleCell];
        } else {
            titleCell = [NITitleCellObject objectWithTitle:[objectToAdd valueForKey:@"name"]];
            [addedObjectNames addObject:titleCell];
        }
    }
    
    
    //add a variable amount of members
    NSIndexSet* indexSet = [self.model addSectionWithTitle:@"Members of Group"];
    
    [self.model addObjectsFromArray:addedObjectNames];
    [self.model updateSectionIndex];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - shouldAutorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        self.groupName = textField.text;
    } else if (textField.tag == 1) {
        self.groupName = textField.text;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self.model;
    self.tableView.delegate = [self.actions forwardingTo:self];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
    [self setupNavBar];
    [self setupMembersArray];
}



@end
