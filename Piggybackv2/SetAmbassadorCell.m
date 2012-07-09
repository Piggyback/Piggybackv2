//
//  SetAmbassadorCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SetAmbassadorCell.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "PBUser.h"

@interface SetAmbassadorCell ()
@property BOOL musicOn;
@property BOOL placesOn;
@property BOOL videosOn;

@end

@implementation SetAmbassadorCell

@synthesize name = _name;
@synthesize profilePic = _profilePic;
@synthesize followMusic = _followMusic;
@synthesize followPlaces = _followPlaces;
@synthesize followVideos = _followVideos;
@synthesize musicOn = _musicOn;
@synthesize placesOn = _placesOn;
@synthesize videosOn = _videosOn;
@synthesize setAmbassadorDelegate = _setAmbassadorDelegate;
@synthesize friend = _friend;

#pragma mark - ib actions

- (IBAction)clickFollowMusic {
    NSLog(@"clicked on music!");
    if (!self.musicOn) {
        [self.followMusic setImage:[UIImage imageNamed:@"follow-music-button-pressed"] forState:UIControlStateNormal];
        self.musicOn = YES;        
        [self.setAmbassadorDelegate setAmbassador:self.friend ForType:@"music"];
    } else {
        [self.followMusic setImage:[UIImage imageNamed:@"follow-music-button-normal"] forState:UIControlStateNormal];
        self.musicOn = NO;
        [self.setAmbassadorDelegate removeAmbassador:self.friend ForType:@"music"];
    }
}

- (IBAction)clickFollowPlaces {
    if (!self.placesOn) {
        [self.followPlaces setImage:[UIImage imageNamed:@"follow-places-button-pressed"] forState:UIControlStateNormal];
        self.placesOn = YES;
        [self.setAmbassadorDelegate setAmbassador:self.friend ForType:@"places"];
    } else {
        [self.followPlaces setImage:[UIImage imageNamed:@"follow-places-button-normal"] forState:UIControlStateNormal];
        self.placesOn = NO;
        [self.setAmbassadorDelegate removeAmbassador:self.friend ForType:@"places"];
    }
}

- (IBAction)clickFollowVideos {
    if (!self.videosOn) {
        [self.followVideos setImage:[UIImage imageNamed:@"follow-video-button-pressed"] forState:UIControlStateNormal];
        self.videosOn = YES;
        [self.setAmbassadorDelegate setAmbassador:self.friend ForType:@"videos"];
    } else {
        [self.followVideos setImage:[UIImage imageNamed:@"follow-video-button-normal"] forState:UIControlStateNormal];
        self.videosOn = NO;
        [self.setAmbassadorDelegate removeAmbassador:self.friend ForType:@"videos"];
    }
}

@end
