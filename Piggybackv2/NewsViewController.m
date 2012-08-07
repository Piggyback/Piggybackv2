//
//  NewsViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 7/19/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "NewsViewController.h"
#import "PBMusicNews.h"
#import "PBPlacesNews.h"
#import "PBVideosNews.h"
#import "PBUser.h"
#import "PBMusicActivity.h"
#import "PBPlacesActivity.h"
#import "PBPlacesItem.h"
#import "PBVideosActivity.h"
#import "PBVideosItem.h"
#import "PBMusicItem.h"
#import "Constants.h"
#import "NewsCell.h"
#import <QuartzCore/QuartzCore.h>

@interface NewsViewController ()

@property (nonatomic, strong) NSMutableArray *newsToDisplay;

@end

@implementation NewsViewController

@synthesize tableView;
@synthesize newsToDisplay = _newsToDisplay;

#pragma mark - Getters & Setters
-(NSMutableArray*)newsToDisplay {
    if (!_newsToDisplay) {
        _newsToDisplay = [[NSMutableArray alloc] init];
    }
    return _newsToDisplay;
}

#pragma mark - Private helper methods
- (void)loadObjectsFromDataStore {
    [self.newsToDisplay addObjectsFromArray:[PBMusicNews allObjects]];
    [self.newsToDisplay addObjectsFromArray:[PBPlacesNews allObjects]];
    [self.newsToDisplay addObjectsFromArray:[PBVideosNews allObjects]];

    // sort news with most recent at top
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.newsToDisplay sortedArrayUsingDescriptors:sortDescriptors];
    self.newsToDisplay = [sortedArray mutableCopy];
    
    // load profile pic thumbnails into core data if they are not yet
    for (id news in self.newsToDisplay) {
        if ([news isKindOfClass:[PBMusicNews class]]) {
            PBMusicNews *musicNews = news;
            if(!musicNews.follower.thumbnail) {
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",musicNews.follower.fbId];
                musicNews.follower.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
                [[RKObjectManager sharedManager].objectStore save:nil];
            }
        } else if ([news isKindOfClass:[PBPlacesNews class]]) {
            PBPlacesNews *placesNews = news;
            if(!placesNews.follower.thumbnail) {
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",placesNews.follower.fbId];
                placesNews.follower.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
                [[RKObjectManager sharedManager].objectStore save:nil];
            }
        } else if ([news isKindOfClass:[PBVideosNews class]]) {
            PBVideosNews *videosNews = news;
            if(!videosNews.follower.thumbnail) {
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",videosNews.follower.fbId];
                videosNews.follower.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
                [[RKObjectManager sharedManager].objectStore save:nil];
            }
        }
    }
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

- (void)loadData {
    // load the object model via RestKit
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectMapping *responseMapping = (RKObjectMapping*)[objManager.mappingProvider mappingForKeyPath:@"PBMusicActivity"];
    NSDictionary *newsParam = [NSDictionary dictionaryWithKeysAndObjects:@"uid", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], nil];
    
    [objManager loadObjectsAtResourcePath:[@"/news" stringByAppendingQueryParameters:newsParam] usingBlock:^(RKObjectLoader *loader) {
        loader.serializationMIMEType = RKMIMETypeJSON;
        loader.delegate = self;
        responseMapping.rootKeyPath = @"PBMusicActivity";
        loader.objectMapping = responseMapping;
    }];
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"objects from news feed are %@",objects);
    [self loadObjectsFromDataStore];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"restkit failed with error from getting news feed");
}

//- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
//    NSLog(@"Retrieved JSON2: %@", [response bodyAsString]);
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.newsToDisplay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newsTableCell";
    NewsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([[self.newsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBMusicNews class]]) {
        PBMusicNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
        PBUser* follower = newsItem.follower;
        
        cell.profilePic.image = follower.thumbnail;
        
        NSString* lastInitial;
        if (follower.lastName) {
            lastInitial = [NSString stringWithFormat:@" %@.",[follower.lastName substringToIndex:1]];
        } else {
            lastInitial = @"";
        }
        
        NSString* action;
        if ([newsItem.newsActionType isEqualToString:@"todo"]) {
            action = @"saved";
        } else if ([newsItem.newsActionType isEqualToString:@"like"]) {
            action = @"liked";
        }
        
        cell.newsText.text = [NSString stringWithFormat:@"%@%@ %@ your song \"%@\"", follower.firstName, lastInitial, action, newsItem.musicActivity.musicItem.songTitle];
        cell.date.text = [self timeElapsed:newsItem.dateAdded];
    }
    
    else if ([[self.newsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesNews class]]) {
        PBPlacesNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
        PBUser* follower = newsItem.follower;
        
        cell.profilePic.image = follower.thumbnail;
        
        NSString* lastInitial;
        if (follower.lastName) {
            lastInitial = [NSString stringWithFormat:@" %@.",[follower.lastName substringToIndex:1]];
        } else {
            lastInitial = @"";
        }
        
        NSString* action;
        if ([newsItem.newsActionType isEqualToString:@"todo"]) {
            action = @"saved";
        } else if ([newsItem.newsActionType isEqualToString:@"like"]) {
            action = @"liked";
        }
        
        cell.newsText.text = [NSString stringWithFormat:@"%@%@ %@ a place you went to \"%@\"", follower.firstName, lastInitial, action, newsItem.placesActivity.placesItem.name];
        cell.date.text = [self timeElapsed:newsItem.dateAdded];
    }
    
    else if ([[self.newsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBVideosNews class]]) {
        PBVideosNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
        PBUser* follower = newsItem.follower;
        
        cell.profilePic.image = follower.thumbnail;
        
        NSString* lastInitial;
        if (follower.lastName) {
            lastInitial = [NSString stringWithFormat:@" %@.",[follower.lastName substringToIndex:1]];
        } else {
            lastInitial = @"";
        }
        
        NSString* action;
        if ([newsItem.newsActionType isEqualToString:@"todo"]) {
            action = @"saved";
        } else if ([newsItem.newsActionType isEqualToString:@"like"]) {
            action = @"liked";
        }
        
        cell.newsText.text = [NSString stringWithFormat:@"%@%@ %@ a place you went to \"%@\"", follower.firstName, lastInitial, action, newsItem.videosActivity.videosItem.name];
        cell.date.text = [self timeElapsed:newsItem.dateAdded];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return NEWSTABLEROWHEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
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
