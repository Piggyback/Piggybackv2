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
#import "Constants.h"
#import "PBUser.h"

@interface PiggybackTabBarController ()
@end

@implementation PiggybackTabBarController
@synthesize currentFbAPICall = _currentFbAPICall;

#pragma mark - private helper methods

- (void)storeCurrentUserFbInformation:(id)meGraphApiResult {
    // store user in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[meGraphApiResult objectForKey:@"first_name"] forKey:@"FirstName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"last_name"] forKey:@"LastName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"id"] forKey:@"FBID"];
    [defaults setObject:[meGraphApiResult objectForKey:@"email"] forKey:@"Email"];
    
    // create and store new user in core data if doesnt exist yet
//    PBUser *newUser = [PBUser object];
//    newUser.fbid = [NSNumber numberWithLongLong:[[defaults objectForKey:@"FBID"] longLongValue]];
//    newUser.email = [defaults objectForKey:@"Email"];
//    newUser.firstName = [defaults objectForKey:@"FirstName"];
//    newUser.lastName = [defaults objectForKey:@"LastName"];
    
    // create and store new user in database if doesnt exist yet
    
    [defaults synchronize];
}

- (void)getFriendsOfCurrentUser {
    Facebook *facebook = [(AppDelegate*)[[UIApplication sharedApplication] delegate] facebook];
    self.currentFbAPICall = fbAPIGraphMeFriends;
    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)storeCurrentUsersFriends:(id)meGraphApiResult {
    NSLog(@"friend results are %@",[meGraphApiResult objectForKey:@"data"]);
    
//    for (NSDictionary* friend in [meGraphApiResult objectForKey:@"data"]) {
        
//    }
}

#pragma mark - FBRequestDelegate methods

- (void)request:(FBRequest *)request didLoad:(id)result { 
    NSLog(@"request did load");
    switch (self.currentFbAPICall) {
        case fbAPIGraphMeFromLogin:
        {
            [self storeCurrentUserFbInformation:result];
            [self getFriendsOfCurrentUser];
            break;
        }
    
        case fbAPIGraphMeFriends: 
        {
            [self storeCurrentUsersFriends:result];
            break;
        }
        default: 
            break;
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"FBRequestDelegate Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
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
