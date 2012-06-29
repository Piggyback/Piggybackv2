//
//  ExploreTableViewController.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface ExploreTableViewController : UITableViewController <BZFoursquareRequestDelegate, RKObjectLoaderDelegate>

- (void)getFoursquareSelf;
- (void)getFoursquareFriends;
- (void)getRecentFriendCheckins;

@end
