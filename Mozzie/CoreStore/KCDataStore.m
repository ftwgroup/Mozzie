//
//  DataStore.m
//  Mozzie
//
//  Created by JJ Weber on 10/11/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCDataStore.h"

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

+ (void)save {
    NSError *err;
    if (![[KCDataStore context] save:&err]) {
        [NSException raise:@"Save Failed!!" format:@"Reason: %@", [err localizedDescription]];
    }
}


@end
