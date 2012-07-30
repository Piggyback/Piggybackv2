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

#pragma mark - ib actions
//-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        [self.playButton setImage:[UIImage imageNamed:@"play-button"] forState:UIControlStateNormal];
//    }
//    return self;
//}

- (IBAction)heart:(id)sender {
    [self.heart setImage:[UIImage imageNamed:@"heart-pressed-button"] forState:UIControlStateNormal];
}

- (IBAction)todo:(id)sender {
    [self.todo setImage:[UIImage imageNamed:@"todo-added-button"] forState:UIControlStateNormal];
}

- (IBAction)clickPlay:(id)sender {
    NSDictionary* userInfoDict = [NSDictionary dictionaryWithObject:self.spotifyURL forKey:@"spotifyURL"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickPlayMusic" object:self userInfo:userInfoDict];
    if ([self.playButton.imageView.image isEqual:[UIImage imageNamed:@"pause-button"]]) {
        [self.playButton setImage:[UIImage imageNamed:@"play-button"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"pause-button"] forState:UIControlStateNormal];
    }
}

@end