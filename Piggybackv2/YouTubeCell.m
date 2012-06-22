//
//  YouTubeCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YouTubeCell.h"

@implementation YouTubeCell

@synthesize nameOfVideo = _nameOfVideo;
@synthesize favoritedBy = _favoritedBy;
@synthesize profilePic = _profilePic;
@synthesize date = _date;
@synthesize heart = _heart;
@synthesize todo = _todo;

- (IBAction)heart:(id)sender {
    [self.heart setImage:[UIImage imageNamed:@"heart-pressed-button"] forState:UIControlStateNormal];
}

- (IBAction)todo:(id)sender {
    [self.todo setImage:[UIImage imageNamed:@"todo-added-button"] forState:UIControlStateNormal];
    
}

@end

