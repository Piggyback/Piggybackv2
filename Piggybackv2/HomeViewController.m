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
#import "PBMusicActivity.h"
#import "PBMusicItem.h"
#import <QuartzCore/QuartzCore.h>
#import "PBPlacesActivity.h"
#import "PBPlacesItem.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableSet* selectedFilters;
@property (nonatomic, strong) NSMutableDictionary *topLists;
@property (nonatomic, strong) NSMutableArray *topPlaces;
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableArray *displayItems;


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
@synthesize displayItems = _displayItems;
@synthesize topLists = _topLists;
@synthesize topPlaces = _topPlaces;

@synthesize musicAmbassadors = _musicAmbassadors;
@synthesize placesAmbassadors = _placesAmbassadors;
@synthesize videosAmbassadors = _videosAmbassadors;

@synthesize foursquareDelegate = _foursquareDelegate;

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

- (NSMutableArray*)displayItems {
    if (!_displayItems) {
        _displayItems = [[NSMutableArray alloc] init];
    }
    return _displayItems;
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

- (NSMutableDictionary*)topLists {
    if (!_topLists) {
        _topLists = [[NSMutableDictionary alloc] init];
    }
    return _topLists;
}

#pragma mark - public helper methods

- (void)getAmbassadors {
    // fetch existing ambassadors from core data
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *myUID = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];    
    
    NSPredicate *getMe = [NSPredicate predicateWithFormat:@"(uid = %@)",myUID];
    PBUser* me = [PBUser objectWithPredicate:getMe];
    if (me) {
        self.musicAmbassadors = [me.musicAmbassadors mutableCopy];
        self.placesAmbassadors = [me.placesAmbassadors mutableCopy];
    }
    
    NSLog(@"music ambassadors are %@",self.musicAmbassadors);
    NSLog(@"places ambassadors are %@",self.placesAmbassadors);
}

-(void)getAmbassadorsTopTracks {

    for (PBUser* ambassador in self.musicAmbassadors) {
        NSString* spotifyUsername = @"";
        if ([ambassador.lastName isEqualToString:@"Gao"]) {
            spotifyUsername = @"lemikegao";
        } else if ([ambassador.lastName isEqualToString:@"Jiang"]) {
            spotifyUsername = @"kimikul";
        }
        
        SPToplist* topList = [SPToplist toplistForUserWithName:spotifyUsername inSession:[SPSession sharedSession]];
        [topList addObserver:self forKeyPath:@"tracks" options:0 context:nil];
        [self.topLists setObject:topList forKey:ambassador.uid];
    }
}

-(void)getAmbassadorsTopPlaces {
    self.foursquareDelegate = [[FoursquareDelegate alloc] init];
    self.foursquareDelegate.delegate = self;
    [self.foursquareDelegate getRecentFriendCheckins];
}

// this method is called when a spotify user's top list is fetched
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tracks"]) {
        NSString* ambassadorUid = [[self.topLists allKeysForObject:object] lastObject];
        for (SPTrack* track in [[self.topLists objectForKey:ambassadorUid] tracks]) {
            PBMusicItem* newMusicItem = [PBMusicItem object];
            newMusicItem.artistName = [[[track artists] valueForKey:@"name"] componentsJoinedByString:@","];
            newMusicItem.songTitle = track.name;
            newMusicItem.albumTitle = track.album.name;
            newMusicItem.albumYear = [NSNumber numberWithUnsignedInteger:track.album.year];
            newMusicItem.spotifyUrl = [track.spotifyURL absoluteString];
            newMusicItem.songDuration = [NSNumber numberWithFloat:track.duration];
            
            // add music item
            [[RKObjectManager sharedManager] postObject:newMusicItem usingBlock:^(RKObjectLoader* loader) {
                loader.onDidLoadObject = ^(id object) {
                    PBMusicActivity* newMusicActivity = [PBMusicActivity object];
                    newMusicActivity.uid = [NSNumber numberWithInteger:[ambassadorUid intValue]];
                    newMusicActivity.musicItemId = newMusicItem.musicItemId;
                    newMusicActivity.musicActivityType = @"top track";
                    
                    [[RKObjectManager sharedManager] postObject:newMusicActivity usingBlock:^(RKObjectLoader* loader) {
                        loader.onDidLoadObject = ^(id object) {
                            [self.items addObject:newMusicActivity];
                            [self.displayItems addObject:newMusicActivity];
                            [self.tableView reloadData];
                        };
                    }];
                };
            }];
        }
    }
}

// this method is called when your ambassadors checkin's are fetched
-(void)updateCheckins:(NSArray*)checkins {
    for (NSDictionary* checkin in checkins) {
        for (PBUser* placesAmbasador in self.placesAmbassadors) {
            if ([placesAmbasador.foursquareId isEqualToNumber:[NSNumber numberWithInt:[[[checkin objectForKey:@"user"] objectForKey:@"id"] intValue]]]) {
                PBPlacesItem* newPlacesItem = [PBPlacesItem object];
                newPlacesItem.addr = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"address"];
                newPlacesItem.addrCity = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"city"];
                newPlacesItem.addrCountry = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"country"];
                newPlacesItem.addrState = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"state"];
                newPlacesItem.addrZip = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"postalCode"];
                newPlacesItem.foursquareReferenceId = [[checkin objectForKey:@"venue"] objectForKey:@"id"];
                newPlacesItem.lat = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lat"];
                newPlacesItem.lng = [[[checkin objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lng"];
                newPlacesItem.name = [[checkin objectForKey:@"venue"] objectForKey:@"name"];
                newPlacesItem.phone = [[[checkin objectForKey:@"venue"] objectForKey:@"contact"] objectForKey:@"formattedPhone"];
                
                [[RKObjectManager sharedManager] postObject:newPlacesItem usingBlock:^(RKObjectLoader* loader) {
                    loader.onDidLoadObject = ^(id object) {
                        PBPlacesActivity* newPlacesActivity = [PBPlacesActivity object];
                        newPlacesActivity.uid = placesAmbasador.uid;
                        newPlacesActivity.placesItemId = newPlacesItem.placesItemId;
                        newPlacesActivity.placesActivityType = @"checkin";
                        
                        [[RKObjectManager sharedManager] postObject:newPlacesActivity usingBlock:^(RKObjectLoader* loader) {
                            loader.onDidLoadObject = ^(id object) {
                                [self.items addObject:newPlacesActivity];
                                [self.displayItems addObject:newPlacesActivity];
                                [self.tableView reloadData];
                            };
                        }];
                    };
                }];
            }
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
    return [self.displayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homeTableCell";
    HomeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.profilePic.layer.cornerRadius = 5;
    cell.profilePic.layer.masksToBounds = YES;
    
    if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBMusicActivity class]]) {
        PBMusicActivity* musicActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBMusicItem* musicItem = musicActivity.musicItem;
        PBUser* user = musicActivity.user;
        
        cell.nameOfItem.text = [NSString stringWithFormat:@"%@ - %@",musicItem.artistName, musicItem.songTitle]; 
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ added a new top track",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"music-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesActivity class]]) {
        PBPlacesActivity* placesActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBPlacesItem* placesItem = placesActivity.placesItem;
        PBUser* user = placesActivity.user;
        
        cell.nameOfItem.text = placesItem.name;
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ checked in",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"places-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
    }
    
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
    NSLog(@"view did load");
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");

}

- (void)viewDidAppear:(BOOL)animated {
    
    // get ambassadors
    [self getAmbassadors];
    
    // get top tracks from ambassadors
    [self getAmbassadorsTopTracks];
    [self getAmbassadorsTopPlaces];
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

- (void)updateDisplayedItems {
    if ([self.selectedFilters count] == 0) {
        self.displayItems = self.items;
    } else {
        NSMutableArray* selectedItems = [[NSMutableArray alloc] init];
        for (id item in self.items) {
            for (NSString* type in self.selectedFilters) {
                if ([type isEqualToString:@"music"]) {
                    if ([item isKindOfClass:[PBMusicActivity class]]) {
                        [selectedItems addObject:item];
                    }
                } else if ([type isEqualToString:@"places"]) {
                    if ([item isKindOfClass:[PBPlacesActivity class]]) {
                        [selectedItems addObject:item];
                    }
                } else if ([type isEqualToString:@"videos"]) {
//                    if ([item isKindOfClass:[PBVideosActivity class]]) {
//                        [selectedItems addObject:item];
//                    }
                }
            }
            self.displayItems = selectedItems;
        }
    }
    NSLog(@"display items is %@",self.displayItems);
    NSLog(@"set of filters is %@",self.selectedFilters);
    [self.tableView reloadData];
}

- (IBAction)clickPlacesButton:(id)sender {
    if ([self.selectedFilters containsObject:@"places"]) {
        [self.placesFilterButton setImage:[UIImage imageNamed:@"media-filter-places-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"places"];
        [self updateDisplayedItems];
    } else {
        [self.placesFilterButton setImage:[UIImage imageNamed:@"media-filter-places-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"places"];
        [self updateDisplayedItems];
    }
}

- (IBAction)clickMusicButton:(id)sender {
    if ([self.selectedFilters containsObject:@"music"]) {
        [self.musicFilterButton setImage:[UIImage imageNamed:@"media-filter-music-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"music"];
        [self updateDisplayedItems];
    } else {
        [self.musicFilterButton setImage:[UIImage imageNamed:@"media-filter-music-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"music"];
        [self updateDisplayedItems];
    }
}

- (IBAction)clickVideosButton:(id)sender {
    if ([self.selectedFilters containsObject:@"videos"]) {
        [self.videosFilterButton setImage:[UIImage imageNamed:@"media-filter-videos-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"videos"];
        [self updateDisplayedItems];
    } else {
        [self.videosFilterButton setImage:[UIImage imageNamed:@"media-filter-videos-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"videos"];
        [self updateDisplayedItems];
    }
}

@end
