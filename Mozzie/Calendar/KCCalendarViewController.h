//
//  CalendarViewController.h
//  TcacTest
//
//  Created by JJ Weber on 10/1/12.
//
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "KCCalendarEventListTableView.h"

#define TOOL_BAR_HEIGHT 40
#define TOOL_BUTTON_WIDTH 40

@interface KCCalendarViewController : UIViewController <UITabBarDelegate, EKCalendarChooserDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, EKEventEditViewDelegate>
@property (nonatomic,strong) KCCalendarEventListTableView* calendarTable;
@end
