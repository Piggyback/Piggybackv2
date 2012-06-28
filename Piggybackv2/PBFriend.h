//
//  PBFriend.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/28/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PBFriend : NSManagedObject

@property (nonatomic, retain) NSNumber * fbid;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * foursquareId;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * spotifyUsername;
@property (nonatomic, retain) NSString * youtubeUsername;

@end
