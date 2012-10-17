//
//  FaceViewController.h
//  Mozzie
//
//  Created by Julian Threatt on 10/7/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NimbusNetworkImage.h"

//#import <QuartzCore/QuartzCore.h>

@interface KCFaceView : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *contactName;
@property (strong, nonatomic) IBOutlet UIImageView *contactImage;
- (void)setupDisplay;
-(void)addContactImage:(UIImage *)image;
-(void)addContactName:(NSString *)name;

@end
