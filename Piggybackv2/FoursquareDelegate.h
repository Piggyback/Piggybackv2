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
@end

@interface FoursquareDelegate : NSObject <BZFoursquareRequestDelegate, RKObjectLoaderDelegate>

- (void)getFoursquareSelf;
- (void)getFoursquareFriends;
- (void)getRecentFriendCheckins;

@property (nonatomic, strong) id <FoursquareCheckinDelegate> delegate;

@end