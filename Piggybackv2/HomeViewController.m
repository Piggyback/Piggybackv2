//
//  HomeViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "HomeTableCell.h"
#import "CocoaLibSpotify.h"
#import "PBUser.h"
#import "PBAmbassador.h"
#import "PBMusicItem.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableSet* selectedFilters;
@property (nonatomic, strong) SPToplist *topList;
@property (nonatomic, strong) NSMutableArray* items;

@property (nonatomic, strong) NSMutableSet* musicAmbassadors;
@property (nonatomic, strong) NSMutableSet* placesAmbassadors;
@property (nonatomic, strong) NSMutableSet* videosAmbassadors;

@end

@implementation HomeViewController

@synthesize musicFilterButton = _musicFilterButton;
@synthesize videosFilterButton = _videosFilterButton;
@synthesize tableView = _tableView;
@synthesize placesFilterButton = _placesFilterButton;
@synthesize selectedFilters = _selectedFilters;
@synthesize items = _items;
@synthesize topList = _topList;

@synthesize musicAmbassadors = _musicAmbassadors;
@synthesize placesAmbassadors = _placesAmbassadors;
@synthesize videosAmbassadors = _videosAmbassadors;

#pragma mark - setters and getters 

- (NSMutableSet*)selectedFilters {
    if (!_selectedFilters) {
        _selectedFilters = [[NSMutableSet alloc] init];
    }
    return _selectedFilters;
}

- (NSMutableArray*)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (NSMutableSet*)musicAmbassadors {
    if (!_musicAmbassadors) {
        _musicAmbassadors = [[NSMutableSet alloc] init];
    }
    return _musicAmbassadors;
}

- (NSMutableSet*)placesAmbassadors {
    if (!_placesAmbassadors) {
        _placesAmbassadors = [[NSMutableSet alloc] init];
    }
    return _placesAmbassadors;
}

- (NSMutableSet*)videosAmbassadors {
    if (!_videosAmbassadors) {
        _videosAmbassadors = [[NSMutableSet alloc] init];
    }
    return _videosAmbassadors;
}

#pragma mark - public helper methods

- (void)getAmbassadors {
    // fetch existing ambassadors from core data
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *myUID = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];    
    
    NSPredicate *getAmbassadors = [NSPredicate predicateWithFormat:@"(followerUid = %@)",myUID];
    NSArray* myAmbassadors = [PBAmbassador objectsWithPredicate:getAmbassadors];
    for (PBAmbassador* ambassador in myAmbassadors) {
        NSPredicate *getAmbassadorUser = [NSPredicate predicateWithFormat:@"(uid = %@)",ambassador.uid];
        PBUser* ambassadorUser = [PBUser objectWithPredicate:getAmbassadorUser];
        if (ambassadorUser) {
            if ([ambassador.ambassadorType isEqualToString:@"music"]) {
                [self.musicAmbassadors addObject:ambassadorUser];
            } else if ([ambassador.ambassadorType isEqualToString:@"places"]) {
                [self.placesAmbassadors addObject:ambassadorUser];
            } else if ([ambassador.ambassadorType isEqualToString:@"videos"]) {
                [self.videosAmbassadors addObject:ambassadorUser];
            }
        }
    }
    
    NSLog(@"music ambassadors %@",self.musicAmbassadors);
    NSLog(@"places ambassadors %@",self.placesAmbassadors);
    NSLog(@"videos ambassadors %@",self.videosAmbassadors);
}

#warning - fetching top tracks is static right now, even though we have the music ambassadors in self.musicAmbassadors
#warning - make a table to store favorite songs

-(void)getFriendsTopTracks {
    [SPUser userWithURL:[NSURL URLWithString:@"spotify:user:facebook:1230930066"] inSession:[SPSession sharedSession] callback:^(SPUser *user) {
        NSLog(@"user: %@", user);
    }];
    [[SPSession sharedSession] userForURL:[NSURL URLWithString:@"spotify:user:lemikegao"] callback:^(SPUser *user) {
        NSLog(@"user: %@", user);
    }];
    self.topList = [SPToplist toplistForUserWithName:@"ptpells" inSession:[SPSession sharedSession]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"topList.tracks"]) {
        NSLog(@"peter's top tracks: %@", self.topList.tracks);
//        self.items = [self.topList.tracks mutableCopy];
        for (SPTrack* track in self.topList.tracks) {
            PBMusicItem* newMusicItem = [PBMusicItem object];
            newMusicItem.artistName = [[[track artists] valueForKey:@"name"] componentsJoinedByString:@","];
            newMusicItem.songTitle = track.name;
            newMusicItem.albumTitle = track.album.name;
            newMusicItem.albumYear = [NSNumber numberWithUnsignedInteger:track.album.year];
            newMusicItem.spotifyUrl = [track.spotifyURL absoluteString];
            
            [[RKObjectManager sharedManager] postObject:newMusicItem delegate:self];
        }
    }
}

#pragma mark - private helper methods

// get string for time elapsed e.g., "2 days ago"
- (NSString*)timeElapsed:(NSDate*)date {
    NSUInteger desiredComponents = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* elapsedTimeUnits = [[NSCalendar currentCalendar] components:desiredComponents fromDate:date toDate:[NSDate date] options:0];
    
    NSInteger number = 0;
    NSString* unit;
    
    if ([elapsedTimeUnits year] > 0) {
        number = [elapsedTimeUnits year];
        unit = [NSString stringWithFormat:@"yr"];
    }
    else if ([elapsedTimeUnits month] > 0) {
        number = [elapsedTimeUnits month];
        unit = [NSString stringWithFormat:@"mo"];
    }
    else if ([elapsedTimeUnits week] > 0) {
        number = [elapsedTimeUnits week];
        unit = [NSString stringWithFormat:@"wk"];
    }
    else if ([elapsedTimeUnits day] > 0) {
        number = [elapsedTimeUnits day];
        unit = [NSString stringWithFormat:@"d"];
    }
    else if ([elapsedTimeUnits hour] > 0) {
        number = [elapsedTimeUnits hour];
        unit = [NSString stringWithFormat:@"hr"];
    }
    else if ([elapsedTimeUnits minute] > 0) {
        number = [elapsedTimeUnits minute];
        unit = [NSString stringWithFormat:@"min"];
    }
    else if ([elapsedTimeUnits second] > 0) {
        number = [elapsedTimeUnits second];
        unit = [NSString stringWithFormat:@"sec"];
    } else if ([elapsedTimeUnits second] <= 0) {
        number = 0;
    }
    
    NSString* elapsedTime = [NSString stringWithFormat:@"%d%@",number,unit];
    
    if (number == 0) {
        elapsedTime = @"1sec";
    }
    
    return elapsedTime;
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"objects from user insert are %@",objects);
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"restkit failed with error from creating new music item");
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    NSLog(@"Retrieved JSON2: %@", [response bodyAsString]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homeTableCell";
    HomeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    SPTrack* track = [self.items objectAtIndex:indexPath.row];
    NSLog(@"track is %@",track);
    
    cell.nameOfItem.text = [NSString stringWithFormat:@"\"%@\" - %@", [track name], [[[track artists] valueForKey:@"name"] componentsJoinedByString:@","]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return HOMETABLEROWHEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - searchbar delegate methods
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
}

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    // get ambassadors
    [self getAmbassadors];
    
    // get top tracks from ambassadors
    [self getFriendsTopTracks];
    [self addObserver:self forKeyPath:@"topList.tracks" options:0 context:nil];
}

- (void)viewDidUnload
{
    [self setPlacesFilterButton:nil];
    [self setMusicFilterButton:nil];
    [self setVideosFilterButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ib action methods

- (IBAction)clickPlacesButton:(id)sender {
    if ([self.selectedFilters containsObject:@"places"]) {
        [self.placesFilterButton setImage:[UIImage imageNamed:@"media-filter-places-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"places"];
    } else {
        [self.placesFilterButton setImage:[UIImage imageNamed:@"media-filter-places-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"places"];
    }
}

- (IBAction)clickMusicButton:(id)sender {
    if ([self.selectedFilters containsObject:@"music"]) {
        [self.musicFilterButton setImage:[UIImage imageNamed:@"media-filter-music-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"music"];
    } else {
        [self.musicFilterButton setImage:[UIImage imageNamed:@"media-filter-music-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"music"];
    }
}

- (IBAction)clickVideosButton:(id)sender {
    if ([self.selectedFilters containsObject:@"videos"]) {
        [self.videosFilterButton setImage:[UIImage imageNamed:@"media-filter-videos-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"videos"];
    } else {
        [self.videosFilterButton setImage:[UIImage imageNamed:@"media-filter-videos-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"videos"];
    }
}

@end
