//
//  PBAmbassador.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/16/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PBUser.h"

@class PBUser;

@interface PBAmbassador : PBUser

@property (nonatomic, retain) NSNumber * ambassadorId;
@property (nonatomic, retain) NSString * ambassadorType;
@property (nonatomic, retain) NSDate * dateBecameAmbassador;
@property (nonatomic, retain) NSNumber * followerUid;
@property (nonatomic, retain) PBUser *follower;

@end
