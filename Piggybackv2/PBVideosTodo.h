//
//  PBVideosTodo.h
//  Piggybackv2
//
//  Created by Michael Gao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBUser, PBVideosActivity;

@interface PBVideosTodo : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * videosActivityId;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) PBUser *follower;
@property (nonatomic, retain) PBVideosActivity *videosActivity;

@end
