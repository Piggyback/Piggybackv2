//
//  FoursquareDelegate.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/20/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@protocol FoursquareCheckinDelegate
-(void)updateCheckins:(NSArray*)checkins;
- (void)updateVenuePhoto:(NSString*)photoURL forVendor:(NSString*)vid;
@end

@interface FoursquareDelegate : NSObject <BZFoursquareRequestDelegate, RKObjectLoaderDelegate>

- (void)getFoursquareSelf;
- (void)getFoursquareFriends;
- (void)getRecentFriendCheckins;
- (void)getVenuePhoto:(NSString*)vid;
@property BOOL didFacebookFriendsLoad;
@property BOOL didLoginToFoursquare;
@property BOOL didLoadFoursquareFriends;
@property (nonatomic, strong) id <FoursquareCheckinDelegate> delegate;

@end