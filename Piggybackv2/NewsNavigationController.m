//
//  NewsNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/2/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "NewsNavigationController.h"

@interface NewsNavigationController ()

@end

@implementation NewsNavigationController

- (void)customizeNavigationBar {
    self.navigationBar.tintColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"piggyback_titlebar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor blackColor], UITextAttributeTextColor,
                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                nil]];
    
//    CGRect titleFrame = CGRectMake(0, 0, 320, 44);
//    UILabel *label = [[UILabel alloc] initWithFrame:titleFrame];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = UITextAlignmentCenter;
//    label.font = [UIFont fontWithName:@"Futura-Medium" size:24.0f];
//    label.text = @"YOUR NEWS";
//    [self.navigationBar addSubview:label];
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
