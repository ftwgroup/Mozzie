//
//  KCRemoteSynching.h
//  Mozzie
//
//  Created by FTWGroup on 10/23/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface KCRemoteSynching : NSObject <RKObjectLoaderDelegate>
- (void)synchContactsFromMozzieServer;
- (void)requestFinished;
@end
