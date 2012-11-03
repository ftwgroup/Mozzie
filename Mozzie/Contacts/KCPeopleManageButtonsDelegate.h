//
//  KCPeopleManageButtonsDelegate.h
//  Mozzie
//
//  Created by JJ Weber on 11/2/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KCPeopleManageButtonsDelegate <NSObject>
- (void)animateInCreateGroupButton;
- (void)animateInRemoveButton;
- (void)animateOutRemoveButton;
@end
