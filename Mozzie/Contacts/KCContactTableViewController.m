//
//  ContactsViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCContactTableViewController.h"
#import "KCFaceView.h"
#import "UIColor+FTWColors.h"
#import "RKRequestExample.h"

#import <MessageUI/MessageUI.h>


@interface DetailView : UITableViewController
@property (nonatomic, readwrite, retain) NITableViewModel *model;
@property (nonatomic, readwrite, retain) NITableViewActions *actions;
- (id)initWithUpdate:(NSMutableDictionary*)updateDict;
@end

@implementation DetailView

@synthesize model = _model;
@synthesize actions = _actions;


- (id)initWithUpdate:(NSMutableDictionary*)updateDict
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = @"Mozzie";
        NSLog(@"update: %@",updateDict);
        _actions = [[NITableViewActions alloc] initWithController:self];

        NSArray *sectionedObjects =
        [NSArray arrayWithObjects:

         @"Contacts",
         [NISubtitleCellObject objectWithTitle:@"Row 3" subtitle:@"Subtitle"],
         
         nil];

        _model = [[NITableViewModel alloc] initWithSectionedArray:sectionedObjects
                                                         delegate:(id)[NICellFactory class]];
    }
    return self;
}
-(void)testRequest
{
    Contact *contact = [[Contact alloc] init];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.client.baseURL = [RKURL URLWithString:@"http://localhost:8000"];
    RKObjectMapping *contactMapping = [manager.mappingProvider objectMappingForClass:[Contact class]];
    
//    RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[Contact class]];
    [contactMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [contactMapping mapKeyPath:@"fb_id" toAttribute:@"fbID"];
    [contactMapping mapKeyPath:@"first" toAttribute:@"firstName"];
    [contactMapping mapKeyPath:@"last" toAttribute:@"lastName"];
    [contactMapping mapKeyPath:@"lkdin_id" toAttribute:@"lkdINID"];
    [contactMapping mapKeyPath:@"nick_name" toAttribute:@"nickName"];
    [contactMapping mapKeyPath:@"on_phone" toAttribute:@"onPhone"];
    [contactMapping mapKeyPath:@"photo" toAttribute:@"photo"];
    
    [manager loadObjectsAtResourcePath:@"/people"  objectMapping:contactMapping delegate:contact];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self testRequest];
    self.tableView.dataSource = self.model;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
    self.tableView.delegate = [self.actions forwardingTo:self];
}

@end

@interface KCContactTableViewController ()

@property (nonatomic, readwrite, retain) NITableViewModel *model;
@property (nonatomic, readwrite, retain) NITableViewActions *actions;
- (NITableViewActionBlock)detailAction:(NSMutableDictionary*)updateDict;
- (NITableViewActionBlock)callAction:(NSString*)phoneNumber;
- (NITableViewActionBlock)emailAction:(NSString*)email;

- (void)setupTableHeaderView;

@end

@implementation KCContactTableViewController

@synthesize model = _model;
@synthesize updates = _updates;
@synthesize actions = _actions;


- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    NSLog(@"tap");
    // In a later example we will show how to push a Nimbus web controller onto the navigation stack
    // rather than punt the user out of the application to Safari.
    [[UIApplication sharedApplication] openURL:result.URL];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = @"Contact Name";

        
        _actions = [[NITableViewActions alloc] initWithController:self];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupWho];

    self.tableView.dataSource = self.model;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
    self.tableView.delegate = [self.actions forwardingTo:self];
    [self setupTableHeaderView];

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NIIsSupportedOrientation(toInterfaceOrientation);
}



#pragma mark Person Info
- (void)setupWho {
        
    NSString* phone = nil;
    NSString* email = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(self.person,
                                                     kABPersonPhoneProperty);
    ABMultiValueRef emailAddresses = ABRecordCopyValue(self.person, kABPersonEmailProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    
    if (ABMultiValueGetCount(emailAddresses) > 0) {
        email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailAddresses, 0);
    }
    //self.phoneNumber.text = phone;
    
    NSArray *tableContents = [NSArray arrayWithObject:@"Contact"];
    if (phone) {
        tableContents = [tableContents arrayByAddingObject:[_actions attachNavigationAction:[self callAction:phone] toObject:[NISubtitleCellObject objectWithTitle:@"Mobile Number" subtitle:phone]]];
    }
    if (email) {
        tableContents = [tableContents arrayByAddingObject:[_actions attachNavigationAction:[self emailAction:email] toObject:[NISubtitleCellObject objectWithTitle:@"Email" subtitle:email]]];
    }
    tableContents = [tableContents arrayByAddingObject:@"Updates"];
    for (NSMutableDictionary *update in self.updates) {
        //NSLog(@"result: %@", update);
        NSString *title = [update objectForKey:@"story"];
        if (title) {
            tableContents = [tableContents arrayByAddingObject:[_actions attachNavigationAction:[self detailAction:update] toObject:[NITitleCellObject objectWithTitle:title]]];
        } else {
            title = [update objectForKey:@"message"];
            tableContents = [tableContents arrayByAddingObject:[_actions attachNavigationAction:[self detailAction:update] toObject:[NITitleCellObject objectWithTitle:title]]];
        }

    }
    self.model = [[NITableViewModel alloc] initWithSectionedArray:tableContents delegate:(id)[NICellFactory class]];
    
    self.tableView.dataSource = self.model;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor backgroundColor];
    [self setupTableHeaderView];
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed - Unknown Error :-("
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
# pragma mark - Methods for rendering the user profile
- (void) setupTableHeaderView
{
    KCFaceView *faceView = [[KCFaceView alloc] initWithNibName:nil bundle:nil];
    faceView.view.backgroundColor = [UIColor backgroundColor];
    if (ABRecordGetRecordType(self.person) == kABPersonType) {
        UIImage *image = [UIImage imageWithData:(__bridge NSData *)(ABPersonCopyImageData(self.person))];
        [faceView addContactImage:image];
        CFStringRef name = ABRecordCopyCompositeName(self.person);
        [faceView addContactName:(__bridge NSString *)(name)];
    }
    self.tableView.tableHeaderView = faceView.view;
}

# pragma mark - Action Blocks
- (NITableViewActionBlock)detailAction:(NSMutableDictionary *)updateDict
{
    return [^(id object, UIViewController* controller) {
        // You must initialize the actions object with initWithController: and pass a valid
        // controller.
        NIDASSERT(nil != controller);
        
        if (nil != controller) {
            DetailView* controllerToPush = [[DetailView alloc] initWithUpdate:updateDict];
            [controller.navigationController pushViewController:controllerToPush
                                                       animated:YES];
        }
        
        return NO;
    } copy];
}

- (NITableViewActionBlock)emailAction:(NSString *)email
{
    return [^(id object, UIViewController* controller) {

        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = controller;
        
        [picker setSubject:@"test subject"];
        
        NSString *emailBody = @"test body";
        [picker setMessageBody:emailBody isHTML:YES];
        
        picker.navigationBar.barStyle = UIBarStyleBlack;
        
        NIDASSERT(nil != controller);
        
        if (nil != controller) {
            [controller presentModalViewController:picker animated:YES];
        }
        
        return YES;
    } copy];
}

- (NITableViewActionBlock)callAction:(NSString *)phoneNumber
{
    return [^(id object, UIViewController* controller) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://4043131546"]];
        return YES;
    } copy];
}
@end


