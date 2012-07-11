//
//  SongViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SongViewController.h"

@interface SongViewController ()

@end

@implementation SongViewController

@synthesize track = _track;
@synthesize playbackManager = _playbackManager;
@synthesize trackCover = _trackCover;
@synthesize trackTitle;
@synthesize trackArtist;
@synthesize albumInfo;
@synthesize playButton;
@synthesize positionSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"song view controller did load");
	// Do any additional setup after loading the view.
    [self addObserver:self forKeyPath:@"track.album.cover.image" options:0 context:nil];
    [self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:0 context:nil];
    [SPTrack trackForTrackURL:self.track.spotifyURL inSession:[SPSession sharedSession] callback:^(SPTrack *track) {
        self.trackTitle.text = track.name;
        self.trackArtist.text = [[[track artists] valueForKey:@"name"] componentsJoinedByString:@","];
        self.albumInfo.text = [NSString stringWithFormat:@"%@ (%i)", track.album.name, track.album.year];
        self.positionSlider.maximumValue = track.duration;
        self.trackCover.image = track.album.cover.image;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"track.album.cover.image"]) {
		self.trackCover.image = self.track.album.cover.image;
    } else if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
        if (!self.positionSlider.highlighted) {
            self.positionSlider.value = self.playbackManager.trackPosition;
        }
    }
}

- (void)viewDidUnload
{
    [self setTrackCover:nil];
    [self setTrackTitle:nil];
    [self setTrackArtist:nil];
    [self setAlbumInfo:nil];
    [self setPlayButton:nil];
    [self setPositionSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"track.album.cover.image"];
    [self removeObserver:self forKeyPath:@"playbackManager.trackPosition"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)playTrack:(id)sender {
    [[SPSession sharedSession] trackForURL:self.track.spotifyURL callback:^(SPTrack *track) {
        if (track != nil) {
            if (!self.playButton.selected) {
                self.playButton.selected = YES;
                [SPAsyncLoading waitUntilLoaded:track timeout:10.0f then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                    [self.playbackManager playTrack:track callback:^(NSError *error) {
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                            message:[error localizedDescription]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                }];
            } else {
                self.playButton.selected = NO;
                self.playbackManager.isPlaying = NO;
            }
        }
    }];
}

- (IBAction)setTrackPosition:(id)sender {
    [self.playbackManager seekToTrackPosition:self.positionSlider.value];
}

@end
