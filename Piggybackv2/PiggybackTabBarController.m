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
#import "PBFriend.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

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
    [defaults synchronize];

    // create and store new user in core data if doesnt exist yet
    PBUser *newUser = [PBUser object];
    newUser.fbid = [NSNumber numberWithLongLong:[[defaults objectForKey:@"FBID"] longLongValue]];
    newUser.email = [defaults objectForKey:@"Email"];
    newUser.firstName = [defaults objectForKey:@"FirstName"];
    newUser.lastName = [defaults objectForKey:@"LastName"];
    [[RKObjectManager sharedManager].objectStore save:nil];
        
    // restkit will return core data pbuser object which will automatically be put into core data. remove above chunk of code
    
    #warning - use api to add myself into user table
    
}

- (void)getFriendsOfCurrentUser {
    Facebook *facebook = [(AppDelegate*)[[UIApplication sharedApplication] delegate] facebook];
    self.currentFbAPICall = fbAPIGraphMeFriends;
    [facebook requestWithGraphPath:@"me/friends?limit=5000" andDelegate:self];
}

- (void)storeCurrentUsersFriendsInCoreData:(id)meGraphApiResult {
    NSLog(@"friend results are %@",[meGraphApiResult objectForKey:@"data"]);
    
    for (NSDictionary* friend in [meGraphApiResult objectForKey:@"data"]) {
        PBFriend* newFriend = [PBFriend object];
        newFriend.fbid = [NSNumber numberWithLongLong:[[friend objectForKey:@"id"] longLongValue]];
        
        // parse name into first and last
        NSArray* nameComponents = [[friend objectForKey:@"name"] componentsSeparatedByString:@" "];
        if ([nameComponents count] > 0) {
            newFriend.firstName = [nameComponents objectAtIndex:0];
            NSString* lastName = @"";
            for (int i = 1; i < [nameComponents count]; i++) {
                lastName = [NSString stringWithFormat:@"%@ %@",lastName, [nameComponents objectAtIndex:i]];
            }
            if ([lastName length] > 0) {
                lastName = [lastName substringWithRange:NSMakeRange(1,[lastName length]-1)];
            }
            newFriend.lastName = lastName;
        }
    }
    [[RKObjectManager sharedManager].objectStore save:nil];
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
            [self storeCurrentUsersFriendsInCoreData:result];
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
