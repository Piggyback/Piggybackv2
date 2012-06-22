//
//  AppDelegate.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "AppDelegate.h"
#import "PiggybackTabBarController.h"
#import "AccountLinkViewController.h"
#include "appkey.c"
#import "ListenTableViewController.h"
#import "ExploreTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString* const FSQ_CLIENT_ID = @"LBZXOLI3RUL2GDOHGPO5HH4Z101JUATS2ECUZ0QACUJVWUFB";
NSString* const FSQ_CALLBACK_URL = @"piggyback://foursquare";

@synthesize window = _window;
@synthesize foursquare = _foursquare;
@synthesize playbackManager = _playbackManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    // setting up foursquare
    self.foursquare = [[BZFoursquare alloc] initWithClientID:FSQ_CLIENT_ID callbackURL:FSQ_CALLBACK_URL];
    self.foursquare.sessionDelegate = self;
    
    // setting up spotify
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"com.getpiggyback.Piggybackv2"
										   loadingPolicy:SPAsyncLoadingManual
												   error:nil];
    [[SPSession sharedSession] setDelegate:self];

    
    // always show modal account link page on startup
    [self.window makeKeyAndVisible];
    PiggybackTabBarController *rootViewController = (PiggybackTabBarController *)self.window.rootViewController;
    
    AccountLinkViewController *accountLinkViewController = [storyboard instantiateViewControllerWithIdentifier:@"accountLinkViewController"];
    [rootViewController presentViewController:accountLinkViewController animated:NO completion:nil];
    
    return YES;
}

// Foursquare openURL handling
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.foursquare handleOpenURL:url];
}

#pragma mark -
#pragma mark - BZFoursquareSessionDelegate protocol methods
- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    NSLog(@"foursquare did authorize");
    [(ExploreTableViewController*)[[[(PiggybackTabBarController *)self.window.rootViewController viewControllers] objectAtIndex:1] topViewController] getRecentFriendCheckins];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"foursquare failed to authorize: %@", errorInfo);
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AccountLinkViewController *accountLinkViewController = [storyboard instantiateViewControllerWithIdentifier:@"accountLinkViewController"];
	return accountLinkViewController;
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	// Invoked by SPSession after a successful login.
    NSLog(@"logged into spotify");
    
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    [(ListenTableViewController*)[[[(PiggybackTabBarController *)self.window.rootViewController viewControllers] objectAtIndex:0] topViewController] getFriendsTopTracks];
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	// Invoked by SPSession after a failed login.
    NSLog(@"failed to log into spotify");
}

-(void)sessionDidLogOut:(SPSession *)aSession {
	NSLog(@"logged out of spotify");
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


#pragma mark -
#pragma mark - AppDelegate methods
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[SPSession sharedSession] logout:^{}];
    [self.foursquare invalidateSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
