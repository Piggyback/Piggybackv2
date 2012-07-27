//
//  YoutubeDelegate.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YoutubeDelegate <NSObject>
-(void)updateFavoriteVideos:(NSMutableDictionary*)video;
@end

@interface YoutubeDelegate : NSObject
-(void)getAmbassadorsFavoriteVideos:(NSMutableSet*)videosAmbassadors;
@property (nonatomic, weak) id <YoutubeDelegate> delegate;
@end
