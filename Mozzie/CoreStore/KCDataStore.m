//
//  DataStore.m
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCDataStore.h"
#import "Person.h"
#import "PhoneNumbers.h"
#import "EmailAddresses.h"

NSManagedObjectContext *dataContext;
NSManagedObjectModel *dataModel;

@interface KCDataStore ()
+ (NSManagedObjectContext* ) context;
+ (NSManagedObjectModel* ) model;
@end

@implementation KCDataStore

+ (NSManagedObjectContext*) context {
    if (!dataContext) {
        NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        NSString* documentDirectory = [documentDirectories objectAtIndex:0];
        
        NSURL* storeURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingString:@"KCdataStore.data"]];
        
        NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[KCDataStore model]];
        
        NSError* err;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&err]) {
            [NSException raise:@"Open failed!"
                        format:@"Reason: %@", [err localizedDescription]];
        } else {
            dataContext = [NSManagedObjectContext new];
            [dataContext setPersistentStoreCoordinator:psc];
            
            // ???
            [dataContext setUndoManager:nil];
        }
    }
    
    return dataContext;
}


+ (NSManagedObjectModel *) model {
    if (!dataModel) {
        dataModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
    return dataModel;
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

+ (NSArray* )fetchPeople {
    NSFetchRequest* req = [NSFetchRequest new];
    req.entity = [[KCDataStore model].entitiesByName objectForKey:@"Person"];
    NSError* err;
    NSArray* result = [[KCDataStore context] executeFetchRequest:req error:&err];
    if (!result) {
        [NSException raise:@"Fetch people request failure!" format:@"Reason: %@", [err localizedDescription]];
    }
    return result;
}

+ (BOOL)isInDB:(NSInteger) ID Entity:(NSString *)entity  {
    NSFetchRequest* req = [NSFetchRequest new];
    req.entity = [[KCDataStore model].entitiesByName objectForKey:entity];
    NSString *attributeName = @"abRecordID";
    NSInteger attributeValue = ID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %i", attributeName, attributeValue];
    req.predicate = predicate;
    NSError* error;
    NSArray* result = [[KCDataStore context] executeFetchRequest:req error:&error];
    if (result.count == 0) {
        return false;
    } else {
        return true;
    }
}

+ (BOOL)saveEntityFromPersonRecordRef:(ABRecordRef)person {
    //names (need more to cover all potential names in AB
    Person *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                    inManagedObjectContext:[KCDataStore context]];
    NSInteger ID = ABRecordGetRecordID(person);
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
        PhoneNumbers *digits = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber"
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
        EmailAddresses *email = [NSEntityDescription insertNewObjectForEntityForName:@"EmailAddress"
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
