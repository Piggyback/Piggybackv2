//
//  PiggybackTabBarController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackTabBarController.h"
#import "YouTubeTableViewController.h"
#import "SetAmbassadorsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PBUser.h"
#import "PBFriend.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import <RestKit/RKRequestSerialization.h>

@interface PiggybackTabBarController ()
@end

@implementation PiggybackTabBarController
@synthesize currentFbAPICall = _currentFbAPICall;
@synthesize setAmbassadorsNavigationController = _setAmbassadorsNavigationController;
@synthesize foursquareDelegate = _foursquareDelegate;

#pragma mark - private helper methods

- (void)storeCurrentUserFbInformation:(id)meGraphApiResult {
    // store user in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[meGraphApiResult objectForKey:@"first_name"] forKey:@"FirstName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"last_name"] forKey:@"LastName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"id"] forKey:@"FBID"];
    [defaults setObject:[meGraphApiResult objectForKey:@"email"] forKey:@"Email"];
//    [defaults synchronize];

    // store new user in core data and server db if not exists yet
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbId = %@",[defaults objectForKey:@"FBID"]];
    PBUser *user = [PBUser objectWithPredicate:predicate];
    if (!user) {
        PBUser *newUser = [PBUser object];
        newUser.fbId = [NSNumber numberWithLongLong:[[defaults objectForKey:@"FBID"] longLongValue]];
        newUser.email = [defaults objectForKey:@"Email"];
        newUser.firstName = [defaults objectForKey:@"FirstName"];
        newUser.lastName = [defaults objectForKey:@"LastName"];
        newUser.isPiggybackUser = [NSNumber numberWithBool:YES];
        
        NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",newUser.fbId];
        newUser.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
        
        [[RKObjectManager sharedManager] postObject:newUser delegate:self];
    } else {
        [defaults setObject:user.uid forKey:@"UID"];
        [defaults synchronize];
    }
}

- (void)getFriendsOfCurrentUser {
    Facebook *facebook = [(AppDelegate*)[[UIApplication sharedApplication] delegate] facebook];
    self.currentFbAPICall = fbAPIGraphMeFriends;
    [facebook requestWithGraphPath:@"me/friends?limit=5000" andDelegate:self];
}

- (void)storeCurrentUsersFriendsInCoreData:(id)meGraphApiResult {    
    // add friends to core data if they are not in it yet - do in background thread!
    dispatch_queue_t storeFriendsQueue = dispatch_queue_create("storeFriendsInCoreData",NULL);
    dispatch_async(storeFriendsQueue, ^{
        for (NSDictionary* friend in [meGraphApiResult objectForKey:@"data"]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbId = %@",[NSNumber numberWithLongLong:[[friend objectForKey:@"id"] longLongValue]]];
            NSArray *friendArray = [PBFriend objectsWithPredicate:predicate];
            if ([friendArray count] == 0) {
                PBFriend* newFriend = [PBFriend object];
                newFriend.fbId = [NSNumber numberWithLongLong:[[friend objectForKey:@"id"] longLongValue]];
                
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
        }
        [[RKObjectManager sharedManager].objectStore save:nil];
        NSLog(@"friends are done loading");
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.foursquareDelegate.didFacebookFriendsLoad = YES;
            if (self.foursquareDelegate.didFacebookFriendsLoad && self.foursquareDelegate.didLoginToFoursquare && !self.foursquareDelegate.didLoadFoursquareFriends) {
                [self.foursquareDelegate getFoursquareSelf];
                [self.foursquareDelegate getFoursquareFriends];
                NSLog(@"loading foursquare friends after friends are done loading");
            }
            [(SetAmbassadorsViewController*)self.setAmbassadorsNavigationController.topViewController reloadFriendsList];
        });
    });
}

- (void)sendProviderDeviceToken:(NSString *)deviceToken andUid:(NSNumber *)Uid {
    NSLog(@"in send provider device token from tab bar");
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:deviceToken, @"deviceToken", Uid, @"uid", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] post:@"/addIphonePushToken" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"DeviceTokenAdded"];
    }
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

#pragma mark - RKRequestDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
//    NSLog(@"add device token did load response: %@",[response bodyAsString]);
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    NSLog(@"restkit failed with error from adding push token from tab bar: %@", error);
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    NSLog(@"objects from user insert are %@",objects);
    
    // store my uid in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[(PBUser*)[objects objectAtIndex:0] uid] forKey:@"UID"];
//    [defaults synchronize];
    
    // add device token to DB if not already added
    if ([[defaults objectForKey:@"DeviceTokenAdded"] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        [self sendProviderDeviceToken:[defaults objectForKey:@"DeviceToken"] andUid:[defaults objectForKey:@"UID"]];
    }
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"restkit failed with error from user creation: %@", error);
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
    self.setAmbassadorsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"setAmbassadorsNavigationViewController"];
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
