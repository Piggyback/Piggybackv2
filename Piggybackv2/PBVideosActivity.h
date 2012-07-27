//
//  PBVideosActivity.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBUser, PBVideosItem, PBVideosNews;

@interface PBVideosActivity : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * videosItemId;
@property (nonatomic, retain) NSNumber * videosActivityId;
@property (nonatomic, retain) NSString * videosActivityType;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *news;
@property (nonatomic, retain) PBUser *user;
@property (nonatomic, retain) PBVideosItem *videosItem;
@end

@interface PBVideosActivity (CoreDataGeneratedAccessors)

- (void)addNewsObject:(PBVideosNews *)value;
- (void)removeNewsObject:(PBVideosNews *)value;
- (void)addNews:(NSSet *)values;
- (void)removeNews:(NSSet *)values;

@end
