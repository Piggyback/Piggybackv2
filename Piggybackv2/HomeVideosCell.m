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
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize icon = _icon;

#pragma mark - initialization
-(void)awakeFromNib {
    self.profilePic.layer.cornerRadius = 5.0;
    self.profilePic.layer.masksToBounds = YES;
}

- (IBAction)heart:(id)sender {
    [self.heart setImage:[UIImage imageNamed:@"heart-pressed-button"] forState:UIControlStateNormal];
}

- (IBAction)todo:(id)sender {
    [self.todo setImage:[UIImage imageNamed:@"todo-added-button"] forState:UIControlStateNormal];
}

@end
