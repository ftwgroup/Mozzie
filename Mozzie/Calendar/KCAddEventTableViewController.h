//
//  KCAddEventViewController.h
//  Mozzie
//
//  Created by JJ Weber on 10/16/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCore.h"
#import "NimbusModels.h"
#import <EventKit/EventKit.h>

#define TOOL_BAR_HEIGHT 40

@interface KCAddEventTableViewController : UITableViewController <UITextFieldDelegate, NIMutableTableViewModelDelegate>
@property (strong, nonatomic) EKEventStore* eventStore;
-(id)initWithEvent:(EKEvent*)event;
@end
