//
//  PBPlacesActivity.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBUser;

@interface PBPlacesActivity : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * placesItemId;
@property (nonatomic, retain) NSString * placesActivityType;
@property (nonatomic, retain) NSNumber * placesActivityId;
@property (nonatomic, retain) NSManagedObject *placesItem;
@property (nonatomic, retain) PBUser *user;
@property (nonatomic, retain) NSSet *news;
@end

@interface PBPlacesActivity (CoreDataGeneratedAccessors)

- (void)addNewsObject:(NSManagedObject *)value;
- (void)removeNewsObject:(NSManagedObject *)value;
- (void)addNews:(NSSet *)values;
- (void)removeNews:(NSSet *)values;

@end
