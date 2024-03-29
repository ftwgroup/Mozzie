//
//  DataStore.m
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCDataStore.h"
#import "Person.h"
#import "Group.h"
#import "Event.h"
#import "PhoneNumber.h"
#import "EmailAddress.h"
#import <RestKit/RestKit.h>

NSManagedObjectContext *dataContext;
NSManagedObjectModel *dataModel;

@interface KCDataStore ()
+ (NSManagedObjectContext* ) context;
+ (NSManagedObjectModel* ) model;
@end

@implementation KCDataStore

+ (NSManagedObjectContext*) context {
    if (!dataContext) {
        dataContext = [RKObjectManager sharedManager].objectStore.primaryManagedObjectContext;
    }
    
    return dataContext;
}

+ (NSArray* )fetchEntity:(NSString *)entity {
    NSFetchRequest* req = [NSFetchRequest new];
    req.entity = [[KCDataStore model].entitiesByName objectForKey:entity];
    NSError* err;
    NSArray* result = [[KCDataStore context] executeFetchRequest:req error:&err];
    if (!result) {
        [NSException raise:@"Fetch request failure!" format:@"Reason: %@", [err localizedDescription]];
    }
    return result;
}

+ (BOOL)groupHasUniqueName:(NSString* )name {
    NSFetchRequest* req = [NSFetchRequest new];
    req.entity = [[KCDataStore model].entitiesByName objectForKey:@"Group"];
    NSString *attributeName = @"name";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K MATCHES %@", attributeName, name];
    req.predicate = predicate;
    NSError* error;
    NSArray* result = [[KCDataStore context] executeFetchRequest:req error:&error];
    if (result.count == 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isInDB:(NSNumber* )ID Entity:(NSString *)entity  {
    NSFetchRequest* req = [NSFetchRequest new];
    req.entity = [[KCDataStore model].entitiesByName objectForKey:entity];
    NSString *attributeName = @"abRecordID";
    NSInteger attributeValue = [ID integerValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %i", attributeName, attributeValue];
    req.predicate = predicate;
    NSError* error;
    NSArray* result = [[KCDataStore context] executeFetchRequest:req error:&error];
    if (result.count == 0) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSManagedObjectModel *) model {
    if (!dataModel) {
        dataModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    return dataModel;
}

//TODO, implement apple recommended find or create:
//http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/CoreData/Articles/cdImporting.html
//+ (BOOL)removeDuplicatesAndSaveWithIncomingIds:(NSArray* )ids WithIDType:(NSString* )idType WithEntityType:(NSString* ) entityType {
//    NSArray* sortedIDs = [ids sortedArrayUsingSelector: @selector(compare:)];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:
//     [NSEntityDescription entityForName:entityType inManagedObjectContext:[KCDataStore context]]];
//    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(%@ IN %@)", idType, ids]];
//    [fetchRequest setSortDescriptors:
//     @[ [[NSSortDescriptor alloc] initWithKey:idType ascending:YES] ]];
//    // Execute the fetch.
//    NSError *error;
//    NSArray *objectsWithMatchingIDs = [[KCDataStore context] executeFetchRequest:fetchRequest error:&error];
//    
//    for (int i = 0; i < ids.count; i++) {
//        NSInteger incomingID = [[ids objectAtIndex:i] integerValue];
//        NSInteger matchingObjectId = [[((NSManagedObject* )[objectsWithMatchingIDs objectAtIndex:i]) valueForKey:idType] integerValue];
//        if (incomingID == matchingObjectId) {
//            continue;
//        } else {
//            
//        }
//    }
//}
+ (BOOL)saveEventWithName:(NSString *)eventName StartDate:(NSDate *)startDate EndDate:(NSDate *)endDate location:(NSString *)location status:(NSNumber *)statusSwitch people:(NSDictionary *)selectedObjects ekEventsID:(NSString *)ekEventsID {
    Event* event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[KCDataStore context]];
    event.name = eventName;
    event.startDate = startDate;
    event.endDate = endDate;
    event.location = location;
    event.status = statusSwitch;
    event.ekEventsID = ekEventsID;
    
    NSMutableSet* peopleToAdd = [NSMutableSet new];
    NSMutableArray* groupsToParse = [NSMutableArray new];

    for (NSManagedObjectID* objectID in selectedObjects) {
        NSManagedObject* personable = [[KCDataStore context] objectWithID:objectID];
        if ([personable class] == [Person class]) {
            [peopleToAdd addObject:personable];
        } else {
            [groupsToParse addObject:personable];
        }
    }
    for (Group* group in groupsToParse) {
        for (Person* person in group.manyPeople) {
            [peopleToAdd addObject:person];
        }
    }
    [event addManyPeople:peopleToAdd];
    
    NSError* error;
    [[KCDataStore context] save:&error];
    if (!error) {
        return YES;
    } else {
        return NO; 
    }
}



+ (BOOL) saveGroupWithName:(NSString *)name AndPeople:(NSArray *)people {
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:[KCDataStore context]];
    group.name = name;
    
    NSMutableSet* peopleToAdd = [NSMutableSet new];
    NSMutableArray* groupsToParse = [NSMutableArray new];
    
    for (NSManagedObject* personable in people) {
        if ([personable class] == [Person class]) {
            [peopleToAdd addObject:personable];
        } else {
            [groupsToParse addObject:personable];
        }
    }
    for (Group* group in groupsToParse) {
        for (Person* person in group.manyPeople) {
            [peopleToAdd addObject:person];
        }
    }
    [group addManyPeople:peopleToAdd];
    
    NSError* error;
    [[KCDataStore context] save:&error];
    if (!error) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)save {
    NSError *err;
    if (![[KCDataStore context] save:&err]) {
        [NSException raise:@"Save Failed!!" format:@"Reason: %@", [err localizedDescription]];
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)saveEntityFromPersonRecordRef:(ABRecordRef)person {
    //names (need more to cover all potential names in AB
    Person *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                    inManagedObjectContext:[KCDataStore context]];
    NSNumber* ID = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
    if ([self isInDB:ID Entity:@"Person"]) {
        //done
        return true;
    }
    
    contact.abRecordID = ID;
    contact.firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    contact.lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    contact.nickName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonNicknameProperty));
    contact.title = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonJobTitleProperty));
    ABMultiValueRef phoneRefs = ABRecordCopyValue(person, kABPersonPhoneProperty);
    //phone numbers 
    for (int p = 0; p < ABMultiValueGetCount(phoneRefs); p++) {
        PhoneNumber *digits = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber"
                                                        inManagedObjectContext:[KCDataStore context]];
        digits.number = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneRefs, p));
        digits.label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phoneRefs, p));
        //linked to person
        digits.person = contact;
    }
    //emails
    ABMultiValueRef emailRefs = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int e = 0; e < ABMultiValueGetCount(emailRefs); e++)
    {
        EmailAddress *email = [NSEntityDescription insertNewObjectForEntityForName:@"EmailAddress"
                                                            inManagedObjectContext:[KCDataStore context]];
        email.address = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(emailRefs, e));
        email.person = contact;
    }
    //social media
   ABMultiValueRef socialMediaMulti = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
   for(CFIndex i = 0; i < ABMultiValueGetCount(socialMediaMulti); i++) {
       CFDictionaryRef socialService = ABMultiValueCopyValueAtIndex(socialMediaMulti, i);
       NSDictionary* socialServiceDict =(__bridge NSDictionary *) socialService;
       if ([[socialServiceDict objectForKey:(NSString*)kABPersonSocialProfileServiceKey] isEqualToString:(NSString*)kABPersonSocialProfileServiceTwitter]) {
           contact.twitterHandle = [socialServiceDict objectForKey:(NSString*)kABPersonSocialProfileUsernameKey];
       }
       if ([[socialServiceDict objectForKey:(NSString*)kABPersonSocialProfileServiceKey] isEqualToString:(NSString*)kABPersonSocialProfileServiceFacebook]) {
           contact.facebookID = [socialServiceDict objectForKey:(NSString*)kABPersonSocialProfileUserIdentifierKey];
       }
   }
    
    return [self save];
}

+ (NSArray* )userTwitterHandle {
    NSFetchRequest* req = [NSFetchRequest new];
    req.entity = [[KCDataStore model].entitiesByName objectForKey:@"Person"];
    req.propertiesToFetch = @[@"twitterHandle"];
    NSError* err;
    NSArray* result = [[KCDataStore context] executeFetchRequest:req error:&err];
        if (!result) {
            [NSException raise:@"user Twitter Hande Fetch Failure" format:@"Reason: %@", [err localizedDescription]];
        }
    return result;
}


@end
