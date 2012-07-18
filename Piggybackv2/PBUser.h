//
//  PBUser.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/16/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBMusicActivity, PBMusicNews, PBUser;

@interface PBUser : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSDate * dateBecamePbUser;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * fbId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * foursquareId;
@property (nonatomic, retain) NSNumber * isPiggybackUser;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * spotifyUsername;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * youtubeUsername;
@property (nonatomic, retain) NSSet *musicAmbassadors;
@property (nonatomic, retain) NSSet *musicFollowers;
@property (nonatomic, retain) NSSet *musicActivity;
@property (nonatomic, retain) NSSet *myActions;
@end

@interface PBUser (CoreDataGeneratedAccessors)

- (void)addMusicAmbassadorsObject:(PBUser *)value;
- (void)removeMusicAmbassadorsObject:(PBUser *)value;
- (void)addMusicAmbassadors:(NSSet *)values;
- (void)removeMusicAmbassadors:(NSSet *)values;

- (void)addMusicFollowersObject:(PBUser *)value;
- (void)removeMusicFollowersObject:(PBUser *)value;
- (void)addMusicFollowers:(NSSet *)values;
- (void)removeMusicFollowers:(NSSet *)values;

- (void)addMusicActivityObject:(PBMusicActivity *)value;
- (void)removeMusicActivityObject:(PBMusicActivity *)value;
- (void)addMusicActivity:(NSSet *)values;
- (void)removeMusicActivity:(NSSet *)values;

- (void)addMyActionsObject:(PBMusicNews *)value;
- (void)removeMyActionsObject:(PBMusicNews *)value;
- (void)addMyActions:(NSSet *)values;
- (void)removeMyActions:(NSSet *)values;

@end
