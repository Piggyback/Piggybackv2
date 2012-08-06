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
#import "PBPlacesFeedback.h"
#import "PBMusicFeedback.h"
#import "PBVideosFeedback.h"
#import <RestKit/RKRequestSerialization.h>

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableArray *displayItems;

@property (nonatomic, strong) NSMutableDictionary *topLists;

@property (nonatomic, strong) NSMutableSet* musicAmbassadors;
@property (nonatomic, strong) NSMutableSet* placesAmbassadors;
@property (nonatomic, strong) NSMutableSet* videosAmbassadors;

@property (nonatomic, strong) NSMutableDictionary* cachedPlacesPhotos;
@property (nonatomic, strong) NSMutableDictionary* cachedYoutubeWebViews;
@property (nonatomic, strong) NSMutableDictionary* cachedAlbumCovers;

@property (nonatomic, strong) NSMutableSet* heartedMusic;
@property (nonatomic, strong) NSMutableSet* heartedPlaces;
@property (nonatomic, strong) NSMutableSet* heartedVideos;
@property (nonatomic, strong) NSMutableSet* todoedMusic;
@property (nonatomic, strong) NSMutableSet* todoedPlaces;
@property (nonatomic, strong) NSMutableSet* todoedVideos;

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

@synthesize heartedMusic = _heartedMusic;
@synthesize heartedPlaces = _heartedPlaces;
@synthesize heartedVideos = _heartedVideos;
@synthesize todoedMusic = _todoedMusic;
@synthesize todoedPlaces = _todoedPlaces;
@synthesize todoedVideos = _todoedVideos;

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

- (NSMutableSet*)heartedMusic {
    if (!_heartedMusic) {
        _heartedMusic = [[NSMutableSet alloc] init];
    }
    return _heartedMusic;
}

- (NSMutableSet*)heartedPlaces {
    if (!_heartedPlaces) {
        _heartedPlaces = [[NSMutableSet alloc] init];
    }
    return _heartedPlaces;
}

- (NSMutableSet*)heartedVideos {
    if (!_heartedVideos) {
        _heartedVideos = [[NSMutableSet alloc] init];
    }
    return _heartedVideos;
}

- (NSMutableSet*)todoedMusic {
    if (!_todoedMusic) {
        _todoedMusic = [[NSMutableSet alloc] init];
    }
    return _todoedMusic;
}

- (NSMutableSet*)todoedPlaces {
    if (!_todoedPlaces) {
        _todoedPlaces = [[NSMutableSet alloc] init];
    }
    return _todoedPlaces;
}

- (NSMutableSet*)todoedVideos {
    if (!_todoedVideos) {
        _todoedVideos = [[NSMutableSet alloc] init];
    }
    return _todoedVideos;
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
                    [self.cachedAlbumCovers setObject:track.album.cover forKey:newMusicItem.spotifyUrl];
                    [track.album.cover startLoading];
                    
                    // reload cell if it is visible and the image was just reloaded
                    for (id cell in [self.tableView visibleCells]) {
                        if ([cell isKindOfClass:[HomeMusicCell class]]) {
                            HomeMusicCell* musicCell = cell;
                            if (musicCell.musicActivity.musicItem.musicItemId == newMusicItem.musicItemId) {
                                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }
                    }
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
    } else if ([keyPath isEqualToString:@"mainPic"]) {
        NSLog(@"album cover loaded!");
        
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
    
    // reload cell if it is visible and the image was just reloaded
    for (id cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[HomeVideosCell class]]) {
            HomeVideosCell* videosCell = cell;
            if (videosCell.videosActivity.videosItem.videosItemId == newVideosItem.videosItemId) {
                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }

    
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
            
            // reload cell if it is visible and the image was just reloaded
            for (id cell in [self.tableView visibleCells]) {
                if ([cell isKindOfClass:[HomePlacesCell class]]) {
                    HomePlacesCell* placesCell = cell;
                    if (placesCell.placesActivity.placesItem.placesItemId == placesItem.placesItemId) {
                        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            }        }
        
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

-(void)getExistingFeedback {
    dispatch_queue_t getMusicFeedbackQueue = dispatch_queue_create("getMusicFeedbackQueue",NULL);
    dispatch_async(getMusicFeedbackQueue, ^{
        NSArray *existingMusicFeedback = [PBMusicFeedback allObjects];
        for (PBMusicFeedback* musicFeedback in existingMusicFeedback) {
            if ([musicFeedback.musicFeedbackType isEqualToString:@"todo"]) {
                [self.todoedMusic addObject:musicFeedback.musicActivity.musicItem.musicItemId];
            } else if ([musicFeedback.musicFeedbackType isEqualToString:@"like"]) {
                [self.heartedMusic addObject:musicFeedback.musicActivity.musicItem.musicItemId];
            }
        }
    });

    dispatch_queue_t getPlacesFeedbackQueue = dispatch_queue_create("getPlacesFeedbackQueue",NULL);
    dispatch_async(getPlacesFeedbackQueue, ^{
        NSArray *existingPlacesFeedback = [PBPlacesFeedback allObjects];
        for (PBPlacesFeedback* placesFeedback in existingPlacesFeedback) {
            if ([placesFeedback.placesFeedbackType isEqualToString:@"todo"]) {
                [self.todoedPlaces addObject:placesFeedback.placesActivity.placesItem.placesItemId];
            } else if ([placesFeedback.placesFeedbackType isEqualToString:@"like"]) {
                [self.heartedPlaces addObject:placesFeedback.placesActivity.placesItem.placesItemId];
            }
        }
    });
       
    dispatch_queue_t getVideosFeedbackQueue = dispatch_queue_create("getVideosFeedbackQueue",NULL);
    dispatch_async(getVideosFeedbackQueue, ^{
        NSArray *existingVideosFeedback = [PBVideosFeedback allObjects];
        for (PBVideosFeedback* videosFeedback in existingVideosFeedback) {
            if ([videosFeedback.videosFeedbackType isEqualToString:@"todo"]) {
                [self.todoedVideos addObject:videosFeedback.videosActivity.videosItem.videosItemId];
            } else if ([videosFeedback.videosFeedbackType isEqualToString:@"like"]) {
                [self.heartedVideos addObject:videosFeedback.videosActivity.videosItem.videosItemId];
            }
        }
    });
}

-(void)cacheImages {
    // youtube video web views
    dispatch_queue_t cacheImagesQueue = dispatch_queue_create("cacheImagesQueue",NULL);
    dispatch_async(cacheImagesQueue, ^{
        for (id activity in self.items) {
            if ([activity isKindOfClass:[PBVideosActivity class]]) {
                PBVideosActivity *videosActivity = activity;
                dispatch_async(dispatch_get_main_queue(), ^{
                    YouTubeView* videoWebView = [[YouTubeView alloc] initWithStringAsURL:videosActivity.videosItem.videoURL frame:CGRectMake(9,38,302,290)];
                    [self.cachedYoutubeWebViews setObject:videoWebView forKey:videosActivity.videosItem.videoURL];
                    
                    // reload cell if it is visible and the image was just reloaded
                    for (id cell in [self.tableView visibleCells]) {
                        if ([cell isKindOfClass:[HomeVideosCell class]]) {
                            HomeVideosCell* videosCell = cell;
                            if (videosCell.videosActivity.videosItem.videosItemId == videosActivity.videosItem.videosItemId) {
                                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }
                    }
                });

            }
            
            // foursquare vendor photos
            else if ([activity isKindOfClass:[PBPlacesActivity class]]) {
                PBPlacesActivity *placesActivity = activity;
                if(placesActivity.placesItem.photoURL) {
                    UIImage* placesImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:placesActivity.placesItem.photoURL]]];
                    [self.cachedPlacesPhotos setObject:placesImage forKey:placesActivity.placesItem.photoURL];
                    
                    // reload cell if it is visible and the image was just reloaded
                    for (id cell in [self.tableView visibleCells]) {
                        if ([cell isKindOfClass:[HomePlacesCell class]]) {
                            HomePlacesCell* placesCell = cell;
                            if (placesCell.placesActivity.placesItem.placesItemId == placesActivity.placesItem.placesItemId) {
                                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }
                    }
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
                            
                            // reload cell if it is visible and the image was just reloaded
                            for (id cell in [self.tableView visibleCells]) {
                                if ([cell isKindOfClass:[HomeMusicCell class]]) {
                                    HomeMusicCell* musicCell = cell;
                                    if (musicCell.musicActivity.musicItem.musicItemId == musicActivity.musicItem.musicItemId) {
                                        [musicCell addObserver:self forKeyPath:@"mainPic" options:nil context:nil];
//                                        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                                    }
                                }
                            }
                        }];
                    }
                }];
            }
        }
    });
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
- (void)heartMusic:(NSNotification*)notification {
    PBMusicActivity* musicActivity = [[notification userInfo] objectForKey:@"musicActivity"];
    if ([self.heartedMusic containsObject:musicActivity.musicItem.musicItemId]) {
        [self removeMusicFeedback:musicActivity forFeedbackType:@"like"];
        [self.heartedMusic removeObject:musicActivity.musicItem.musicItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self addMusicFeedback:musicActivity forFeedbackType:@"like"];
        [self.heartedMusic addObject:musicActivity.musicItem.musicItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)todoMusic:(NSNotification*)notification {
    PBMusicActivity* musicActivity = [[notification userInfo] objectForKey:@"musicActivity"];
    if ([self.todoedMusic containsObject:musicActivity.musicItem.musicItemId]) {
        [self removeMusicFeedback:musicActivity forFeedbackType:@"todo"];
        [self.todoedMusic removeObject:musicActivity.musicItem.musicItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self addMusicFeedback:musicActivity forFeedbackType:@"todo"];
        [self.todoedMusic addObject:musicActivity.musicItem.musicItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)addMusicFeedback:(PBMusicActivity *)musicActivity forFeedbackType:(NSString *)feedbackType {
    PBMusicFeedback *musicFeedback = [PBMusicFeedback object];
    musicFeedback.followerUid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]];
    musicFeedback.follower = [PBUser findByPrimaryKey:musicFeedback.followerUid];
    musicFeedback.musicActivityId = musicActivity.musicActivityId;
    musicFeedback.musicActivity = musicActivity;
//    musicFeedback.musicFeedbackType = @"todo";
    musicFeedback.status = [NSNumber numberWithInt:0];
    
    if ([feedbackType isEqualToString:@"todo"]) {
        NSLog(@"in add music to do");
        
        musicFeedback.musicFeedbackType = @"todo";
        
        [[RKObjectManager sharedManager] postObject:musicFeedback delegate:self];
    } else if ([feedbackType isEqualToString:@"like"]) {
        NSLog(@"in add music like");
        
        musicFeedback.musicFeedbackType = @"like";
    }
    
    [[RKObjectManager sharedManager] postObject:musicFeedback delegate:self];
}

- (void)removeMusicFeedback:(PBMusicActivity *)musicActivity forFeedbackType:(NSString *)feedbackType {
    PBMusicFeedback *musicFeedback;
    
    if ([feedbackType isEqualToString:@"todo"]) {
        NSLog(@"in remove music to do");
        // remove todo from core data
        musicFeedback = [PBMusicFeedback objectWithPredicate:[NSPredicate predicateWithFormat:@"(musicActivityId == %@) AND (musicFeedbackType like 'todo')", musicActivity.musicActivityId]];
    } else if ([feedbackType isEqualToString:@"like"]) {
        NSLog(@"in remove music like");
        musicFeedback = [PBMusicFeedback objectWithPredicate:[NSPredicate predicateWithFormat:@"(musicActivityId == %@) AND (musicFeedbackType like 'like')", musicActivity.musicActivityId]];
    }
    
    NSNumber *musicFeedbackId = musicFeedback.musicFeedbackId;
    
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] objectStore] managedObjectContextForCurrentThread];
    [context deleteObject:musicFeedback];
    [context save:nil];
    
    // set status flag to 'deleted' in DB
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:musicFeedbackId, @"musicFeedbackId", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] put:@"/removeMusicFeedback" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
    }
}

- (void)heartPlaces:(NSNotification*)notification {
    PBPlacesActivity* placesActivity = [[notification userInfo] objectForKey:@"placesActivity"];
    if ([self.heartedPlaces containsObject:placesActivity.placesItem.placesItemId]) {
        [self removePlacesFeedback:placesActivity forFeedbackType:@"like"];
        [self.heartedPlaces removeObject:placesActivity.placesItem.placesItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self addPlacesFeedback:placesActivity forFeedbackType:@"like"];
        [self.heartedPlaces addObject:placesActivity.placesItem.placesItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)todoPlaces:(NSNotification*)notification {
    PBPlacesActivity* placesActivity = [[notification userInfo] objectForKey:@"placesActivity"];
    if ([self.todoedPlaces containsObject:placesActivity.placesItem.placesItemId]) {
        [self removePlacesFeedback:placesActivity forFeedbackType:@"todo"];
        [self.todoedPlaces removeObject:placesActivity.placesItem.placesItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self addPlacesFeedback:placesActivity forFeedbackType:@"todo"];
        [self.todoedPlaces addObject:placesActivity.placesItem.placesItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)addPlacesFeedback:(PBPlacesActivity *)placesActivity forFeedbackType:(NSString *)feedbackType {
    PBPlacesFeedback *placesFeedback = [PBPlacesFeedback object];
    placesFeedback.followerUid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]];
    placesFeedback.follower = [PBUser findByPrimaryKey:placesFeedback.followerUid];
    placesFeedback.placesActivityId = placesActivity.placesActivityId;
    placesFeedback.placesActivity = placesActivity;
//    placesFeedback.placesFeedbackType = @"todo";
    placesFeedback.status = [NSNumber numberWithInt:0];
    
    if ([feedbackType isEqualToString:@"todo"]) {
        NSLog(@"in add places to do");
        
        placesFeedback.placesFeedbackType = @"todo";
        
        [[RKObjectManager sharedManager] postObject:placesFeedback delegate:self];
    } else if ([feedbackType isEqualToString:@"like"]) {
        NSLog(@"in add places like");
        
        placesFeedback.placesFeedbackType = @"like";
    }
    
    [[RKObjectManager sharedManager] postObject:placesFeedback delegate:self];
}

- (void)removePlacesFeedback:(PBPlacesActivity *)placesActivity forFeedbackType:(NSString *)feedbackType {
    PBPlacesFeedback *placesFeedback;
    
    if ([feedbackType isEqualToString:@"todo"]) {
        NSLog(@"in remove places to do");
        // remove todo from core data
        placesFeedback = [PBPlacesFeedback objectWithPredicate:[NSPredicate predicateWithFormat:@"(placesActivityId == %@) AND (placesFeedbackType like 'todo')", placesActivity.placesActivityId]];
    } else if ([feedbackType isEqualToString:@"like"]) {
        NSLog(@"in remove places like");
        placesFeedback = [PBPlacesFeedback objectWithPredicate:[NSPredicate predicateWithFormat:@"(placesActivityId == %@) AND (placesFeedbackType like 'like')", placesActivity.placesActivityId]];
    }
    
    NSNumber *placesFeedbackId = placesFeedback.placesFeedbackId;
    
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] objectStore] managedObjectContextForCurrentThread];
    [context deleteObject:placesFeedback];
    [context save:nil];
    
    // set status flag to 'deleted' in DB
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:placesFeedbackId, @"placesFeedbackId", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] put:@"/removePlacesFeedback" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
    }
}

- (void)heartVideos:(NSNotification*)notification {
    PBVideosActivity* videosActivity = [[notification userInfo] objectForKey:@"videosActivity"];
    if ([self.heartedVideos containsObject:videosActivity.videosItem.videosItemId]) {
        [self removeVideosFeedback:videosActivity forFeedbackType:@"like"];
        [self.heartedVideos removeObject:videosActivity.videosItem.videosItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self addVideosFeedback:videosActivity forFeedbackType:@"like"];
        [self.heartedVideos addObject:videosActivity.videosItem.videosItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)todoVideos:(NSNotification*)notification {
    PBVideosActivity* videosActivity = [[notification userInfo] objectForKey:@"videosActivity"];
    if ([self.todoedVideos containsObject:videosActivity.videosItem.videosItemId]) {
        [self removeVideosFeedback:videosActivity forFeedbackType:@"todo"];
        [self.todoedMusic removeObject:videosActivity.videosItem.videosItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self addVideosFeedback:videosActivity forFeedbackType:@"todo"];
        [self.todoedVideos addObject:videosActivity.videosItem.videosItemId];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)addVideosFeedback:(PBVideosActivity *)videosActivity forFeedbackType:(NSString *)feedbackType {
    PBVideosFeedback *videosFeedback = [PBVideosFeedback object];
    videosFeedback.followerUid = [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]];
    videosFeedback.follower = [PBUser findByPrimaryKey:videosFeedback.followerUid];
    videosFeedback.videosActivityId = videosActivity.videosActivityId;
    videosFeedback.videosActivity = videosActivity;
//    videosFeedback.videosFeedbackType = @"todo";
    videosFeedback.status = [NSNumber numberWithInt:0];
    
    if ([feedbackType isEqualToString:@"todo"]) {
        NSLog(@"in add videos to do");
        
        videosFeedback.videosFeedbackType = @"todo";
        
        [[RKObjectManager sharedManager] postObject:videosFeedback delegate:self];
    } else if ([feedbackType isEqualToString:@"like"]) {
        NSLog(@"in add videos like");
        
        videosFeedback.videosFeedbackType = @"like";
    }
    
    [[RKObjectManager sharedManager] postObject:videosFeedback delegate:self];
}

- (void)removeVideosFeedback:(PBVideosActivity *)videosActivity forFeedbackType:(NSString *)feedbackType {
    PBVideosFeedback *videosFeedback;
    
    if ([feedbackType isEqualToString:@"todo"]) {
        NSLog(@"in remove videos to do");
        // remove todo from core data
        videosFeedback = [PBVideosFeedback objectWithPredicate:[NSPredicate predicateWithFormat:@"(videosActivityId == %@) AND (videosFeedbackType like 'todo')", videosActivity.videosActivityId]];
    } else if ([feedbackType isEqualToString:@"like"]) {
        NSLog(@"in remove videos like");
        videosFeedback = [PBVideosFeedback objectWithPredicate:[NSPredicate predicateWithFormat:@"(videosActivityId == %@) AND (videosFeedbackType like 'like')", videosActivity.videosActivityId]];
    }
    
    NSNumber *videosFeedbackId = videosFeedback.videosFeedbackId;
    
    NSManagedObjectContext *context = [[[RKObjectManager sharedManager] objectStore] managedObjectContextForCurrentThread];
    [context deleteObject:videosFeedback];
    [context save:nil];
    
    // set status flag to 'deleted' in DB
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:videosFeedbackId, @"videosFeedbackId", nil];
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSError *error = nil;
    NSString *json = [parser stringFromObject:params error:&error];
    
    if (!error) {
        [[RKClient sharedClient] put:@"/removeVideosFeedback" params:[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON] delegate:self];
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
        cell.delegate = self;
        
        PBMusicActivity* musicActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBMusicItem* musicItem = musicActivity.musicItem;
        PBUser* user = musicActivity.user;
        
        cell.musicActivity = musicActivity;
        cell.nameOfItem.text = [NSString stringWithFormat:@"%@ - %@",musicItem.artistName, musicItem.songTitle];
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ added a new top track",user.firstName, user.lastName];
        cell.icon.image = [UIImage imageNamed:@"music-icon-badge.png"];
        cell.profilePic.image = user.thumbnail;
        cell.mainPic.image = [(SPImage*)[self.cachedAlbumCovers objectForKey:musicItem.spotifyUrl] image];
        
        // play button
        if ([cell.musicActivity.musicItem.spotifyUrl isEqualToString:self.currentlyPlayingSpotifyURL] && self.isPlaying) {
            cell.playButton.imageView.image = [UIImage imageNamed:@"pause-button"];
        } else {
            cell.playButton.imageView.image = [UIImage imageNamed:@"play-button"];
        }
        
        // heart
        if ([self.heartedMusic containsObject:musicActivity.musicItem.musicItemId]) {
            cell.heart.imageView.image = [UIImage imageNamed:@"heart-pressed-button"];
        } else {
            cell.heart.imageView.image = [UIImage imageNamed:@"heart-button"];
        }
        
        // todo
        if ([self.todoedMusic containsObject:musicActivity.musicItem.musicItemId]) {
            cell.todo.imageView.image = [UIImage imageNamed:@"todo-added-button"];
        } else {
            cell.todo.imageView.image = [UIImage imageNamed:@"todo-button"];
        }
        
        return cell;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesActivity class]]) {
        static NSString *CellIdentifier = @"homePlacesCell";
        HomePlacesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
        
        // heart
        if ([self.heartedPlaces containsObject:placesActivity.placesItem.placesItemId]) {
            cell.heart.imageView.image = [UIImage imageNamed:@"heart-pressed-button"];
        } else {
            cell.heart.imageView.image = [UIImage imageNamed:@"heart-button"];
        }
        
        // todo
        if ([self.todoedPlaces containsObject:placesActivity.placesItem.placesItemId]) {
            cell.todo.imageView.image = [UIImage imageNamed:@"todo-added-button"];
        } else {
            cell.todo.imageView.image = [UIImage imageNamed:@"todo-button"];
        }
        
        return cell;
    } else if ([[self.displayItems objectAtIndex:indexPath.row] isKindOfClass:[PBVideosActivity class]]) {
        PBVideosActivity* videosActivity = [self.displayItems objectAtIndex:indexPath.row];
        PBVideosItem* videosItem = videosActivity.videosItem;
        PBUser* user = videosActivity.user;
        
        static NSString *CellIdentifier = @"homeVideosCell";
        HomeVideosCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.videosActivity = videosActivity;
        
        cell.nameOfItem.text = videosItem.name;
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ %@ %@ a new video",user.firstName,user.lastName,videosActivity.videosActivityType];
        cell.profilePic.image = user.thumbnail;

        YouTubeView* videoWebView = [self.cachedYoutubeWebViews objectForKey:videosItem.videoURL];
        [cell.contentView addSubview:videoWebView];
        
        cell.icon.image = [UIImage imageNamed:@"movie-icon-badge.png"];
        [cell.contentView bringSubviewToFront:cell.icon];

        // heart
        if ([self.heartedVideos containsObject:videosActivity.videosItem.videosItemId]) {
            cell.heart.imageView.image = [UIImage imageNamed:@"heart-pressed-button"];
        } else {
            cell.heart.imageView.image = [UIImage imageNamed:@"heart-button"];
        }
        
        // todo
        if ([self.todoedVideos containsObject:videosActivity.videosItem.videosItemId]) {
            cell.todo.imageView.image = [UIImage imageNamed:@"todo-added-button"];
        } else {
            cell.todo.imageView.image = [UIImage imageNamed:@"todo-button"];
        }
        
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
    [self getExistingFeedback];
    
    // register for notifications from music cell play button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playTrack:) name:@"clickPlayMusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartMusic:) name:@"heartMusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoMusic:) name:@"todoMusic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartPlaces:) name:@"heartPlaces" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoPlaces:) name:@"todoPlaces" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heartVideos:) name:@"heartVideos" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(todoVideos:) name:@"todoVideos" object:nil];
    
    // create segmented control to select type of media to view
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"All",
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
