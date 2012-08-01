//
//  PBVideosNews.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBUser, PBVideosActivity;

@interface PBVideosNews : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) NSString * newsActionType;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSNumber * videosItemId;
@property (nonatomic, retain) PBUser *follower;
@property (nonatomic, retain) PBVideosActivity *videosActivity;

@end
