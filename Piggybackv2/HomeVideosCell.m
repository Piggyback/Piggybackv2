//
//  HomeVideosCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeVideosCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeVideosCell

@synthesize nameOfItem = _nameOfItem;
@synthesize favoritedBy = _favoritedBy;
@synthesize profilePic = _profilePic;
@synthesize date = _date;
@synthesize icon = _icon;
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize videosActivity = _videosActivity;
@synthesize delegate = _delegate;

#pragma mark - initialization
-(void)awakeFromNib {
    self.profilePic.layer.cornerRadius = 5.0;
    self.profilePic.layer.masksToBounds = YES;
}

- (IBAction)heart:(id)sender {
    if (self.heart.selected == NO) {
        self.heart.selected = YES;
        [self.delegate addVideosFeedback:self.videosActivity forFeedbackType:@"like"];
    } else {
        self.heart.selected = NO;
        [self.delegate removeVideosFeedback:self.videosActivity forFeedbackType:@"like"];
    }
}

- (IBAction)todo:(id)sender {
    if (self.todo.selected == NO) {
        self.todo.selected = YES;
        [self.delegate addVideosFeedback:self.videosActivity forFeedbackType:@"todo"];
    } else {
        self.todo.selected = NO;
        [self.delegate removeVideosFeedback:self.videosActivity forFeedbackType:@"todo"];
    }
}

@end
