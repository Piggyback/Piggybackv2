//
//  PBMusicItem.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/16/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBMusicActivity;

@interface PBMusicItem : NSManagedObject

@property (nonatomic, retain) NSString * albumTitle;
@property (nonatomic, retain) NSNumber * albumYear;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSNumber * musicItemId;
@property (nonatomic, retain) NSString * songTitle;
@property (nonatomic, retain) NSString * spotifyUrl;
@property (nonatomic, retain) id albumCover;
@property (nonatomic, retain) NSNumber * songDuration;
@property (nonatomic, retain) NSSet *musicActivity;
@end

@interface PBMusicItem (CoreDataGeneratedAccessors)

- (void)addMusicActivityObject:(PBMusicActivity *)value;
- (void)removeMusicActivityObject:(PBMusicActivity *)value;
- (void)addMusicActivity:(NSSet *)values;
- (void)removeMusicActivity:(NSSet *)values;

@end
