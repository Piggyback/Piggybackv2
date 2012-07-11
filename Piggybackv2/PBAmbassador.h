//
//  PBAmbassador.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBUser;

@interface PBAmbassador : NSManagedObject

@property (nonatomic, retain) NSString * ambassadorType;
@property (nonatomic, retain) NSNumber * ambassadorUid;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSSet *followers;
@end

@interface PBAmbassador (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(PBUser *)value;
- (void)removeFollowersObject:(PBUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

@end
