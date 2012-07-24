//
//  PBUser.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBMusicActivity, PBMusicNews, PBPlacesActivity, PBPlacesNews, PBUser;

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
@property (nonatomic, retain) NSSet *musicActivity;
@property (nonatomic, retain) NSSet *musicAmbassadors;
@property (nonatomic, retain) NSSet *musicFollowers;
@property (nonatomic, retain) NSSet *myMusicActions;
@property (nonatomic, retain) NSSet *placesAmbassadors;
@property (nonatomic, retain) NSSet *placesFollowers;
@property (nonatomic, retain) NSSet *myPlacesActions;
@property (nonatomic, retain) NSSet *placesActivity;
@end

@interface PBUser (CoreDataGeneratedAccessors)

- (void)addMusicActivityObject:(PBMusicActivity *)value;
- (void)removeMusicActivityObject:(PBMusicActivity *)value;
- (void)addMusicActivity:(NSSet *)values;
- (void)removeMusicActivity:(NSSet *)values;

- (void)addMusicAmbassadorsObject:(PBUser *)value;
- (void)removeMusicAmbassadorsObject:(PBUser *)value;
- (void)addMusicAmbassadors:(NSSet *)values;
- (void)removeMusicAmbassadors:(NSSet *)values;

- (void)addMusicFollowersObject:(PBUser *)value;
- (void)removeMusicFollowersObject:(PBUser *)value;
- (void)addMusicFollowers:(NSSet *)values;
- (void)removeMusicFollowers:(NSSet *)values;

- (void)addMyMusicActionsObject:(PBMusicNews *)value;
- (void)removeMyMusicActionsObject:(PBMusicNews *)value;
- (void)addMyMusicActions:(NSSet *)values;
- (void)removeMyMusicActions:(NSSet *)values;

- (void)addPlacesAmbassadorsObject:(PBUser *)value;
- (void)removePlacesAmbassadorsObject:(PBUser *)value;
- (void)addPlacesAmbassadors:(NSSet *)values;
- (void)removePlacesAmbassadors:(NSSet *)values;

- (void)addPlacesFollowersObject:(PBUser *)value;
- (void)removePlacesFollowersObject:(PBUser *)value;
- (void)addPlacesFollowers:(NSSet *)values;
- (void)removePlacesFollowers:(NSSet *)values;

- (void)addMyPlacesActionsObject:(PBPlacesNews *)value;
- (void)removeMyPlacesActionsObject:(PBPlacesNews *)value;
- (void)addMyPlacesActions:(NSSet *)values;
- (void)removeMyPlacesActions:(NSSet *)values;

- (void)addPlacesActivityObject:(PBPlacesActivity *)value;
- (void)removePlacesActivityObject:(PBPlacesActivity *)value;
- (void)addPlacesActivity:(NSSet *)values;
- (void)removePlacesActivity:(NSSet *)values;

@end
