//
//  WatchNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "WatchNavigationController.h"

@interface WatchNavigationController ()

@end

@implementation WatchNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"watch-view-titlebar"] forBarMetrics:UIBarMetricsDefault];
    return [super initWithRootViewController:rootViewController];
    
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"watch-view-titlebar"] forBarMetrics:UIBarMetricsDefault];
}

@end
