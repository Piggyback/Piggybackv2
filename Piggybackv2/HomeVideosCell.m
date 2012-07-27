//
//  HomeVideosCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeVideosCell.h"

@implementation HomeVideosCell

@synthesize nameOfItem = _nameOfItem;
@synthesize favoritedBy = _favoritedBy;
@synthesize profilePic = _profilePic;
@synthesize date = _date;
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize mediaType = _mediaType;
@synthesize icon = _icon;
@synthesize videoWebView = _viewWebView;

- (IBAction)heart:(id)sender {
    [self.heart setImage:[UIImage imageNamed:@"heart-pressed-button"] forState:UIControlStateNormal];
}

- (IBAction)todo:(id)sender {
    [self.todo setImage:[UIImage imageNamed:@"todo-added-button"] forState:UIControlStateNormal];
}

@end
