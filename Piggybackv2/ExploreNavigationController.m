//
//  ExploreNavigationController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ExploreNavigationController.h"

@interface ExploreNavigationController ()

@end

@implementation ExploreNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"explore-view-titlebar"] forBarMetrics:UIBarMetricsDefault];
    return [super initWithRootViewController:rootViewController];
    
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"explore-view-titlebar"] forBarMetrics:UIBarMetricsDefault];
}

@end
