//
//  FTWMViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "FTWMHomeViewController.h"
#import "UIColor+FTWColors.h"

#import "KCCalendarViewController.h"
#import "KCProfileTableViewController.h"
#import "KCContactsViewController.h"

#import "NimbusModels.h"

@interface FTWMHomeViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel *model;
@property (nonatomic, readwrite, retain) NITableViewActions *actions;

@end

@implementation FTWMHomeViewController

-(id)initWithStyle:(UITableViewStyle)style {
    // We explicitly set the table view style in this controller's implementation because we want this
    // controller to control how the table view is displayed
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        // Set the title here because we never change it
        self.title = @"Mozzie";
        
        // When we instantiate the actions object we must provide it with a weak reference to the parent
        // controller. This value is passed to the action blocks so that we can easily navigate to new
        // controllers without introducing retain cycles by otherwise having to access self in the block
        _actions = [[NITableViewActions alloc] initWithController:self];
        
        // This controller uses the Nimbus table view model. In loose terms, Nimbus models implement
        // data source protocols. They encapsulate standard delegate functionality and will make your
        // life a lot easier. In this particular case we're using NITableViewModel with a sectioned
        // array of objects.
        NSArray *sectionedObjects =
        [NSArray arrayWithObjects:
         // An NSString in a sectioned array denotes the start of a new section. It's also the label of the
         // section header.
         @"Contacts",
         
         // Any objects following an NSString will be a part of the same group until another NSSTring is encountered
         
         // We attach actions to objects using the chaining pattern. The "attach" methods of
         // NITableViewActions will return the object we pass to them, allowing us to create an object,
         // attach an action to it, and then add the object to the sectioned array in one statement.
         [_actions attachNavigationAction:
          
          // NIPushControllerAction is a helper method that instantiates the controller class and then
          // pushes it onto the current view controller's navigation stack.
          NIPushControllerAction([KCContactsViewController class])
            toObject:[NISubtitleCellObject objectWithTitle:@"Contacts"
                                                  subtitle:@"Your friend's Profiles"]],
         @"Profile",
         [_actions attachNavigationAction:NIPushControllerAction([KCProfileTableViewController class])
                                 toObject:[NISubtitleCellObject objectWithTitle:@"Profile"
                                                                       subtitle:@"Your profile."]],
         @"Calendars",
         [_actions attachNavigationAction:NIPushControllerAction([KCCalendarViewController class])
                                 toObject:[NISubtitleCellObject objectWithTitle:@"Calendars"
                                                                       subtitle:@"See only what you have planned."]],
         
         nil];
        
        // When we create the model we must provide it with a delegate that implements the
        // NITableViewModelDelegate protocol. This protocol has a single method that is used to create
        // cells given an object from the model. If we don't require any custom cell bindings then it's
        // often easiest to use the NICellFactory as the delegate. The NICellFactory class provides a
        // barebones implementation that is sufficient for nearly all applications.
        _model = [[NITableViewModel alloc] initWithSectionedArray:sectionedObjects
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
    self.tableView.delegate = [self.actions forwardingTo:self];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    //annoying bug where if interface orientation is landscape on init the screen is frozen, rotating the screen will fix it
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}


@end
