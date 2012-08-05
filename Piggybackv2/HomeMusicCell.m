//
//  HomeSquareTableCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeMusicCell.h"

@implementation HomeMusicCell

@synthesize nameOfItem = _nameOfItem;
@synthesize favoritedBy = _favoritedBy;
@synthesize profilePic = _profilePic;
@synthesize date = _date;
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize icon = _icon;
@synthesize mainPic = _mainPic;
@synthesize playButton = _playButton;
@synthesize spotifyURL = _spotifyURL;
@synthesize musicActivity = _musicActivity;
@synthesize delegate = _delegate;

#pragma mark - ib actions

- (IBAction)heart:(id)sender {
    if (self.heart.selected == NO) {
        self.heart.selected = YES;
        [self.delegate addMusicFeedback:self.musicActivity forFeedbackType:@"like"];
    } else {
        self.heart.selected = NO;
        [self.delegate removeMusicFeedback:self.musicActivity forFeedbackType:@"like"];
    }
}

- (IBAction)todo:(id)sender {
    if (self.todo.selected == NO) {
        self.todo.selected = YES;
        [self.delegate addMusicFeedback:self.musicActivity forFeedbackType:@"todo"];
    } else {
        self.todo.selected = NO;
        [self.delegate removeMusicFeedback:self.musicActivity forFeedbackType:@"todo"];
    }
}

- (IBAction)clickPlay:(id)sender {
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObject:self.spotifyURL forKey:@"spotifyURL"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickPlayMusic" object:self userInfo:userInfoDict];
}


@end