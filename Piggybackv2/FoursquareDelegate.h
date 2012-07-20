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

@interface FoursquareDelegate : NSObject <BZFoursquareRequestDelegate, RKObjectLoaderDelegate>

- (void)getFoursquareSelf;
- (void)getFoursquareFriends;
- (void)getRecentFriendCheckins;

@end
