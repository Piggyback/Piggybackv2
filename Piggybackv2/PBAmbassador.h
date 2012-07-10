//
//  PBAmbassador.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/28/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBUser;

@interface PBAmbassador : NSManagedObject

@property (nonatomic, retain) NSNumber * ambassadorUid;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) NSString * ambassadorType;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) PBUser *follower;

@end
