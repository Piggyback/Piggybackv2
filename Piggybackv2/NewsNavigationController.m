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
    CGRect titleFrame = CGRectMake(0, 0, 320, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:titleFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Futura-Medium" size:24.0f];
    label.text = @"NEWS";
    [self.navigationBar addSubview:label];
    
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
