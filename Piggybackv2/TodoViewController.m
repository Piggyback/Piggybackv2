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

@interface TodoViewController ()

@property (nonatomic, strong) NSMutableArray *todos;
@property (nonatomic, strong) NSArray *todosToDisplay;
@property (nonatomic, strong) NSMutableDictionary* cachedPlacesPhotos;  // key is photoURL
@property (nonatomic, strong) NSMutableDictionary* cachedAlbumCovers;   // key is spotifyURL
@property (nonatomic, strong) NSMutableDictionary* formattedAddresses;  // key is placeActivityId

@end

@implementation TodoViewController

@synthesize tableView = _tableView;
@synthesize todosToDisplay = _todosToDisplay;
@synthesize cachedAlbumCovers = _cachedAlbumCovers;
@synthesize cachedPlacesPhotos = _cachedPlacesPhotos;
@synthesize formattedAddresses = _formattedAddresses;
@synthesize todos = _todos;

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

#pragma mark - Private helper methods
- (void)loadObjectsFromDataStore {
    self.todos = [NSMutableArray arrayWithArray:[PBMusicFeedback allObjects]];
    [self.todos addObjectsFromArray:[PBPlacesFeedback allObjects]];
    self.todosToDisplay = self.todos;
    [self.tableView reloadData];
    
//    NSFetchRequest* request = [PBMusicTodo fetchRequest];
    //    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"referralDate" ascending:NO];
    //    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
}

-(void)cacheImages {
    dispatch_queue_t cacheImagesQueue = dispatch_queue_create("cacheImagesQueue",NULL);
    dispatch_async(cacheImagesQueue, ^{
        for (id feedback in self.todos) {
            
            // cache cover albums
            if ([feedback isKindOfClass:[PBMusicFeedback class]]) {
                PBMusicFeedback *musicFeedback = feedback;
                NSString* spotifyURL = musicFeedback.musicActivity.musicItem.spotifyUrl;
                [[SPSession sharedSession] trackForURL:[NSURL URLWithString:spotifyURL] callback:^(SPTrack *track) {
                    if (track != nil) {
                        [SPAsyncLoading waitUntilLoaded:track timeout:10.0f then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                            [self.cachedAlbumCovers setObject:track.album.cover forKey:spotifyURL];
                            [track.album.cover startLoading];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
//                              [self.tableView reloadRowsAtIndexPaths:[self.tableView visibleCells] withRowAnimation:UITableViewRowAnimationNone];
                            });
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadImage" object:nil userInfo:[NSDictionary dictionaryWithObject:spotifyURL forKey:@"spotifyURL"]];
                        }];
                    }
                }];
            }
            
            // cache foursquare vendor photos
            else if ([feedback isKindOfClass:[PBPlacesFeedback class]]) {
                PBPlacesFeedback *placesFeedback = feedback;
                NSString* photoURL = placesFeedback.placesActivity.placesItem.photoURL;
                if(photoURL) {
                    UIImage* placesImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
                    [self.cachedPlacesPhotos setObject:placesImage forKey:photoURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
//                        [self.tableView reloadRowsAtIndexPaths:[self.tableView visibleCells] withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
            }
        }
    });
}

-(void)formatAddresses {
    dispatch_queue_t formattedAddressesQueue = dispatch_queue_create("formattedAddressesQueue",NULL);
    dispatch_async(formattedAddressesQueue, ^{
        for (id feedback in self.todos) {
            if ([feedback isKindOfClass:[PBPlacesFeedback class]]) {
                PBPlacesFeedback* placesFeedback = feedback;
                NSString* addr = placesFeedback.placesActivity.placesItem.addr;
                NSString* addrCity = placesFeedback.placesActivity.placesItem.addrCity;
                NSString* addrState = placesFeedback.placesActivity.placesItem.addrState;
                
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
                [self.formattedAddresses setObject:formattedAddress forKey:placesFeedback.placesActivityId];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
//            [self.tableView reloadRowsAtIndexPaths:[self.tableView visibleCells] withRowAnimation:UITableViewRowAnimationNone];
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
        //        for (id item in self.items) {
        //            if ([item isKindOfClass:[PBVideosActivity class]]) {
        //                [selectedItems addObject:item];
        //            }
        //        }
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
    
    // set up playback manager
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    
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
