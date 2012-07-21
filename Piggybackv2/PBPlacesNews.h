//
//  PBPlacesNews.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBPlacesActivity, PBUser;

@interface PBPlacesNews : NSManagedObject

@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) NSNumber * placeItemId;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSString * newsActionType;
@property (nonatomic, retain) PBUser *follower;
@property (nonatomic, retain) PBPlacesActivity *placesActivity;

@end
