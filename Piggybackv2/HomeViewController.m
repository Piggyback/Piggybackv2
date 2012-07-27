//
//  HomeViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "HomeSquareTableCell.h"
#import "CocoaLibSpotify.h"
#import "PBUser.h"
#import "PBMusicActivity.h"
#import "PBMusicItem.h"
#import <QuartzCore/QuartzCore.h>
#import "PBPlacesActivity.h"
#import "PBPlacesItem.h"
#import "PBVideosItem.h"
#import "PBVideosActivity.h"
#import "HomeVideosCell.h"
#import "YouTubeView.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableDictionary *topLists;

@property (nonatomic, strong) NSMutableSet* musicAmbassadors;
@property (nonatomic, strong) NSMutableSet* placesAmbassadors;
@property (nonatomic, strong) NSMutableSet* videosAmbassadors;

@property (nonatomic, strong) NSMutableDictionary* cachedPlacesPhotos;
@property (nonatomic, strong) NSMutableDictionary* cachedYoutubeWebViews;
@end

@implementation HomeViewController

@synthesize tableView = _tableView;
@synthesize items = _items;
@synthesize displayItems = _displayItems;
@synthesize topLists = _topLists;

@synthesize musicAmbassadors = _musicAmbassadors;
@synthesize placesAmbassadors = _placesAmbassadors;
@synthesize videosAmbassadors = _videosAmbassadors;

@synthesize foursquareDelegate = _foursquareDelegate;
@synthesize youtubeDelegate = _youtubeDelegate;

@synthesize cachedPlacesPhotos = _cachedPlacesPhotos;
@synthesize cachedYoutubeWebViews = _cachedYoutubeWebViews;

#pragma mark - setters and getters 

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

- (NSMutableDictionary*)cachedPlacesPhotos {
    if (!_cachedPlacesPhotos) {
        _cachedPlacesPhotos = [[NSMutableDictionary alloc] init];
    }
    return _cachedPlacesPhotos;
}

- (NSMutableDictionary*)cachedYoutubeWebViews {
    if (!_cachedYoutubeWebViews) {
        _cachedYoutubeWebViews = [[NSMutableDictionary alloc] init];
    }
    return _cachedYoutubeWebViews;
}

#pragma mark - public helper methods

- (void)loadAmbassadorData {
    
    // get ambassadors
    [self getAmbassadors];
    
    // get top tracks from ambassadors
    [self getAmbassadorsTopTracks];
    [self getAmbassadorsTopPlaces];
    [self getAmbassadorsTopVideos];
    
    NSLog(@"items are %@",self.items);
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
                            [self fetchAmbassadorFavsFromCoreData];
//                            [self.items addObject:newMusicActivity];
//                            [self.displayItems addObject:newMusicActivity];
//                            [self.tableView reloadData];
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
                
                // get photo for place item
                [self.foursquareDelegate getVenuePhoto:newPlacesItem.foursquareReferenceId];
                
                // save places item
                [[RKObjectManager sharedManager] postObject:newPlacesItem usingBlock:^(RKObjectLoader* loader) {
                    loader.onDidLoadObject = ^(id object) {
                        
                        // create places activity
                        PBPlacesActivity* newPlacesActivity = [PBPlacesActivity object];
                        newPlacesActivity.uid = placesAmbasador.uid;
                        newPlacesActivity.placesItemId = newPlacesItem.placesItemId;
                        newPlacesActivity.placesActivityType = @"checkin";
                                                
                        [[RKObjectManager sharedManager] postObject:newPlacesActivity usingBlock:^(RKObjectLoader* loader) {
                            loader.onDidLoadObject = ^(id object) {
//                                [self.items addObject:newPlacesActivity];
//                                [self.displayItems addObject:newPlacesActivity];
//                                [self.tableView reloadData];
                            };
                        }];
                    };
                }];
            }
        }
    }
}

// this method is called when a youtube users top videos are fetched
-(void)updateFavoriteVideos:(NSMutableDictionary*)video {
    PBVideosItem* newVideosItem = [PBVideosItem object];
    newVideosItem.name = [video objectForKey:@"name"];
    newVideosItem.videoURL = [video objectForKey:@"url"];
    
    YouTubeView* videoWebView = [[YouTubeView alloc] initWithStringAsURL:newVideosItem.videoURL frame:CGRectMake(9,38,302,240)];
    [self.cachedYoutubeWebViews setObject:videoWebView forKey:newVideosItem.videoURL];
    NSLog(@"cached youtube views are %@",self.cachedYoutubeWebViews);
    
    [[RKObjectManager sharedManager] postObject:newVideosItem usingBlock:^(RKObjectLoader* loader) {
        loader.onDidLoadObject = ^(id object) {
            for (PBUser* videosAmbassador in self.videosAmbassadors) {
                if ([videosAmbassador.youtubeUsername isEqualToString:[video objectForKey:@"youtubeUsername"]]) {
                    PBVideosActivity* newVideosActivity = [PBVideosActivity object];
                    newVideosActivity.uid = videosAmbassador.uid;
                    newVideosActivity.videosItemId = newVideosItem.videosItemId;
                    newVideosActivity.videosActivityType = [video objectForKey:@"activity"];
                    
                    [[RKObjectManager sharedManager] postObject:newVideosActivity usingBlock:^(RKObjectLoader* loader) {
                        loader.onDidLoadObject = ^(id object) {
                            [self fetchAmbassadorFavsFromCoreData];
                        };
                    }];
                }
            }
        };
    }];
}

- (void)updateVenuePhoto:(NSString*)photoURL forVendor:(NSString*)vid {
    NSPredicate *placesItemPredicate = [NSPredicate predicateWithFormat:@"(foursquareReferenceId = %@)",vid];
    PBPlacesItem *placesItem = [PBPlacesItem objectWithPredicate:placesItemPredicate];
    placesItem.photoURL = photoURL;
    
    [[RKObjectManager sharedManager].objectStore save:nil];
    [self fetchAmbassadorFavsFromCoreData];

    // call restkit to update photoURL in database
}

#pragma mark - private helper methods

- (void)getAmbassadors {
    // fetch existing ambassadors from core data
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *myUID = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];    
    
    NSPredicate *getMe = [NSPredicate predicateWithFormat:@"(uid = %@)",myUID];
    PBUser* me = [PBUser objectWithPredicate:getMe];
    if (me) {
        self.musicAmbassadors = [me.musicAmbassadors mutableCopy];
        self.placesAmbassadors = [me.placesAmbassadors mutableCopy];
        self.videosAmbassadors = [me.videosAmbassadors mutableCopy];
    }
    
    NSLog(@"music ambassadors are %@",self.musicAmbassadors);
    NSLog(@"places ambassadors are %@",self.placesAmbassadors);
    NSLog(@"videos ambassadors are %@",self.videosAmbassadors);
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

-(void)getAmbassadorsTopVideos {
    self.youtubeDelegate = [[YoutubeDelegate alloc] init];
    self.youtubeDelegate.delegate = self;
    [self.youtubeDelegate getAmbassadorsFavoriteVideos:self.videosAmbassadors];
}

-(void)fetchAmbassadorFavsFromCoreData {
    self.items = [NSMutableArray arrayWithArray:[PBMusicActivity allObjects]];
    [self.items addObjectsFromArray:[PBPlacesActivity allObjects]];
    [self.items addObjectsFromArray:[PBVideosActivity allObjects]];
    self.displayItems = self.items;
    [self.tableView reloadData];
}

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

#pragma mark - change segment control delegate method

-(void)changeSegment:(id)sender {
    
    NSMutableArray* selectedItems = [[NSMutableArray alloc] init];

    // all
    if ([sender selectedSegmentIndex] == 0) {
        selectedItems = self.items;
    }
    
    // music
    else if ([sender selectedSegmentIndex] == 1) {
        for (id item in self.items) {
            if ([item isKindOfClass:[PBMusicActivity class]]) {
                [selectedItems addObject:item];
            }
        }
    }
    
    // places
    else if ([sender selectedSegmentIndex] == 2) {
        for (id item in self.items) {
            if ([item isKindOfClass:[PBPlacesActivity class]]) {
                [selectedItems addObject:item];
            }
        }
    }
    
    else if ([sender selectedSegmentIndex] == 3) {
        for (id item in self.items) {
            if ([item isKindOfClass:[PBVideosActivity class]]) {
                [selectedItems addObject:item];
            }
        }
    }
    
    self.displayItems = selectedItems;
    [self.tableView reloadData];
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
    if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBMusicActivity class]]) {
        static NSString *CellIdentifier = @"homeSquareTableCell";
        HomeSquareTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.profilePic.layer.cornerRadius = 5;
        cell.profilePic.layer.masksToBounds = YES;
        
        PBMusicActivity* musicActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBMusicItem* musicItem = musicActivity.musicItem;
        PBUser* user = musicActivity.user;
        
        cell.nameOfItem.text = [NSString stringWithFormat:@"%@ - %@",musicItem.artistName, musicItem.songTitle]; 
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ added a new top track",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"music-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
        
        // set picture
        [SPTrack trackForTrackURL:[NSURL URLWithString:musicItem.spotifyUrl] inSession:[SPSession sharedSession] callback:^(SPTrack *track) {
            cell.mainPic.image = track.album.cover.image;
        }];
        
        return cell;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesActivity class]]) {
        static NSString *CellIdentifier = @"homeSquareTableCell";
        HomeSquareTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.profilePic.layer.cornerRadius = 5;
        cell.profilePic.layer.masksToBounds = YES;
        
        PBPlacesActivity* placesActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBPlacesItem* placesItem = placesActivity.placesItem;
        PBUser* user = placesActivity.user;
        
        cell.nameOfItem.text = placesItem.name;
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ checked in",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"places-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
        
        // if photo exists, display
        if (placesItem.photoURL) {
            // get places image from cache if it was loaded previously
            if ([self.cachedPlacesPhotos objectForKey:placesItem.photoURL]) {
                cell.mainPic.image = [self.cachedPlacesPhotos objectForKey:placesItem.photoURL];
            }
            
            // otherwise, load image for first time and store in cache
            else {
                UIImage* placesImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:placesItem.photoURL]]];
                cell.mainPic.image = placesImage;
                [self.cachedPlacesPhotos setObject:placesImage forKey:placesItem.photoURL];
            }
        }
        
        // no photo - display default photo
        else {
            // no photo image
        }
        
        return cell;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBVideosActivity class]]) {
        PBVideosActivity* videosActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBVideosItem* videosItem = videosActivity.videosItem;
        PBUser* user = videosActivity.user;
        
        // otherwise, load cell for first time and store in cache
        static NSString *CellIdentifier = @"homeVideosCell";
        HomeVideosCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.profilePic.layer.cornerRadius = 5;
        cell.profilePic.layer.masksToBounds = YES;
        
        cell.nameOfItem.text = videosItem.name;
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ %@ a new video",user.firstName,user.lastName,videosActivity.videosActivityType];
        cell.profilePic.image = user.thumbnail;

        YouTubeView* videoWebView = [self.cachedYoutubeWebViews objectForKey:videosItem.videoURL];
        [cell.contentView addSubview:videoWebView];
        
        cell.icon.image = [UIImage imageNamed:@"movie-icon-badge.png"];
        [cell.contentView bringSubviewToFront:cell.icon];

        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return HOMESQUARETABLEROWHEIGHT;
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
    
    [self fetchAmbassadorFavsFromCoreData];

    // create segmented control to select type of media to view
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"navbar-todo-icon"],
                                             [UIImage imageNamed:@"navbar-popular-icon"],
                                             [UIImage imageNamed:@"navbar-you-icon"],
                                             [UIImage imageNamed:@"navbar-home-icon"],
                                             nil]];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor blueColor];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(changeSegment:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(self.navigationController.toolbar.frame.origin.x, self.navigationController.toolbar.frame.origin.y, 130, 34)];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = barButtonItem;
    
    NSLog(@"view did load");
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");

}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
