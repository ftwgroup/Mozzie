//
//  KCRKInit.m
//  Mozzie
//
//  Created by FTWGroup on 10/22/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCRKInit.h"
#import "Person.h"
#import "KCConstants.h"
#import "KCDataStore.h"
#import <RestKit/RestKit.h>

@implementation KCRKInit
+ (void) setupRK {
    /* first initialize the base class */
    // RestKist client
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURLString:kMozzieServeBaseURL];
    [RKObjectManager setSharedManager:objectManager];
    
    // Store Manager    
    RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:kCoreDataStoreName
                                                                               inDirectory:nil
                                                                     usingSeedDatabaseName:nil
                                                                        managedObjectModel:[KCDataStore model]
                                                                                  delegate:self];
    [RKObjectManager sharedManager].objectStore = objectStore;
    
    // Enable automatic network activity indicator
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    
    // Setup Person Mappping
    //RKManagedObjectMapping *personMapping = [RKManagedObjectMapping mappingForClass:[Person class] inManagedObjectStore:objectStore];
    
//    // Setup our Contact Mapping
//    RKObjectMapping *contactMapping = [RKObjectMapping mappingForClass:[Contact class]];
//    //[contactMapping mapKeyPath:@"id" toAttribute:@"identifier"];
//    [contactMapping mapKeyPath:@"fb_id" toAttribute:@"fbID"];
//    [contactMapping mapKeyPath:@"first" toAttribute:@"firstName"];
//    [contactMapping mapKeyPath:@"last" toAttribute:@"lastName"];
//    [contactMapping mapKeyPath:@"lkdin_id" toAttribute:@"lkdINID"];
//    [contactMapping mapKeyPath:@"nick_name" toAttribute:@"nickName"];
//    [contactMapping mapKeyPath:@"on_phone" toAttribute:@"onPhone"];
//    [contactMapping mapKeyPath:@"photo" toAttribute:@"photo"];
    
//    [objectManager.mappingProvider addObjectMapping:contactMapping];
    
    // Register our mappings with the provider using a resource path pattern
    //RKObjectRouter *router = [RKObjectManager sharedManager].router;
    
    // Define a default resource path
    //[router routeClass:[Contact class] toResourcePath:@"/people/:identifier"];
    //[router routeClass:[Contact class] toResourcePath:@"/people" forMethod:RKRequestMethodPOST];
}
@end
