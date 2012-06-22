//
//  SongViewController.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface SongViewController : UIViewController <SPSessionPlaybackDelegate>

@property (strong, nonatomic) SPTrack *track;
@property (strong, nonatomic) SPPlaybackManager *playbackManager;
@property (weak, nonatomic) IBOutlet UIImageView *trackCover;
@property (weak, nonatomic) IBOutlet UILabel *trackTitle;
@property (weak, nonatomic) IBOutlet UILabel *trackArtist;
@property (weak, nonatomic) IBOutlet UILabel *albumInfo;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider;

- (IBAction)playTrack:(id)sender;
- (IBAction)setTrackPosition:(id)sender;

@end
