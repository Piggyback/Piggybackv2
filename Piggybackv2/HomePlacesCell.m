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
        [self.delegate addPlacesFeedback:self.placesActivity forFeedbackType:@"like"];
    } else {
        self.heart.selected = NO;
        [self.delegate removePlacesFeedback:self.placesActivity forFeedbackType:@"like"];
    }
}

- (IBAction)todo:(id)sender {
    if (self.todo.selected == NO) {
        self.todo.selected = YES;
        [self.delegate addPlacesFeedback:self.placesActivity forFeedbackType:@"todo"];
    } else {
        self.todo.selected = NO;
        [self.delegate removePlacesFeedback:self.placesActivity forFeedbackType:@"todo"];
    }
}

@end
