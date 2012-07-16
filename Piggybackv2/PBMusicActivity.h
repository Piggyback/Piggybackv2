//
//  PBMusicActivity.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/16/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBMusicItem, PBMusicNews, PBUser;

@interface PBMusicActivity : NSManagedObject

@property (nonatomic, retain) NSNumber * musicActivityId;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * musicActivityType;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * musicItemId;
@property (nonatomic, retain) PBUser *user;
@property (nonatomic, retain) PBMusicItem *musicItem;
@property (nonatomic, retain) NSSet *news;
@end

@interface PBMusicActivity (CoreDataGeneratedAccessors)

- (void)addNewsObject:(PBMusicNews *)value;
- (void)removeNewsObject:(PBMusicNews *)value;
- (void)addNews:(NSSet *)values;
- (void)removeNews:(NSSet *)values;

@end
