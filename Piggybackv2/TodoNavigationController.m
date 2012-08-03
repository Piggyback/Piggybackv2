//
//  TodoNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "TodoNavigationController.h"

@interface TodoNavigationController ()

@end

@implementation TodoNavigationController

- (void)customizeNavigationBar {
    [self.navigationBar setTintColor:[UIColor colorWithRed:1.0f green:0.91f blue:0.50f alpha:0]];
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
