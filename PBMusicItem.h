//
//  PBMusicItem.h
//  Piggybackv2
//
//  Created by Michael Gao on 7/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PBMusicItem : NSManagedObject

@property (nonatomic, strong) NSString* albumTitle;
@property (nonatomic, strong) NSNumber* albumYear;
@property (nonatomic, strong) NSString* artistName;
@property (nonatomic, strong) NSNumber* musicItemId;
@property (nonatomic, strong) NSString* songTitle;
@property (nonatomic, strong) NSString* spotifyUrl;

@end
