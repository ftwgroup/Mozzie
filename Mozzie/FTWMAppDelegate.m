 //
//  FTWMAppDelegate.m
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "FTWMAppDelegate.h"
#import "KCCalendarStore.h"

#import "FTWMViewController.h"
#import "FTWMLoginViewController.h"
#import "UIColor+FTWColors.h"

NSString *const FBSessionStateChangedNotification = @"FTW-Group.Mozzie:FBSessionStateChangedNotification";

@interface FTWMAppDelegate ()

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) FTWMViewController *mainViewController;
@property (strong, nonatomic) FTWMLoginViewController *loginViewController;

-(void)showLoginView;
-(void)createAndPresentLoginView;
-(void)sessionStateChanged:(FBSession*)session state:(FBSessionState)state error:(NSError*)error;

@end

@implementation FTWMAppDelegate

@synthesize window = _window;
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;
@synthesize loginViewController = _loginViewController;

#pragma mark Facebook Login Code

-(void)showLoginView
{
    if (self.loginViewController == nil) {
        [self createAndPresentLoginView];
    } else {
        [self.loginViewController loginFailed];
    }
}

-(void)createAndPresentLoginView
{
    if (self.loginViewController == nil) {
        self.loginViewController = [[FTWMLoginViewController alloc] initWithNibName:@"FTWMLoginViewController" bundle:nil];
        UIViewController *topViewController = [self.navController topViewController];
        [topViewController presentModalViewController:self.loginViewController animated:NO];
    }
}

-(BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    return [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        [self sessionStateChanged:session state:state error:error];
    }];
}

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    // Any time the session is closed, we want ot display the login controller.
    // When the session is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            // do something interesting
            if (self.loginViewController != nil) {
                UIViewController *topViewController = [self.navController topViewController];
                [topViewController dismissModalViewControllerAnimated:YES];
                self.loginViewController = nil;
            }
            // Pre-fetch and cache the friends for the friend picker as asoon as possible to imptove responsiveness
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            // Once the user has loged out, we want them to be looking at the root view.
            UIViewController *topViewController = [self.navController topViewController];
            // At this point this should be the loginViewcontroller
            UIViewController *modalViewController = [topViewController modalViewController];
            if (modalViewController != nil) {
                [topViewController dismissModalViewControllerAnimated:NO];
            }
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            // if the token goes invalid we want to switch right back to
            // the login view, however we do it with a slight delay in order
            // to account for a race condition between this and the login view disappearing
            // a moment before.
            [self performSelector:@selector(showLoginView)
                       withObject:nil
                       afterDelay:0.5f];
            }
            break;
            
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // BUG WORKAROUND:
    // Nib files require the type to have been loaded before they can do the
    // wireup successfully.
    // http://stackoverflow.com/questions/1725881/unknown-class-myclass-in-interface-builder-file-error-at-runtime
    [FBProfilePictureView class];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor backgroundColor];
    // Out main view controller for now it is just a table view
    self.mainViewController = [[FTWMViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.navController.navigationBar.tintColor = [UIColor headerColor];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    // Ask for calendar permissions
    [[KCCalendarStore sharedStore].EKEvents requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        NSLog(@"Permission granted: %s", granted ? "true" : "false");
    }];
    // Ask for contacts permissions
    
    
    // See if we have a valid token for the current state.
    if (![self openSessionWithAllowLoginUI:YES]) {
        [self showLoginView];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the application with regards to SSO
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [FBSession.activeSession close];
}

@end
