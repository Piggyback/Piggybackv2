//
//  PBFriend.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FBImageToDataTransformer.h"

//@interface FriendFBImageToDataTransformer : NSValueTransformer {
//}
//@end

@interface PBFriend : NSManagedObject

@property (nonatomic, retain) NSNumber * fbId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * foursquareId;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * spotifyUsername;
@property (nonatomic, retain) NSString * youtubeUsername;
@property (nonatomic, retain) UIImage * thumbnail;

@end
