//
//  HomeTableCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeTableCell.h"

@implementation HomeTableCell

@synthesize nameOfItem = _nameOfItem;
@synthesize favoritedBy = _favoritedBy;
@synthesize profilePic = _profilePic;
@synthesize date = _date;
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize mediaType = _mediaType;

- (IBAction)heart:(id)sender {
    [self.heart setImage:[UIImage imageNamed:@"heart-pressed-button"] forState:UIControlStateNormal];
}

- (IBAction)todo:(id)sender {
    [self.todo setImage:[UIImage imageNamed:@"todo-added-button"] forState:UIControlStateNormal];
    
}

@end