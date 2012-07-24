//
//  PBPlacesActivity.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/23/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBPlacesItem, PBPlacesNews, PBUser;

@interface PBPlacesActivity : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * placesActivityId;
@property (nonatomic, retain) NSString * placesActivityType;
@property (nonatomic, retain) NSNumber * placesItemId;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *news;
@property (nonatomic, retain) PBPlacesItem *placesItem;
@property (nonatomic, retain) PBUser *user;
@end

@interface PBPlacesActivity (CoreDataGeneratedAccessors)

- (void)addNewsObject:(PBPlacesNews *)value;
- (void)removeNewsObject:(PBPlacesNews *)value;
- (void)addNews:(NSSet *)values;
- (void)removeNews:(NSSet *)values;

@end
