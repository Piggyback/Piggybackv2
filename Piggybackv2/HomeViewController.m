//
//  HomeViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "CocoaLibSpotify.h"
#import "PBUser.h"
#import "PBMusicItem.h"
#import "PBMusicActivity.h"
#import <QuartzCore/QuartzCore.h>
#import "PBPlacesActivity.h"
#import "PBPlacesItem.h"
#import "PBVideosItem.h"
#import "PBVideosActivity.h"
#import "YouTubeView.h"
#import "PBMusicTodo.h"
#import "PBMusicLike.h"
#import "PBPlacesTodo.h"
#import <RestKit/RKRequestSerialization.h>

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableDictionary *topLists;

@property (nonatomic, strong) NSMutableSet* musicAmbassadors;
@property (nonatomic, strong) NSMutableSet* placesAmbassadors;
@property (nonatomic, strong) NSMutableSet* videosAmbassadors;

@property (nonatomic, strong) NSMutableDictionary* cachedPlacesPhotos;
@property (nonatomic, strong) NSMutableDictionary* cachedYoutubeWebViews;
@property (nonatomic, strong) NSMutableDictionary* cachedAlbumCovers;

@property (nonatomic, strong) NSString* currentlyPlayingSpotifyURL;
@property BOOL isPlaying;

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
@synthesize playbackManager = _playbackManager;

@synthesize cachedPlacesPhotos = _cachedPlacesPhotos;
@synthesize cachedYoutubeWebViews = _cachedYoutubeWebViews;
@synthesize cachedAlbumCovers = _cachedAlbumCovers;

@synthesize currentlyPlayingSpotifyURL = _currentlyPlayingSpotifyURL;
@synthesize isPlaying = _isPlaying;

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

- (NSMutableDictionary*)cachedAlbumCovers {
    if (!_cachedAlbumCovers) {
        _cachedAlbumCovers = [[NSMutableDictionary alloc] init];
    }
    return _cachedAlbumCovers;
}

#pragma mark - public helper methods

- (void)loadAmbassadorData {
    
    // get ambassadors
    [self getAmbassadors];
    
    // get top tracks from ambassadors
    [self getAmbassadorsTopTracks];
    [self getAmbassadorsTopPlaces];
    [self getAmbassadorsTopVideos];
}

// this method is called when a spotify user's top list is fetched
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tracks"]) {
        
        // remove observer
        [object removeObserver:self forKeyPath:@"tracks"];
        
        // create new music item and store in core data / db
        NSString* ambassadorUid = [[self.topLists allKeysForObject:object] lastObject];
        for (SPTrack* track in [[self.topLists objectForKey:ambassadorUid] tracks]) {
            PBMusicItem* newMusicItem = [PBMusicItem object];
            newMusicItem.artistName = [[[track artists] valueForKey:@"name"] componentsJoinedByString:@","];
            newMusicItem.songTitle = track.name;
            newMusicItem.albumTitle = track.album.name;
            newMusicItem.albumYear = [NSNumber numberWithUnsignedInteger:track.album.year];
            newMusicItem.spotifyUrl = [track.spotifyURL absoluteString];
            newMusicItem.songDuration = [NSNumber numberWithFloat:track.duration];
            
            // save album covers in cache
            dispatch_queue_t getTopTracksQueue = dispatch_queue_create("getTopTracksQueue",NULL);
            dispatch_async(getTopTracksQueue, ^{
                [SPTrack trackForTrackURL:[NSURL URLWithString:newMusicItem.spotifyUrl] inSession:[SPSession sharedSession] callback:^(SPTrack *track) {
                    NSLog(@"valid track is %@",track);
                    [self.cachedAlbumCovers setObject:track.album.cover forKey:newMusicItem.spotifyUrl];
                    [track.album.cover startLoading];
                    NSLog(@"cached album covers are %@",self.cachedAlbumCovers);
                }];
            });

            // create new music activity and store in core data / db
            [[RKObjectManager sharedManager] postObject:newMusicItem usingBlock:^(RKObjectLoader* loader) {
                loader.onDidLoadObject = ^(id object) {
                    PBMusicActivity* newMusicActivity = [PBMusicActivity object];
                    newMusicActivity.uid = [NSNumber numberWithInteger:[ambassadorUid intValue]];
                    newMusicActivity.musicItemId = newMusicItem.musicItemId;
                    newMusicActivity.musicActivityType = @"top track";
                    
                    [[RKObjectManager sharedManager] postObject:newMusicActivity usingBlock:^(RKObjectLoader* loader) {
                        loader.onDidLoadObject = ^(id object) {
                            [self fetchAmbassadorFavsFromCoreData];
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
    dispatch_queue_t updateVendorPhotosQueue = dispatch_queue_create("updateVendorPhotosQueue",NULL);
    dispatch_async(updateVendorPhotosQueue, ^{
        
        NSPredicate *placesItemPredicate = [NSPredicate predicateWithFormat:@"(foursquareReferenceId = %@)",vid];
        PBPlacesItem *placesItem = [PBPlacesItem objectWithPredicate:placesItemPredicate];
        placesItem.photoURL = photoURL;
        
        if(placesItem.photoURL) {
            UIImage* placesImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:placesItem.photoURL]]];
            [self.cachedPlacesPhotos setObject:placesImage forKey:placesItem.photoURL];
            NSLog(@"places photos are %@",self.cachedPlacesPhotos);
        }
        
        // store photoURLs in core data and db
        [[RKObjectManager sharedManager] putObject:placesItem usingBlock:^(RKObjectLoader* loader) {
        }];

    });
    
    [self fetchAmbassadorFavsFromCoreData];
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
        } else if ([ambassador.lastName isEqualToString:@"Pelberg"]) {
            spotifyUsername = @"ptpells";
        } else if ([ambassador.lastName isEqualToString:@"Hsiao"]) {
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
    
    NSLog(@"items are %@",self.items);
}

-(void)cacheImages {
//    dispatch_queue_t cacheImagesQueue = dispatch_queue_create("cacheImagesQueue",NULL);
//    dispatch_async(cacheImagesQueue, ^{
        // youtube video web views
        for (id activity in self.items) {
            if ([activity isKindOfClass:[PBVideosActivity class]]) {
                PBVideosActivity *videosActivity = activity;
                YouTubeView* videoWebView = [[YouTubeView alloc] initWithStringAsURL:videosActivity.videosItem.videoURL frame:CGRectMake(9,38,302,240)];
                [self.cachedYoutubeWebViews setObject:videoWebView forKey:videosActivity.videosItem.videoURL];
            }
            
            // foursquare vendor photos
            else if ([activity isKindOfClass:[PBPlacesActivity class]]) {
                PBPlacesActivity *placesActivity = activity;
                if(placesActivity.placesItem.photoURL) {
                    UIImage* placesImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:placesActivity.placesItem.photoURL]]];
                    [self.cachedPlacesPhotos setObject:placesImage forKey:placesActivity.placesItem.photoURL];
                }
            }
            
            // spotify album covers
            else if ([activity isKindOfClass:[PBMusicActivity class]]) {
                PBMusicActivity *musicActivity = activity;
                [[SPSession sharedSession] trackForURL:[NSURL URLWithString:musicActivity.musicItem.spotifyUrl] callback:^(SPTrack *track) {
                    if (track != nil) {
                        [SPAsyncLoading waitUntilLoaded:track timeout:10.0f then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                            [self.cachedAlbumCovers setObject:track.album.cover forKey:musicActivity.musicItem.spotifyUrl];
                            [track.album.cover startLoading];
                        }];
                    }
                }];
            }
        }
//    });
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

#pragma mark - home music cell delegate methods
- (void)addMusicTodo:(PBMusicActivity*)musicActivity {
    // in add music todo
    NSLog(@"in add music to do");
    PBMusicTodo *musicTodo = [PBMusicTodo object];
    musicTodo.followerUid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]];
    musicTodo.follower = [PBUser findByPrimaryKey:musicTodo.followerUid];
    musicTodo.musicActivityId = musicActivity.musicActivityId;
    musicTodo.musicActivity = musicActivity;

    [[RKObjectManager sharedManager] postObject:musicTodo delegate:self];
}

- (void)removeMusicTodo:(PBMusicActivity *)musicActivity {
    NSLog(@"in remove music to do");
    // remove todo from core data
    PBMusicTodo *musicTodo = [PBMusicTodo objectWithPredicate:[NSPredicate predicateWithFormat:@"musicActivityId == %@", musicActivity.musicActivityId]];
    
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] objectStore] managedObjectContextForCurrentThread];
    [context deleteObject:musicTodo];
    [context save:nil];
    
    // set status flag to 'deleted' in DB
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:musicActivity.musicActivityId, @"musicActivityId", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], @"followerUid", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] put:@"/removeMusicTodo" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
    }
}

- (void)addMusicLike:(PBMusicActivity*)musicActivity {
    // in add music like
    NSLog(@"in add music like");
    PBMusicLike *musicLike = [PBMusicLike object];
    musicLike.followerUid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]];
    musicLike.follower = [PBUser findByPrimaryKey:musicLike.followerUid];
    musicLike.musicActivityId = musicActivity.musicActivityId;
    musicLike.musicActivity = musicActivity;
    
    [[RKObjectManager sharedManager] postObject:musicLike delegate:self];
}

- (void)removeMusicLike:(PBMusicActivity *)musicActivity {
    NSLog(@"in remove music like");
    // remove like from core data
    PBMusicLike *musicLike = [PBMusicLike objectWithPredicate:[NSPredicate predicateWithFormat:@"musicActivityId == %@", musicActivity.musicActivityId]];
    
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] objectStore] managedObjectContextForCurrentThread];
    [context deleteObject:musicLike];
    [context save:nil];
    
    // set deleted flag to 1 in DB
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:musicActivity.musicActivityId, @"musicActivityId", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], @"followerUid", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] put:@"/removeMusicLike" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
    }
}

- (void)addPlacesTodo:(PBPlacesActivity*)placesActivity {
    // in add places todo
    NSLog(@"in add places to do");
    PBPlacesTodo *placesTodo = [PBPlacesTodo object];
    placesTodo.followerUid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]];
    placesTodo.follower = [PBUser findByPrimaryKey:placesTodo.followerUid];
    placesTodo.placesActivityId = placesActivity.placesActivityId;
    placesTodo.placesActivity = placesActivity;
    
    [[RKObjectManager sharedManager] postObject:placesTodo delegate:self];
}

- (void)removePlacesTodo:(PBPlacesActivity *)placesActivity {
    NSLog(@"in remove places to do");
    // remove todo from core data
    PBPlacesTodo *placesTodo = [PBPlacesTodo objectWithPredicate:[NSPredicate predicateWithFormat:@"placesActivityId == %@", placesActivity.placesActivityId]];
    
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] objectStore] managedObjectContextForCurrentThread];
    [context deleteObject:placesTodo];
    [context save:nil];
    
    // set status flag to 'deleted' in DB
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:placesActivity.placesActivityId, @"placesActivityId", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], @"followerUid", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] put:@"/removePlacesTodo" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
    }
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"objects from user insert are %@",objects);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"restkit failed with error from creating new item");
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

#pragma mark - play song notification callback 

-(void)playTrack:(NSNotification*)notification {
    NSURL* trackURL = [NSURL URLWithString:[[notification userInfo] objectForKey:@"spotifyURL"]];
    [[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track) {
        if (track != nil) {
            // start new song
            if (![self.currentlyPlayingSpotifyURL isEqualToString:[[notification userInfo] objectForKey:@"spotifyURL"]]) {
                NSLog(@"start new song");
                [SPAsyncLoading waitUntilLoaded:track timeout:10.0f then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                    [self.playbackManager playTrack:track callback:^(NSError *error) {
                        if (error) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                            message:[error localizedDescription]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            self.currentlyPlayingSpotifyURL = [[notification userInfo] objectForKey:@"spotifyURL"];
                            self.playbackManager.isPlaying = YES;
                            self.isPlaying = YES;
                            [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }];
                }];
            }
            
            // pause current song
            else if ([self.currentlyPlayingSpotifyURL isEqualToString:[[notification userInfo] objectForKey:@"spotifyURL"]] && self.isPlaying) {
                NSLog(@"pause current song");
                self.isPlaying = NO;
                self.playbackManager.isPlaying = NO;
                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
            }
            
            // resume current song
            else if ([self.currentlyPlayingSpotifyURL isEqualToString:[[notification userInfo] objectForKey:@"spotifyURL"]] && !self.isPlaying) {
                NSLog(@"resume current song");
                self.playbackManager.isPlaying = YES;
                self.isPlaying = YES;
                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }];
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
        static NSString *CellIdentifier = @"homeMusicCell";
        HomeMusicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.profilePic.layer.cornerRadius = 5;
        cell.profilePic.layer.masksToBounds = YES;
        cell.delegate = self;
        
        PBMusicActivity* musicActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBMusicItem* musicItem = musicActivity.musicItem;
        PBUser* user = musicActivity.user;
        
        cell.musicActivity = musicActivity;
        
        cell.spotifyURL = musicItem.spotifyUrl;
        cell.nameOfItem.text = [NSString stringWithFormat:@"%@ - %@",musicItem.artistName, musicItem.songTitle]; 
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ added a new top track",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"music-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
        cell.mainPic.image = [(SPImage*)[self.cachedAlbumCovers objectForKey:musicItem.spotifyUrl] image];
        
        if ([cell.spotifyURL isEqualToString:self.currentlyPlayingSpotifyURL] && self.isPlaying) {
            cell.playButton.imageView.image = [UIImage imageNamed:@"pause-button"];
        } else {
            cell.playButton.imageView.image = [UIImage imageNamed:@"play-button"];
        }
        
        return cell;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesActivity class]]) {
        static NSString *CellIdentifier = @"homePlacesCell";
        HomePlacesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.profilePic.layer.cornerRadius = 5;
        cell.profilePic.layer.masksToBounds = YES;
        cell.delegate = self;
        
        PBPlacesActivity* placesActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBPlacesItem* placesItem = placesActivity.placesItem;
        PBUser* user = placesActivity.user;
        
        cell.placesActivity = placesActivity;
        
        cell.nameOfItem.text = placesItem.name;
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ checked in",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"places-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
        
        // if photo exists, display
        if (placesItem.photoURL) {
            cell.mainPic.image = [self.cachedPlacesPhotos objectForKey:placesItem.photoURL];
        }
        
        return cell;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBVideosActivity class]]) {
        PBVideosActivity* videosActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBVideosItem* videosItem = videosActivity.videosItem;
        PBUser* user = videosActivity.user;
        
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
    
    // set up playback manager
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    NSLog(@"playbackmanager is %@",self.playbackManager);
    
    // fetch home feed info
    [self fetchAmbassadorFavsFromCoreData];
    [self cacheImages];
    [self getAmbassadorsTopTracks];
    
    // register for notifications from music cell play button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playTrack:) name:@"clickPlayMusic" object:nil];
    
    // create segmented control to select type of media to view
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"navbar-todo-icon"],
                                             [UIImage imageNamed:@"filter-music"],
                                             [UIImage imageNamed:@"filter-places"],
                                             [UIImage imageNamed:@"filter-videos"],
                                             nil]];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:0];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(changeSegment:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(self.navigationController.toolbar.frame.origin.x, self.navigationController.toolbar.frame.origin.y, 150, 34)];

    self.navigationController.navigationBar.topItem.titleView = segmentedControl;
    
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
