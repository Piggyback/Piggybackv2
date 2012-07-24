//
//  ListenCell.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ListenCell.h"

@implementation ListenCell

@synthesize activity = _activity;
@synthesize heart = _heart;
@synthesize todo = _todo;
@synthesize action = _action;
@synthesize profilePic = _profilePic;
@synthesize icon = _icon;

- (IBAction)heart:(id)sender {
    [self.heart setImage:[UIImage imageNamed:@"heart-pressed-button"] forState:UIControlStateNormal];
}

- (IBAction)todo:(id)sender {
    [self.todo setImage:[UIImage imageNamed:@"todo-added-button"] forState:UIControlStateNormal];
    
}

@end
