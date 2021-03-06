//
//  PBMusicTodo.h
//  Piggybackv2
//
//  Created by Michael Gao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBMusicActivity, PBUser;

@interface PBMusicTodo : NSManagedObject

@property (nonatomic, retain) NSNumber * musicTodoId;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) PBUser *follower;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * musicActivityId;
@property (nonatomic, retain) PBMusicActivity *musicActivity;

@end
