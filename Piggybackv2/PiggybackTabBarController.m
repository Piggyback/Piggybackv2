//
//  PiggybackTabBarController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackTabBarController.h"
#import "YouTubeTableViewController.h"
#import "AppDelegate.h"
#import "AccountLinkViewController.h"

@interface PiggybackTabBarController ()

@end

@implementation PiggybackTabBarController

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get videos from youtube ambassadors
    NSMutableSet *youtubeAmbassadors = [NSMutableSet setWithObjects:@"nerdsinnewyork",@"mlgao",nil];
    YouTubeTableViewController* youtubeVC = (YouTubeTableViewController*)[[self.viewControllers objectAtIndex:2] topViewController];
    [youtubeVC getFavoritesFromAmbassadors:youtubeAmbassadors];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    NSLog(@"tab bar controller dealloc");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
