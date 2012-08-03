//
//  TodoMusicCell.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "TodoMusicCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TodoMusicCell
@synthesize date;
@synthesize songTitle;
@synthesize songArtist;
@synthesize coverImage;
@synthesize playButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib {
    self.coverImage.layer.cornerRadius = 5.0;
    self.coverImage.layer.masksToBounds = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadImage) name:@"reloadImage" object:nil];
}

//-(void)reloadImage {
//    [self setNeedsDisplay];
//    NSLog(@"in reload image");
//}

@end
