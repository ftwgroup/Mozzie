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

@interface KCAddEventTableViewController : UITableViewController <UITextFieldDelegate, NIMutableTableViewModelDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) EKEventStore* eventStore;
-(id)initWithEvent:(EKEvent*)event;
//keep track of the people added selection controller
@property (strong, nonatomic) NSMutableDictionary* selectedObjects;
- (void)displaySelectedPeople;
@end
