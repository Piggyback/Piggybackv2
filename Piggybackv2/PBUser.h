//
//  PBUser.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/26/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PBUser : NSManagedObject

@property (nonatomic, retain) NSNumber * fbid;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * uid;

@end
