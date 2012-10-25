//
//  KCConstants.m
//  TcacTestNative
//
//  Created by JJ Weber on 10/2/12.
//  Copyright (c) 2012 FTW. All rights reserved.
//

#import "KCConstants.h"

@implementation KCConstants
NSString* const kCalendarPermissionsNotification = @"user has set calendar permissions";
NSString* const kCoreDataStoreName = @"KCdataStore.data";
NSString* const kCalendarPermissionsBoolKey = @"permissions y/n";
NSString* const FBSessionStateChangedNotification = @"FTW-Group.Mozzie:FBSessionStateChangedNotification";
NSString* const kMozzieServerBaseURL = @"http://127.0.0.1:8000/";
NSString* const kSynchingRequestComplete = @"synching request complete";
NSString* const kUserEmail = @"the user's entered email";
NSString* const kMozzieApp = @"Mozzie App";
UIModalTransitionStyle const kAppWideModalStyle = UIModalTransitionStyleFlipHorizontal;
@end
