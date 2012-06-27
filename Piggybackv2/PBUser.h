//
//  PBUser.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBAmbassador;

@interface PBUser : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * fbid;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *ambassadors;
@end

@interface PBUser (CoreDataGeneratedAccessors)

- (void)addAmbassadorsObject:(PBAmbassador *)value;
- (void)removeAmbassadorsObject:(PBAmbassador *)value;
- (void)addAmbassadors:(NSSet *)values;
- (void)removeAmbassadors:(NSSet *)values;

@end
