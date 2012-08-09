//
//  NewsCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "NewsCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation NewsCell
@synthesize profilePic;
@synthesize date;

-(void)awakeFromNib {
    self.profilePic.layer.cornerRadius = 5.0;
    self.profilePic.layer.masksToBounds = YES;
}

@end
