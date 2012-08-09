//
//  ProfileViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 8/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ProfileViewController.h"
#import "PBUser.h"

@interface ProfileViewController ()

@property (nonatomic, strong) PBUser *me;
@property (nonatomic, strong) NSNumber *numAmbassadors;

@end

@implementation ProfileViewController
@synthesize profilePic = _profilePic;
@synthesize name = _name;
@synthesize numPiggybacking = _numPiggybacking;
@synthesize statusBar = _statusBar;
@synthesize numMusicPiggybackers = _numMusicPiggybackers;
@synthesize numPlacesPiggybackers = _numPlacesPiggybackers;
@synthesize numVideosPiggybackers = _numVideosPiggybackers;
@synthesize numMusicLikes = _numMusicLikes;
@synthesize numPlacesLikes = _numPlacesLikes;
@synthesize numVideosLikes = _numVideosLikes;
@synthesize numMusicSaves = _numMusicSaves;
@synthesize numPlacesSaves = _numPlacesSaves;
@synthesize numVideosSaves = _numVideosSaves;
@synthesize progressText = _progressText;
@synthesize me = _me;
@synthesize numAmbassadors = _numAmbassadors;

- (void)loadData {
    NSDictionary *profileParam = [NSDictionary dictionaryWithKeysAndObjects:@"uid", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], nil];
    
    [[RKClient sharedClient] get:@"/profilePage" queryParameters:profileParam delegate:self];
    
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSLog(@"profile page loaded successfully");
    NSDictionary *profileResponse = [response parsedBody:nil];
    self.numMusicPiggybackers.text = [[profileResponse objectForKey:@"numMusicPiggybackers"] stringValue];
    self.numPlacesPiggybackers.text = [[profileResponse objectForKey:@"numPlacesPiggybackers"] stringValue];
    self.numVideosPiggybackers.text = [[profileResponse objectForKey:@"numVideosPiggybackers"] stringValue];
    self.numMusicLikes.text = [[profileResponse objectForKey:@"numMusicLikes"] stringValue];
    self.numPlacesLikes.text = [[profileResponse objectForKey:@"numPlacesLikes"] stringValue];
    self.numVideosLikes.text = [[profileResponse objectForKey:@"numVideosLikes"] stringValue];
    self.numMusicSaves.text = [[profileResponse objectForKey:@"numMusicSaves"] stringValue];
    self.numPlacesSaves.text = [[profileResponse objectForKey:@"numPlacesSaves"] stringValue];
    self.numVideosSaves.text = [[profileResponse objectForKey:@"numVideosSaves"] stringValue];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    NSLog(@"profile page failed load with error: %@", error);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadData];
    self.me = [PBUser findByPrimaryKey:[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]]];
    self.numAmbassadors = [NSNumber numberWithInt:([self.me.musicAmbassadors count] + [self.me.placesAmbassadors count] + [self.me.videosAmbassadors count])];

    self.profilePic.image = self.me.thumbnail;
    
    self.name.text = [NSString stringWithFormat:@"%@ %@",self.me.firstName, self.me.lastName];
    
    self.numPiggybacking.text = [NSString stringWithFormat:@"Piggybacking on %@ friends",[self.numAmbassadors stringValue]];
    
    // get percent complete
    float progress = 0;
    float total = 3;
    if (self.me.spotifyUsername) {
        progress = progress + 1;
    }
    
    if (self.me.youtubeUsername) {
        progress = progress + 1;
    }
    
    if (self.me.foursquareId) {
        progress = progress + 1;
    }

    self.statusBar.progress = progress/total;
    if (self.statusBar.progress == 1.0f) {
        self.progressText.text = @"Congratulations, you have connected all of your accounts! You're ready to piggyback your friends!";
    }
}

- (void)viewDidUnload
{
    [self setProfilePic:nil];
    [self setNumMusicPiggybackers:nil];
    [self setNumPlacesPiggybackers:nil];
    [self setNumVideosPiggybackers:nil];
    [self setNumMusicLikes:nil];
    [self setNumPlacesLikes:nil];
    [self setNumVideosLikes:nil];
    [self setNumMusicSaves:nil];
    [self setNumPlacesSaves:nil];
    [self setNumVideosSaves:nil];
    [self setStatusBar:nil];
    [self setProgressText:nil];
    [self setName:nil];
    [self setNumPiggybacking:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Profile"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
}
@end
