//
//  TodoViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 7/31/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "TodoViewController.h"
#import "PBMusicActivity.h"
#import "PBMusicItem.h"
#import "PBPlacesItem.h"
#import "PBPlacesActivity.h"
#import "TodoMusicCell.h"
#import "TodoPlacesCell.h"
#import "Constants.h"
#import "PBMusicFeedback.h"
#import "PBVideosFeedback.h"
#import "PBPlacesFeedback.h"
#import "TodoVideosCell.h"
#import "PBVideosItem.h"
#import "PBVideosActivity.h"
#import "YouTubeView.h"

@interface TodoViewController ()

@property (nonatomic, strong) NSMutableArray *todos;
@property (nonatomic, strong) NSArray *todosToDisplay;
@property (nonatomic, strong) NSMutableDictionary* cachedPlacesPhotos;  // key is photoURL
@property (nonatomic, strong) NSMutableDictionary* cachedAlbumCovers;   // key is spotifyURL
@property (nonatomic, strong) NSMutableDictionary* cachedYoutubeWebViews; // key is videoURL
@property (nonatomic, strong) NSMutableDictionary* formattedAddresses;  // key is placeActivityId
@property BOOL isPlaying;
@property (nonatomic, strong) NSString* currentlyPlayingSpotifyURL;

@end

@implementation TodoViewController

@synthesize tableView = _tableView;
@synthesize todosToDisplay = _todosToDisplay;
@synthesize cachedAlbumCovers = _cachedAlbumCovers;
@synthesize cachedPlacesPhotos = _cachedPlacesPhotos;
@synthesize cachedYoutubeWebViews = _cachedYoutubeWebViews;
@synthesize formattedAddresses = _formattedAddresses;
@synthesize todos = _todos;
@synthesize isPlaying = _isPlaying;
@synthesize currentlyPlayingSpotifyURL = _currentlyPlayingSpotifyURL;

#pragma mark - Getters & Setters
-(NSMutableArray*)todos {
    if (!_todos) {
        _todos = [[NSMutableArray alloc] init];
    }
    return _todos;
}

- (void)setTodosToDisplay:(NSArray *)todosToDisplay {
    if (_todosToDisplay != todosToDisplay) {
        _todosToDisplay = todosToDisplay;
        [self.tableView reloadData];
    }
}

- (NSMutableDictionary*)cachedAlbumCovers {
    if (!_cachedAlbumCovers) {
        _cachedAlbumCovers = [[NSMutableDictionary alloc] init];
    }
    return _cachedAlbumCovers;
}

- (NSMutableDictionary*)cachedPlacesPhotos {
    if (!_cachedPlacesPhotos) {
        _cachedPlacesPhotos = [[NSMutableDictionary alloc] init];
    }
    return _cachedPlacesPhotos;
}

- (NSMutableDictionary*)formattedAddresses {
    if (!_formattedAddresses) {
        _formattedAddresses = [[NSMutableDictionary alloc] init];
    }
    return _formattedAddresses;
}

- (NSMutableDictionary*)cachedYoutubeWebViews {
    if (!_cachedYoutubeWebViews) {
        _cachedYoutubeWebViews = [[NSMutableDictionary alloc] init];
    }
    return _cachedYoutubeWebViews;
}

#pragma mark - Private helper methods
- (void)loadObjectsFromDataStore {
    // get todos
    NSPredicate *musicTodoPredicate = [NSPredicate predicateWithFormat:@"musicFeedbackType = %@",@"todo"];
    NSPredicate *placesTodoPredicate = [NSPredicate predicateWithFormat:@"placesFeedbackType = %@",@"todo"];
    NSPredicate *videosTodoPredicate = [NSPredicate predicateWithFormat:@"videosFeedbackType = %@",@"todo"];
    self.todos = [NSMutableArray arrayWithArray:[PBMusicFeedback objectsWithPredicate:musicTodoPredicate]];
    [self.todos addObjectsFromArray:[PBPlacesFeedback objectsWithPredicate:placesTodoPredicate]];
    [self.todos addObjectsFromArray:[PBVideosFeedback objectsWithPredicate:videosTodoPredicate]];
    
    // sort todos with most recent at top
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.todos sortedArrayUsingDescriptors:sortDescriptors];
    self.todos = [sortedArray mutableCopy];

    // display todos
    self.todosToDisplay = self.todos;
    [self.tableView reloadData];
}

-(void)cacheImages {
    dispatch_queue_t cacheImagesQueue = dispatch_queue_create("cacheImagesQueue",NULL);
    dispatch_async(cacheImagesQueue, ^{
        for (id todo in self.todos) {
            
            // cache cover albums
            if ([todo isKindOfClass:[PBMusicFeedback class]]) {
                PBMusicFeedback *musicTodo = todo;
                NSString* spotifyURL = musicTodo.musicActivity.musicItem.spotifyUrl;
                [[SPSession sharedSession] trackForURL:[NSURL URLWithString:spotifyURL] callback:^(SPTrack *track) {
                    if (track != nil) {
                        [SPAsyncLoading waitUntilLoaded:track timeout:10.0f then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                            [self.cachedAlbumCovers setObject:track.album.cover forKey:spotifyURL];
                            [track.album.cover startLoading];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                            });
                        }];
                    }
                }];
            }
            
            // cache foursquare vendor photos
            else if ([todo isKindOfClass:[PBPlacesFeedback class]]) {
                PBPlacesFeedback *placesTodo = todo;
                NSString* photoURL = placesTodo.placesActivity.placesItem.photoURL;
                if(photoURL) {
                    UIImage* placesImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
                    [self.cachedPlacesPhotos setObject:placesImage forKey:photoURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
            }
            
            else if ([todo isKindOfClass:[PBVideosFeedback class]]) {
                PBVideosFeedback *videosTodo = todo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    YouTubeView* videoWebView = [[YouTubeView alloc] initWithStringAsURL:videosTodo.videosActivity.videosItem.videoURL frame:CGRectMake(5,4,51,51)];
                    [self.cachedYoutubeWebViews setObject:videoWebView forKey:videosTodo.videosActivity.videosItem.videoURL];
                    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
                });
                
            }
        }
    });
}

-(void)formatAddresses {
    dispatch_queue_t formattedAddressesQueue = dispatch_queue_create("formattedAddressesQueue",NULL);
    dispatch_async(formattedAddressesQueue, ^{
        for (id todo in self.todos) {
            if ([todo isKindOfClass:[PBPlacesFeedback class]]) {
                PBPlacesFeedback* placesTodo = todo;
                NSString* addr = placesTodo.placesActivity.placesItem.addr;
                NSString* addrCity = placesTodo.placesActivity.placesItem.addrCity;
                NSString* addrState = placesTodo.placesActivity.placesItem.addrState;
                
                NSMutableString* formattedAddress = [[NSMutableString alloc] init];
                if ([addr length] != 0 || [addrCity length] != 0 || [addrState length] != 0)  {
                    formattedAddress = [[NSMutableString alloc] init];
                    if ([addr length])
                        [formattedAddress appendFormat:@"%@", addr];
                    if ([addr length] && ([addrCity length] || [addrState length])) {
                        [formattedAddress appendFormat:@", "];
                    }
                    if ([addrCity length] || [addrState length]) {
                        if ([addrCity length]) {
                            [formattedAddress appendFormat:@"%@",addrCity];
                            if ([addrState length]) {
                                [formattedAddress appendFormat:@", %@",addrState];
                            }
                        } else {
                            [formattedAddress appendFormat:@"%@",addrState];
                        }
                    }
                }
                [self.formattedAddresses setObject:formattedAddress forKey:placesTodo.placesActivityId];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
            [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
        });
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

#pragma mark - play song notification callback

-(void)playTrack:(NSNotification*)notification {
    // start new song
    if (![self.currentlyPlayingSpotifyURL isEqualToString:[[notification userInfo] objectForKey:@"spotifyURL"]]) {
        NSLog(@"start new song");
        self.currentlyPlayingSpotifyURL = [[notification userInfo] objectForKey:@"spotifyURL"];
        self.isPlaying = YES;
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // pause current song
    else if ([self.currentlyPlayingSpotifyURL isEqualToString:[[notification userInfo] objectForKey:@"spotifyURL"]] && self.isPlaying) {
        NSLog(@"pause current song");
        self.isPlaying = NO;
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // resume current song
    else if ([self.currentlyPlayingSpotifyURL isEqualToString:[[notification userInfo] objectForKey:@"spotifyURL"]] && !self.isPlaying) {
        NSLog(@"resume current song");
        self.isPlaying = YES;
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - segmented control delegate

-(void)changeSegment:(id)sender {
    
    NSMutableArray* selectedTodos = [[NSMutableArray alloc] init];
    
    // all
    if ([sender selectedSegmentIndex] == 0) {
        selectedTodos = self.todos;
    }
    
    // music
    else if ([sender selectedSegmentIndex] == 1) {
        for (id todo in self.todos) {
            if ([todo isKindOfClass:[PBMusicFeedback class]]) {
                [selectedTodos addObject:todo];
            }
        }
    }
    
    // places
    else if ([sender selectedSegmentIndex] == 2) {
        for (id todo in self.todos) {
            if ([todo isKindOfClass:[PBPlacesFeedback class]]) {
                [selectedTodos addObject:todo];
            }
        }
    }
    
    else if ([sender selectedSegmentIndex] == 3) {
        for (id todo in self.todos) {
            if ([todo isKindOfClass:[PBVideosFeedback class]]) {
                [selectedTodos addObject:todo];
            }
        }
    }
    
    self.todosToDisplay = selectedTodos;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.todosToDisplay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // music
    if ([[self.todosToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBMusicFeedback class]]) {
        static NSString *CellIdentifier = @"todoMusicTableCell";
        TodoMusicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        PBMusicFeedback *feedback = [self.todosToDisplay objectAtIndex:indexPath.row];
        PBMusicActivity* musicActivity = feedback.musicActivity;
        
        cell.songTitle.text = musicActivity.musicItem.songTitle;
        cell.songArtist.text = musicActivity.musicItem.artistName;
        cell.date.text = [self timeElapsed:feedback.dateAdded];
        cell.coverImage.image = [(SPImage*)[self.cachedAlbumCovers objectForKey:musicActivity.musicItem.spotifyUrl] image];
        cell.spotifyURL = musicActivity.musicItem.spotifyUrl;

        if ([cell.spotifyURL isEqualToString:self.currentlyPlayingSpotifyURL] && self.isPlaying) {
            cell.playButton.imageView.image = [UIImage imageNamed:@"pause-button"];
        } else {
            cell.playButton.imageView.image = [UIImage imageNamed:@"play-button"];
        }
        
        return cell;
    }

    // places
    else if ([[self.todosToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesFeedback class]]) {
        static NSString *CellIdentifier = @"todoPlacesTableCell";
        TodoPlacesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        PBPlacesFeedback *feedback = [self.todosToDisplay objectAtIndex:indexPath.row];
        PBPlacesActivity* placesActivity = feedback.placesActivity;
        
        cell.vendorName.text = placesActivity.placesItem.name;
        cell.vendorAddress.text = [self.formattedAddresses objectForKey:placesActivity.placesActivityId];
        cell.date.text = [self timeElapsed:feedback.dateAdded];
        cell.vendorImage.image = [self.cachedPlacesPhotos objectForKey:placesActivity.placesItem.photoURL];
        cell.phone.text = placesActivity.placesItem.phone;
        
        return cell;
    }
    
    // videos
    else if ([[self.todosToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBVideosFeedback class]]) {
        static NSString *CellIdentifier = @"todoVideosTableCell";
        TodoVideosCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        PBVideosFeedback *feedback = [self.todosToDisplay objectAtIndex:indexPath.row];
        PBVideosActivity* videosActivity = feedback.videosActivity;
        
        // set name of video and top align
        cell.videoName.text = videosActivity.videosItem.name;
        
        cell.date.text = [self timeElapsed:feedback.dateAdded];
        
        YouTubeView* videoWebView = [self.cachedYoutubeWebViews objectForKey:videosActivity.videosItem.videoURL];
        [cell.contentView addSubview:videoWebView];
        
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return TODOTABLEROWHEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)viewDidAppear:(BOOL)animated {
    // cache images
    [self cacheImages];
    
    // cache formatted addresses
    [self formatAddresses];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register for notifications from music cell play button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playTrack:) name:@"clickPlayMusic" object:nil];
    
    // create segmented control to select type of media to view
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"All",
                                             [UIImage imageNamed:@"filter-music"],
                                             [UIImage imageNamed:@"filter-places"],
                                             [UIImage imageNamed:@"filter-videos"],
                                             nil]];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(changeSegment:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setFrame:CGRectMake(self.navigationController.toolbar.frame.origin.x, self.navigationController.toolbar.frame.origin.y, 150, 34)];
    
    self.navigationController.navigationBar.topItem.titleView = segmentedControl;}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjectsFromDataStore];
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
