//
//  KCRKInit.m
//  Mozzie
//
//  Created by FTWGroup on 10/22/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCRKInit.h"
#import "PhoneNumber.h"
#import "Person.h"
#import "KCConstants.h"
#import "KCDataStore.h"
#import <RestKit/RestKit.h>

@implementation KCRKInit
+ (void) setupRK {
    
    // RestKist client
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURLString:kMozzieServerBaseURL];
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
    //Setup Numbers Mapping
//    RKManagedObjectMapping* numbersMapping = [RKManagedObjectMapping mappingForClass:[PhoneNumber class]
//                                                                inManagedObjectStore:objectStore];
//    [numbersMapping mapKeyPath:@"number" toAttribute:@"number"];
//    
//    [objectManager.mappingProvider addObjectMapping:numbersMapping];

    // Setup Person Mappping
    RKManagedObjectMapping *personMapping = [RKManagedObjectMapping mappingForClass:[Person class]
                                                               inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    personMapping.primaryKeyAttribute = @"app_id";
    [personMapping mapKeyPath:@"app_id" toAttribute:@"mozzieIdentifier"];
    [personMapping mapKeyPath:@"fb_id" toAttribute:@"facebookID"];
    [personMapping mapKeyPath:@"first" toAttribute:@"firstName"];
    [personMapping mapKeyPath:@"last" toAttribute:@"lastName"];
    [personMapping mapKeyPath:@"lkdin_id" toAttribute:@"linkedinID"];
    [personMapping mapKeyPath:@"nick_name" toAttribute:@"nickName"];
    [personMapping mapKeyPath:@"on_phone" toAttribute:@"onPhone"];
    [personMapping mapKeyPath:@"photo" toAttribute:@"photoData"];
    [personMapping mapKeyPath:@"numbers" toAttribute:@"phoneNumbers"];
    
    [[RKObjectManager sharedManager].mappingProvider addObjectMapping:personMapping];
    
    // Register our mappings with the provider using a resource path pattern
    RKObjectRouter *router = [RKObjectManager sharedManager].router;
    
    // Define a default resource path
    [router routeClass:[Person class] toResourcePath:@"/people/:identifier" forMethod:RKRequestMethodGET];
    [router routeClass:[Person class] toResourcePath:@"/people" forMethod:RKRequestMethodPOST];
}
@end
