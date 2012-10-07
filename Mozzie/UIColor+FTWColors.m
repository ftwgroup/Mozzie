//
//  UIColor+UIColo_FTWColors.m
//  Mozzie
//
//  Created by Julian Threatt on 10/4/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "UIColor+FTWColors.h"

@implementation UIColor (FTWColors)

+ (UIColor *)headerColor {
    return [UIColor colorWithRed:0.957 green:0.498 blue:0.298 alpha:1.0];
}
+ (UIColor *)backgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}
@end
