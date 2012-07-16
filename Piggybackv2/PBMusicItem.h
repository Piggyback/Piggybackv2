//
//  PBMusicItem.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PBMusicItem : NSManagedObject

@property (nonatomic, retain) NSString * albumTitle;
@property (nonatomic, retain) NSNumber * albumYear;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSNumber * musicItemId;
@property (nonatomic, retain) NSString * songTitle;
@property (nonatomic, retain) NSString * spotifyUrl;

@end
