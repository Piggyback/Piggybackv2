//
//  ExploreTableViewController.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"

@interface ExploreTableViewController : UITableViewController <BZFoursquareRequestDelegate>

- (void)getFoursquareFriends;
- (void)getRecentFriendCheckins;

@end
