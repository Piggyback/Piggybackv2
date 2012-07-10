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

@end

@implementation SetAmbassadorCell

@synthesize name = _name;
@synthesize profilePic = _profilePic;
@synthesize followMusic = _followMusic;
@synthesize followPlaces = _followPlaces;
@synthesize followVideos = _followVideos;
@synthesize setAmbassadorDelegate = _setAmbassadorDelegate;
@synthesize friend = _friend;

#pragma mark - ib actions

- (IBAction)clickFollowMusic {
    [self.setAmbassadorDelegate clickFollow:self.friend forType:@"music"];
}

- (IBAction)clickFollowPlaces {
    [self.setAmbassadorDelegate clickFollow:self.friend forType:@"places"];
}

- (IBAction)clickFollowVideos {
    [self.setAmbassadorDelegate clickFollow:self.friend forType:@"videos"];
}

@end
