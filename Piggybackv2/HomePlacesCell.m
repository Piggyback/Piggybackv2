//
//  HomePlacesCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomePlacesCell.h"

@implementation HomePlacesCell

@synthesize nameOfItem = _nameOfItem;
@synthesize favoritedBy = _favoritedBy;
@synthesize profilePic = _profilePic;
@synthesize date = _date;
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize icon = _icon;
@synthesize mainPic = _mainPic;
@synthesize placesActivity = _placesActivity;
@synthesize delegate = _delegate;

- (IBAction)heart:(id)sender {
    if (self.heart.selected == NO) {
        self.heart.selected = YES;
        [self.delegate addPlacesLike:self.placesActivity];
    } else {
        self.heart.selected = NO;
        [self.delegate removePlacesLike:self.placesActivity];
    }
}

- (IBAction)todo:(id)sender {
    if (self.todo.selected == NO) {
        self.todo.selected = YES;
        [self.delegate addPlacesTodo:self.placesActivity];
    } else {
        self.todo.selected = NO;
        [self.delegate removePlacesTodo:self.placesActivity];
    }
}

@end
