//
//  MozzieRestKitTests.m
//  MozzieRestKitTests
//
//  Created by FTWGroup on 10/22/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "MozzieRestKitTests.h"
#import "KCConstants.h"
#import "KCRKInit.h"
#import "KCRemoteSynching.h"
#import "Person.h"
#import "KCDataStore.h"
#import <RestKit/Testing.h>

@interface MozzieRestKitTests ()

@end

@implementation MozzieRestKitTests

//initializing RestKit
- (void)setUp
{
    [super setUp];
    [KCRKInit setupRK];
    
    STAssertNotNil([RKObjectManager sharedManager], @"Could not create shared object manager");
    STAssertNotNil([RKObjectManager sharedManager].objectStore, @"Could not create test db context");

    STAssertNoThrow([KCDataStore context], @"Core Data conflicts with RestKit");
    
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testKCRKInit
{
    [self setUp];
    [self tearDown];
}

//Loading objects into core data
- (void)setUpRMSynch {
    [super setUp];
    KCRemoteSynching* synchHandler = [[KCRemoteSynching alloc] init];
    [synchHandler synchContactsFromMozzieServer];
}

- (void)tearDownRMSynch {
    [super tearDown];
}



- (void)testKCRemoteSynching {
    [self setUpRMSynch];
    [self tearDownRMSynch];
}



@end
