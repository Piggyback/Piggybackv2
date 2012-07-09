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
#import "LoginViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "PBUser.h"
#import "PBAmbassador.h"
#import "SetAmbassadorsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

//NSString* RK_BASE_URL = @"http://piggybackv2.herokuapp.com";
NSString* RK_BASE_URL = @"http://localhost:5000";
NSString* const FB_APP_ID = @"316977565057222";
NSString* const FSQ_CLIENT_ID = @"LBZXOLI3RUL2GDOHGPO5HH4Z101JUATS2ECUZ0QACUJVWUFB";
NSString* const FSQ_CALLBACK_URL = @"piggyback://foursquare";

@synthesize window = _window;
@synthesize foursquare = _foursquare;
@synthesize playbackManager = _playbackManager;
@synthesize facebook = _facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // set up storyboard and root view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PiggybackTabBarController *rootViewController = (PiggybackTabBarController *)self.window.rootViewController;
    
    // set up restkit
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:RK_BASE_URL]];
    objectManager.acceptMIMEType = RKMIMETypeJSON;
    objectManager.serializationMIMEType = RKMIMETypeJSON;
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"Piggybackv2.sqlite"];
    [RKObjectManager setSharedManager:objectManager];
    
    [self setupRestkitRouting];
    [self setupRestkitMapping];

    // setting up foursquare
    self.foursquare = [[BZFoursquare alloc] initWithClientID:FSQ_CLIENT_ID callbackURL:FSQ_CALLBACK_URL];
    self.foursquare.sessionDelegate = self;
    
    // setting up spotify
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"com.getpiggyback.Piggybackv2"
										   loadingPolicy:SPAsyncLoadingManual
												   error:nil];
    [[SPSession sharedSession] setDelegate:self];
    
    // setting up facebook
    self.facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.facebook isSessionValid]) {
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        [self.window makeKeyAndVisible];
        [rootViewController presentViewController:loginViewController animated:NO completion:nil];
    } else {
        // do nothing (default behavior is to show tab bar controller)
    }
    
    return YES;
}

#pragma mark -
#pragma mark - setting up restkit mapping and routing

- (void)setupRestkitRouting {
    RKObjectRouter *router = [RKObjectManager sharedManager].router;
    [router routeClass:[PBUser class] toResourcePath:@"/addUser" forMethod:RKRequestMethodPOST];
    [router routeClass:[PBUser class] toResourcePath:@"/updateUser" forMethod:RKRequestMethodPUT];
    [router routeClass:[PBAmbassador class] toResourcePath:@"/addAmbassador" forMethod:RKRequestMethodPOST];
}

- (void)setupRestkitMapping {

    // mapping declarations
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBUser" inManagedObjectStore:objectManager.objectStore];
    RKManagedObjectMapping* ambassadorMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBAmbassador" inManagedObjectStore:objectManager.objectStore];
    
    // user mapping
    userMapping.primaryKeyAttribute = @"uid";
    [userMapping mapAttributes:@"uid",@"fbId",@"firstName",@"lastName",@"email",@"spotifyUsername",@"youtubeUsername",@"foursquareId",@"isPiggybackUser",nil];
//    [userMapping mapRelationship:@"ambassadors" withMapping:ambassadorMapping];
    [objectManager.mappingProvider setMapping:userMapping forKeyPath:@"PBUser"];
    
    // ambassador mapping
    [ambassadorMapping mapAttributes:@"followerId",@"ambasadorId",@"type",nil];
    [ambassadorMapping mapRelationship:@"follower" withMapping:userMapping];
    [ambassadorMapping connectRelationship:@"follower" withObjectForPrimaryKeyAttribute:@"followerId"];
    [objectManager.mappingProvider setMapping:ambassadorMapping forKeyPath:@"ambassador"];
    
    // serialization declarations
    RKObjectMapping *userSerializationMapping = [RKObjectMapping mappingForClassWithName:@"PBUser"];
    RKObjectMapping *ambassadorSerializationMapping = [RKObjectMapping mappingForClassWithName:@"PBAmbassador"];

    // user serialization
    [userSerializationMapping mapAttributes:@"uid",@"fbId",@"firstName",@"lastName",@"email",@"spotifyUsername",@"youtubeUsername",@"foursquareId",@"isPiggybackUser",nil];
//    [userSerializationMapping mapKeyPath:@"ambassadors" toRelationship:@"ambassadors" withMapping:ambassadorSerializationMapping];
    [objectManager.mappingProvider setSerializationMapping:userSerializationMapping forClass:[PBUser class]];
    
    // ambassador serialization
    [ambassadorSerializationMapping mapAttributes:@"followerId",@"ambassadorId",@"type",nil];
    [objectManager.mappingProvider setSerializationMapping:ambassadorSerializationMapping forClass:[PBAmbassador class]];
    
}

#pragma mark -
#pragma mark - handling facebook and foursquare openURL redirects

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[[[url absoluteString] componentsSeparatedByString:@":"] objectAtIndex:0] isEqualToString:@"fb316977565057222"]) {
        return [self.facebook handleOpenURL:url];
    } else if ([[[[url absoluteString] componentsSeparatedByString:@":"] objectAtIndex:0] isEqualToString:@"piggyback"]) {
        return [self.foursquare handleOpenURL:url];
    } else {
        NSLog(@"did not find a matching openURL");
        return NO;
    }
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

#pragma mark -
#pragma mark - BZFoursquareSessionDelegate protocol methods
- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    NSLog(@"foursquare did authorize");
    
    [(ExploreTableViewController*)[[[(PiggybackTabBarController *)self.window.rootViewController viewControllers] objectAtIndex:1] topViewController] getFoursquareSelf];
    
    // first time you log in, get foursquare friends and store usernames into friends core data db
    [(ExploreTableViewController*)[[[(PiggybackTabBarController *)self.window.rootViewController viewControllers] objectAtIndex:1] topViewController] getFoursquareFriends];
    
    // get foursquare friend checkins
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
#pragma mark -- FBSessionDelegate methods
- (void)fbDidLogin {
    Facebook *facebook = [(AppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // get current user
    PiggybackTabBarController* rootViewController = (PiggybackTabBarController*)self.window.rootViewController;
    [(LoginViewController*)[rootViewController presentedViewController] getAndStoreCurrentUserFbInformationAndUid];
    
    // dismiss login view 
    [rootViewController dismissViewControllerAnimated:NO completion:nil]; // dismisses loginViewController
    
    // show account link page when you log in for the first time
//    SetAmbassadorsViewController* setAmbassadorsViewController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"setAmbassadorsViewController"];
//    [rootViewController presentViewController:setAmbassadorsViewController animated:NO completion:nil];
    AccountLinkViewController *accountLinkViewController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"accountLinkViewController"];
    [rootViewController presentViewController:accountLinkViewController animated:NO completion:nil];  
    
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
    
    PiggybackTabBarController* rootViewController = (PiggybackTabBarController*)self.window.rootViewController;
    [rootViewController dismissViewControllerAnimated:NO completion:nil]; // dismisses account view controller

    LoginViewController *loginViewController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [rootViewController presentViewController:loginViewController animated:NO completion:nil];
    
#warning - do not reset tabs
    // release existing view controllers and create new instances for next user who logs in
//    UIViewController* listenNavigationController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"listenNavigationController"];
//    UIViewController* exploreNavigationController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"exploreNavigationController"];
//    UIViewController* watchNavigationController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"watchNavigationController"];
//    NSArray* newTabViewControllers = [NSArray arrayWithObjects:listenNavigationController, exploreNavigationController, watchNavigationController, nil];
//    rootViewController.viewControllers = newTabViewControllers;
//    rootViewController.selectedIndex = 0;
    
    NSLog(@"logged out");
}

- (void)fbSessionInvalidated {
    
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
//    [[SPSession sharedSession] logout:^{}];
//    [self.foursquare invalidateSession];
    [_facebook logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    [(ListenTableViewController*)[[[(PiggybackTabBarController *)self.window.rootViewController viewControllers] objectAtIndex:0] topViewController] getFriendsTopTracks];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
