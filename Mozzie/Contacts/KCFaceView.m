//
//  FaceViewController.m
//  Mozzie
//
//  Created by Julian Threatt on 10/7/12.
//  Copyright (c) 2012 Julian Threatt. All rights reserved.
//

#import "KCFaceView.h"

@interface KCFaceView ()
@end

@implementation KCFaceView

@synthesize contactImage = _contactImage;
@synthesize contactName = _contactName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"KCFaceView" bundle:nil];
    if (self) {
        CGRect headerFrame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
        [self.view setFrame:headerFrame];    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

# pragma mark - Special rendering methods
- (void)addContactImage:(UIImage *)image
{
    self.contactImage.image = image;
}

- (void)addContactName:(NSString *)name
{
    self.contactName.text = name;
}

@end
