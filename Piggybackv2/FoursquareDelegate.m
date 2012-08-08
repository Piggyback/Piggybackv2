//
//  FoursquareDelegate.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/20/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "FoursquareDelegate.h"
#import "AppDelegate.h"
#import "PBUser.h"
#import "PBFriend.h"

@interface FoursquareDelegate ()

@property (nonatomic, strong) NSMutableDictionary *requestDict;
@property (nonatomic, strong) NSArray *checkins;

@end

@implementation FoursquareDelegate

@synthesize requestDict = _requestDict;
@synthesize checkins = _checkins;
@synthesize delegate = _delegate;
@synthesize didFacebookFriendsLoad = _didFacebookFriendsLoad;
@synthesize didLoginToFoursquare = _didLoginToFoursquare;
@synthesize didLoadFoursquareFriends = _didLoadFoursquareFriends;

#pragma mark - Getters & Setters
-(NSArray*)checkins {
    if (!_checkins) {
        _checkins = [[NSArray alloc] init];
    }
    return _checkins;
}

- (NSMutableDictionary*)requestDict {
    if (!_requestDict) {
        _requestDict = [[NSMutableDictionary alloc] init];
    }
    return _requestDict;
}

#pragma mark -
#pragma mark - Public Instance Methods
- (void)getFoursquareSelf {
    self.didLoadFoursquareFriends = YES;
    NSLog(@"foursquare in fs delegate is %@",[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare]);
    BZFoursquareRequest* request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:@"users/self" HTTPMethod:@"GET" parameters:nil delegate:self];
    [self.requestDict setObject:@"getSelf" forKey:request.description];
    [request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)getFoursquareFriends {
    BZFoursquareRequest* request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:@"users/self/friends" HTTPMethod:@"GET" parameters:nil delegate:self];
    [self.requestDict setObject:@"getFriends" forKey:request.description];
    [request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)getRecentFriendCheckins {
    BZFoursquareRequest* request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:@"checkins/recent" HTTPMethod:@"GET" parameters:nil delegate:self];
    [self.requestDict setObject:@"getFriendCheckins" forKey:request.description];
    [request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)getVenuePhoto:(NSString*)vid {
    BZFoursquareRequest* request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:[NSString stringWithFormat:@"venues/%@",vid] HTTPMethod:@"GET" parameters:nil delegate:self];
    [self.requestDict setObject:@"getVenuePhoto" forKey:request.description];
    [request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    NSLog(@"success: %@", request.response);
    for (NSString* currentRequest in [self.requestDict allKeys]) {
        if ([request.description isEqualToString:currentRequest]) {
            
            // get my foursquare id
            if ([[self.requestDict objectForKey:currentRequest] isEqualToString:@"getSelf"]) {
                if ([[[request.response objectForKey:@"user"] objectForKey:@"relationship"] isEqualToString:@"self"]) {
                    NSString* myFoursquareId = [[request.response objectForKey:@"user"] objectForKey:@"id"];
                    
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",[defaults objectForKey:@"UID"]];
                    PBUser *me = [PBUser objectWithPredicate:predicate];
                    if (me) {
                        me.foursquareId = [NSNumber numberWithLongLong:[myFoursquareId longLongValue]];
                        NSLog(@"foursquare id added is %@",me.foursquareId);
                        NSLog(@"my name is %@",me.firstName);
                        [[RKObjectManager sharedManager] putObject:me delegate:self];
                    }
                }
            }
            
            // get friends checkins
            else if ([[self.requestDict objectForKey:currentRequest] isEqualToString:@"getFriendCheckins"]) {
                self.checkins = [request.response objectForKey:@"recent"];
                [self.delegate updateCheckins:self.checkins];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
            
            // get venue photo
            else if ([[self.requestDict objectForKey:currentRequest] isEqualToString:@"getVenuePhoto"]) {
                NSString* vid = [[request.response objectForKey:@"venue"] objectForKey:@"id"];
                NSString* photoURL;
                NSArray* photoGroups = [[[request.response objectForKey:@"venue"] objectForKey:@"photos"] objectForKey:@"groups"];
                for (NSDictionary* photoGroup in photoGroups) {
                    if ([[photoGroup objectForKey:@"name"] isEqualToString:@"Venue photos"]) {
                        for (NSDictionary* photo in [photoGroup objectForKey:@"items"]) {
                            if ([[photo objectForKey:@"visibility"] isEqualToString:@"public"]) {
                                for (NSDictionary* difSizePhoto in [[photo objectForKey:@"sizes"] objectForKey:@"items"]) {
                                    if ([[difSizePhoto objectForKey:@"height"] isEqualToNumber:[NSNumber numberWithInt:300]]) {
                                        photoURL = [difSizePhoto objectForKey:@"url"];
                                        NSLog(@"photoURL is %@",photoURL);
                                        [self.delegate updateVenuePhoto:photoURL forVendor:vid];
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // get friends
            else if ([[self.requestDict objectForKey:currentRequest] isEqualToString:@"getFriends"]) {
                // link foursquare id's with friends and store in friends db
                NSArray* foursquareFriends = [[request.response objectForKey:@"friends"] objectForKey:@"items"];
                for (NSDictionary* foursquareFriend in foursquareFriends) {
                    if ([[foursquareFriend objectForKey:@"contact"] objectForKey:@"facebook"]) {
                        
                        // add foursquare acct to friend based on fbid match
                        NSLog(@"fb id is %@",[[foursquareFriend objectForKey:@"contact"] objectForKey:@"facebook"]);
                        NSLog(@"foursquare id that matches is %@",[foursquareFriend objectForKey:@"id"]);
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbId = %@",[NSNumber numberWithLongLong:[[[foursquareFriend objectForKey:@"contact"] objectForKey:@"facebook"] longLongValue]]];
                        PBFriend *friend = [PBFriend objectWithPredicate:predicate];
                        if (friend) {
                            NSLog(@"hi my foursquare friend");
                            friend.foursquareId = [NSNumber numberWithLongLong:[[foursquareFriend objectForKey:@"id"] longLongValue]];
                        }
                    }
                }
                NSLog(@"hey mike & kim");
//                [[RKObjectManager sharedManager].objectStore save:nil];
            }
            [self.requestDict removeObjectForKey:request.description];
            NSLog(@"current requests includes %@",self.requestDict);
        }
    }
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"failure: %@", error);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - 
#pragma mark - restkit delegate

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"objects from foursquare id insert is %@",objects);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"restkit failed with error from foursquare insert");
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    NSLog(@"Retrieved JSON: %@", [response bodyAsString]);
}

@end
