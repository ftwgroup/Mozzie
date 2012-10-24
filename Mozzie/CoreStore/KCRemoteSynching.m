//
//  KCRemoteSynching.m
//  Mozzie
//
//  Created by FTWGroup on 10/23/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCRemoteSynching.h"
#import "KCConstants.h"
#import "Person.h"

@interface KCRemoteSynching ()
@property (nonatomic, strong) Person* person;
@end

@implementation KCRemoteSynching

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self requestFinished];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Object loader failed with error: %@", [error localizedDescription]);
    [self requestFinished];
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader {
    NSLog(@"Object loader got wonky results");
    [self requestFinished];
}

- (void)requestFinished {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSynchingRequestComplete object:nil];
}

#pragma mark Synch Methods

- (void)synchContactsFromMozzieServer {
    // Load the object model via RestKit        
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    RKObjectMapping *personMapping = [objectManager.mappingProvider objectMappingForClass:[Person class]];

    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:@"json" forKey:@"format"];
    NSString *resourcePath = [@"people/" stringByAppendingQueryParameters:queryParams];
    [objectManager loadObjectsAtResourcePath:resourcePath objectMapping:personMapping delegate:self];
    
//    RKObjectManager *manager = [RKObjectManager sharedManager];
//    RKObjectMapping *contactMapping = [manager.mappingProvider objectMappingForClass:[Person class]];
//    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:@"json" forKey:@"format"];
//    NSString *resourcePath = [@"/people/" stringByAppendingQueryParameters:queryParams];
//    [manager loadObjectsAtResourcePath:resourcePath objectMapping:contactMapping delegate:self.person];
    
}

@end
