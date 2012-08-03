//
//  TodoPlacesCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "TodoPlacesCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TodoPlacesCell
@synthesize vendorImage;
@synthesize vendorName;
@synthesize vendorAddress;
@synthesize date;
@synthesize phone;

-(void)awakeFromNib {
    self.vendorImage.layer.cornerRadius = 5.0;
    self.vendorImage.layer.masksToBounds = YES;
}

@end
