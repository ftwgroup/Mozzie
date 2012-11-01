//
//  KCConstants.h
//  TcacTestNative
//
//  Created by JJ Weber on 10/2/12.
//  Copyright (c) 2012 FTW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCConstants : NSObject

typedef enum  {
    kPersonTag,
    kGroupTag
} contactTab;

extern NSString* const kCalendarPermissionsNotification;
extern NSString* const kCalendarPermissionsBoolKey;
extern NSString* const kCoreDataStoreName;
extern NSString* const FBSessionStateChangedNotification;
extern NSString* const kMozzieServerBaseURL;
extern NSString* const kSynchingRequestComplete;
extern NSString* const kUserEmail;
extern NSString* const kUserSelectedCalendarIndentifiers;
extern NSString* const kServiceMozzieApp;
extern UIModalTransitionStyle const kAppWideModalStyle;
@end
