//
//  ListenNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ListenNavigationController.h"
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>

@interface ListenNavigationController ()

@end

@implementation ListenNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"listen-view-titlebar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navigationBar.layer.shadowRadius = 3.0f;
    self.navigationBar.layer.shadowOpacity = 1.0f; 
    return [super initWithRootViewController:rootViewController];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"listen-view-titlebar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.navigationBar.layer.shadowRadius = 3.0f;
    self.navigationBar.layer.shadowOpacity = 1.0f; 
}

@end
