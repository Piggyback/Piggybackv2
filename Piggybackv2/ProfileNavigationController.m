//
//  YouNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ProfileNavigationController.h"

@interface ProfileNavigationController ()

@end

@implementation ProfileNavigationController

- (void)customizeNavigationBar {
    self.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"piggyback_titlebar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor blackColor], UITextAttributeTextColor,
                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                nil]];
    
    CGRect titleFrame = CGRectMake(0, 0, 320, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:titleFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Futura-Medium" size:24.0f];
    label.text = @"YOUR PROFILE";
    [self.navigationBar addSubview:label];
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
