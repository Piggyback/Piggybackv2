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
@property (nonatomic, strong) NSNumber *numPiggybackers;
@property (nonatomic, strong) NSNumber *numLikes;
@property (nonatomic, strong) NSNumber *numSaves;

@end

@implementation ProfileViewController
@synthesize profilePic = _profilePic;

@synthesize me = _me;
@synthesize numAmbassadors = _numAmbassadors;
@synthesize numPiggybackers = _numPiggybackers;
@synthesize numLikes = _numLikes;
@synthesize numSaves = _numSaves;

- (void)loadData {
    NSDictionary *profileParam = [NSDictionary dictionaryWithKeysAndObjects:@"uid", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], nil];
    
    [[RKClient sharedClient] get:@"/profilePage" queryParameters:profileParam delegate:self];
    
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    NSLog(@"profile page loaded successfully");
    NSDictionary *profileResponse = [response parsedBody:nil];
    self.numPiggybackers = [profileResponse objectForKey:@"numPiggybackers"];
    self.numLikes = [profileResponse objectForKey:@"numLikes"];
    self.numSaves = [profileResponse objectForKey:@"numSaves"];
    
    NSLog(@"numPiggybackers: %@, numLikes: %@, numSaves: %@", self.numPiggybackers, self.numLikes, self.numSaves);
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
    
    NSLog(@"num of ambassadors: %@", self.numAmbassadors);
}

- (void)viewDidUnload
{
    [self setProfilePic:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
