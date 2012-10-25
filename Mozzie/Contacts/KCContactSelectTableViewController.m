//
//  KCContactSelectTableViewController.m
//  Mozzie
//
//  Created by JJ Weber on 10/17/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCContactSelectTableViewController.h"
#import "KCDataStore.h"
#import "Person.h"

@interface KCContactSelectTableViewController ()
@property (nonatomic, strong) NITableViewModel* model;;
@property (nonatomic, readwrite, retain) NITableViewActions *actions;
@end

@implementation KCContactSelectTableViewController
@synthesize model = _model;

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
    NSMutableArray* nameArr = [[NSMutableArray alloc] init];
    for (Person *contact in [KCDataStore fetchPeople]) {
        if (contact.firstName) {
            NSString* fullName = [[contact.firstName stringByAppendingString:@" "] stringByAppendingString:contact.lastName];
            [nameArr addObject:[NISubtitleCellObject objectWithTitle:fullName subtitle:contact.nickName]];
        }
    }
    _model = [[NITableViewModel alloc] initWithListArray:nameArr delegate:(id)[NICellFactory class]];
    self.tableView.dataSource = _model;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NIIsSupportedOrientation(toInterfaceOrientation);
}

#pragma mark - Table view delegate


@end
