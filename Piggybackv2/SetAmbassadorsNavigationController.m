//
//  SetAmbassadorsNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SetAmbassadorsNavigationController.h"

@interface SetAmbassadorsNavigationController ()

@end

@implementation SetAmbassadorsNavigationController

- (void)customizeNavigationBar {
    self.navigationBar.tintColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"piggyback_titlebar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor blackColor], UITextAttributeTextColor,
                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                nil]];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    [self customizeNavigationBar];
    return [super initWithRootViewController:rootViewController];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self customizeNavigationBar];
}

@end
