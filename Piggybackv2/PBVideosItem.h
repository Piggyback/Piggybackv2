//
//  PBVideosItem.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBVideosActivity;

@interface PBVideosItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * videosItemId;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSSet *videosActivity;
@end

@interface PBVideosItem (CoreDataGeneratedAccessors)

- (void)addVideosActivityObject:(PBVideosActivity *)value;
- (void)removeVideosActivityObject:(PBVideosActivity *)value;
- (void)addVideosActivity:(NSSet *)values;
- (void)removeVideosActivity:(NSSet *)values;

@end
