//
//  FTWMAppDelegate.h
//  Mozzie
//
//  Created by Julian Threatt on 9/25/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FBSessionStateChangedNotification;

@interface FTWMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// The app delegate is responsible for maintaining the current FBSession. the application
// requires the user to be logged in to Facebook in order to do anything interesting -- if
// there is no valid FBSession, a login screen is displayed.
-(BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
@end
