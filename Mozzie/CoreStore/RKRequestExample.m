//
//  RKRequestExample.m
//  Mozzie
//
//  Created by Julian Threatt on 10/18/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "RKRequestExample.h"

@implementation RKRequestExample

- (void)sendRequests
{
    // Perform a simple HTTP GET and call me back with the results
    [[RKClient sharedClient] get:@"/people/" delegate:self];
    
    // Send a POST to a remote resource. The dictionary will be transparently
    // converted into a URL encoded representation and sent along as the request body
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"RestKit" forKey:@"Sender"];
    [[RKClient sharedClient] post:@"/other.json" params:params delegate:self];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if ([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);
        }
        
    } else if ([request isPOST]) {
        
        // Handling POST /other.json
        if ([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        
    } else if ([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if ([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}
@end



@implementation Contact

@synthesize identifier;
@synthesize fbID;
@synthesize firstName;
@synthesize lastName;
@synthesize lkdINID;
@synthesize nickName;
@synthesize onPhone;
@synthesize photo;

- (void)setupRouter {
    // Grab the reference to the router from the manager
    RKObjectRouter *router = [RKObjectManager sharedManager].router;
    
    // Define a default resource path for all unspecified HTTP verbs
    [router routeClass:[Contact class] toResourcePath:@"/contacts/:identifier"];
    [router routeClass:[Contact class] toResourcePath:@"/contacts" forMethod:RKRequestMethodPOST];
}

- (void)loadContact {
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Contact class]];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [objectMapping mapKeyPath:@"fb_id" toAttribute:@"fbID"];
    [objectMapping mapKeyPath:@"first" toAttribute:@"firstName"];
    [objectMapping mapKeyPath:@"last" toAttribute:@"lastName"];
    [objectMapping mapKeyPath:@"lkdin_id" toAttribute:@"lkdINID"];
    [objectMapping mapKeyPath:@"nick_name" toAttribute:@"nickName"];
    [objectMapping mapKeyPath:@"on_phone" toAttribute:@"onPhone"];
    [objectMapping mapKeyPath:@"photo" toAttribute:@"photo"];


    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURLString:@"http://restkit.org"];
    [manager loadObjectsAtResourcePath:@"/contacts/1" objectMapping:objectMapping delegate:self];
}

// RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    Contact *contact = [objects objectAtIndex:0];
    NSLog(@"Loaded Contact ID #%@ -> Name: %@, %@", contact.identifier, contact.lastName, contact.firstName);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Encountered an error: %@", error);
}

// RKRequestDelegate Protocol
- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    NSLog(@"Encounted an error: %@", error);
}

- (void)request:(RKRequest *)request didReceiveResponse:(RKResponse *)response
{
    NSLog(@"Response: %@",response);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if ([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved JSON: %@", [response bodyAsString]);
        }
        
    } else if ([request isPOST]) {
        
        // Handling POST /other.json
        if ([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        
    } else if ([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if ([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}

// CRUD through a router
//- (void)createObject {
//    Contact* joeBlow = [Contact new];
//    joeBlow.name = @"Joe Blow";
//    joeBlow.company = @"Two Toasters";
//    
//    // POST to /contacts
//    [ [RKObjectManager sharedManager] postObject:joeBlow delegate:self];
//}
//
//- (void)updateObject {
//    Contact* blake = [Contact object];
//    blake.identifier = [NSNumber numberWithInt:1];
//    blake.name = @"Blake Watters";
//    blake.company = @"RestKit";
//    
//    // PUT to /contacts/1
//    [ [RKObjectManager sharedManager] putObject:blake delegate:self];
//}
//
//- (void)deleteObject {
//    Contact* blake = [Contact object];
//    blake.identifier = [NSNumber numberWithInt:1];
//    
//    // DELETE to /contacts/1
//    [ [RKObjectManager sharedManager] deleteObject:blake delegate:self];
//}

//- (void)serializeObject
//{
//    // Configure a serialization mapping for our Article class. We want to send back title, body, and publicationDate
//    RKObjectMapping* articleSerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class] ];
//    [articleSerializationMapping mapAttributes:@"name", @"body", @"publicationDate", nil];
//    
//    // Now register the mapping with the provider
//    [[RKObjectManager sharedManager].mappingProvider setSerializationMapping:articleSerializationMapping forClass:[Article class] ];
//    
//    // More succintly as follows
//    // Our familiar articlesMapping from earlier
//    RKObjectMapping* articleMapping = [RKObjectMapping mappingForClass:[Article class] ];
//    [articleMapping mapKeyPath:@"title" toAttribute:@"title"];
//    [articleMapping mapKeyPath:@"body" toAttribute:@"body"];
//    [articleMapping mapKeyPath:@"author" toAttribute:@"author"];
//    [articleMapping mapKeyPath:@"publication_date" toAttribute:@"publicationDate"];
//    
//    // Build a serialization mapping by inverting our object mapping. Includes attributes and relationships
//    RKObjectMapping* articleSerializationMapping = [articleMapping inverseMapping];
//    // You can customize the mapping here as necessary -- adding/removing mappings
//    [[RKObjectManager sharedManager].mappingProvider setSerializationMapping:articleSerializationMapping forClass:[Article class] ];
//}
//
//- (void)loadArticlesWithoutKVC {
//    RKObjectMapping* articleMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[Article class] ];
//    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/articles" objectMapping:articleMapping delegate:self];
//}
//
//- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
//    RKLogInfo(@"Load collection of Articles: %@", objects);
//}

// CoreData Mapping
- (void)setupCoreDataStore
{
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:@"http://restkit.org"];
    RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"MyApp.sqlite"];
    objectManager.objectStore = objectStore;
}


@end