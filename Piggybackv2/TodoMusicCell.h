//
//  TodoMusicCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/3/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodoMusicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) NSString* spotifyURL;

- (IBAction)clickPlay:(id)sender;

@end
