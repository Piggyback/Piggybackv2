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
#import "LoginViewController.h"

@interface PiggybackTabBarController ()

@end

@implementation PiggybackTabBarController

#pragma mark -- FBSessionDelegate methods
- (void)fbDidLogin {
    Facebook *facebook = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:NO completion:nil]; // dismisses loginViewController
    NSLog(@"logged in");
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not log in");
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidLogout {
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController:loginViewController animated:NO completion:nil];
    
    // release existing view controllers and create new instances for next user who logs in
    UIViewController* compatibilityNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"compatibilityNavigationController"];
    UIViewController* statusUpdateNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"statusUpdateNavigationController"];
    UIViewController* topPicksNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"topPicksNavigationController"];
    NSArray* newTabViewControllers = [NSArray arrayWithObjects:compatibilityNavigationController, statusUpdateNavigationController, topPicksNavigationController, nil];
    self.viewControllers = newTabViewControllers;
    self.selectedIndex = 0;
    
    NSLog(@"logged out");
}

- (void)fbSessionInvalidated {
    
}

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
