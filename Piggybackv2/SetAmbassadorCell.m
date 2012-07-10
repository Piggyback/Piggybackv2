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
    if (!self.musicOn) {
        self.musicOn = YES;
        [self.followMusic setImage:[UIImage imageNamed:@"follow-music-button-pressed"] forState:UIControlStateNormal];
        [self.setAmbassadorDelegate clickMusicButton:self.friend];
        [self.setAmbassadorDelegate setAmbassador:self.friend ForType:@"music"];
    } else {
        self.musicOn = NO;
        [self.followMusic setImage:[UIImage imageNamed:@"follow-music-button-normal"] forState:UIControlStateNormal];
        [self.setAmbassadorDelegate unclickMusicButton:self.friend];
        [self.setAmbassadorDelegate removeAmbassador:self.friend ForType:@"music"];
    }
}

- (IBAction)clickFollowPlaces {
    if (!self.placesOn) {
        self.placesOn = YES;
        [self.followPlaces setImage:[UIImage imageNamed:@"follow-places-button-pressed"] forState:UIControlStateNormal];
        [self.setAmbassadorDelegate clickPlacesButton:self.friend];
        [self.setAmbassadorDelegate setAmbassador:self.friend ForType:@"places"];
    } else {
        self.placesOn = NO;
        [self.followPlaces setImage:[UIImage imageNamed:@"follow-places-button-normal"] forState:UIControlStateNormal];
        [self.setAmbassadorDelegate unclickPlacesButton:self.friend];
        [self.setAmbassadorDelegate removeAmbassador:self.friend ForType:@"places"];
    }
}

- (IBAction)clickFollowVideos {
    if (!self.videosOn) {
        self.videosOn = YES;
        [self.followVideos setImage:[UIImage imageNamed:@"follow-video-button-pressed"] forState:UIControlStateNormal];
        [self.setAmbassadorDelegate clickVideosButton:self.friend];
        [self.setAmbassadorDelegate setAmbassador:self.friend ForType:@"videos"];
    } else {
        self.videosOn = NO;
        [self.followVideos setImage:[UIImage imageNamed:@"follow-video-button-normal"] forState:UIControlStateNormal];
        [self.setAmbassadorDelegate unclickVideosButton:self.friend];
        [self.setAmbassadorDelegate removeAmbassador:self.friend ForType:@"videos"];
    }
}

@end
