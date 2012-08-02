//
//  PBMusicNews.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/16/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBMusicActivity, PBUser;

@interface PBMusicNews : NSManagedObject

@property (nonatomic, retain) NSNumber * musicNewsId;
@property (nonatomic, retain) NSString * newsActionType;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * musicActivityId;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) PBMusicActivity *musicActivity;
@property (nonatomic, retain) PBUser *follower;

@end
