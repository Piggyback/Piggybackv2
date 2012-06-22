//
//  ExploreTableCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ExploreTableCell.h"

@implementation ExploreTableCell

@synthesize nameOfPlace = _nameOfPlace;
@synthesize checkedInBy = _checkedInBy;
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
