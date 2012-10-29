//
//  KCNewGroupTableViewController.h
//  Mozzie
//
//  Created by FTWGroup on 10/29/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCore.h"
#import "NimbusModels.h"

@interface KCNewGroupTableViewController : UITableViewController <NIMutableTableViewModelDelegate, UITextFieldDelegate>
@property NSMutableDictionary* selectedObjects;
@end
