//
//  RKRequestExample.h
//  Mozzie
//
//  Created by Julian Threatt on 10/18/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface RKRequestExample : NSObject <RKRequestDelegate>
- (void)setupCoreDataStore;
@end

@interface Contact : NSObject <RKObjectLoaderDelegate,RKRequestDelegate>

@property (nonatomic, retain) NSString*identifier;
@property (nonatomic, retain) NSString *fbID;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *lkdINID;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, assign) BOOL onPhone;
@property (nonatomic, retain) NSString *photo;

@end