//
//  MozzieRestKitTests.m
//  MozzieRestKitTests
//
//  Created by FTWGroup on 10/22/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "MozzieRestKitTests.h"
#import "RKRequestExample.h"
#import "KCRKInit.h"

@implementation MozzieRestKitTests

- (void)setUp
{
    [super setUp];
    KCRKInit* initConvenience = [[KCRKInit alloc] init];
    
    STAssertNotNil([RKObjectManager sharedManager], @"Could not create shared object manager");
    STAssertNotNil([RKObjectManager sharedManager].objectStore, @"Could not create test");
    
    // Set-up code here.
    
    initConvenience = nil;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testKCRKInit
{
    [self setUp];
    STFail(@"Fail!");
    [self tearDown];
}

@end
