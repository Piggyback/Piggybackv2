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
#import <CoreText/CoreText.h>
#import "PBTextLayer.h"

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
    self.newsToDisplay = [[PBMusicNews allObjects] mutableCopy];
    [self.newsToDisplay addObjectsFromArray:[PBPlacesNews allObjects]];
    [self.newsToDisplay addObjectsFromArray:[PBVideosNews allObjects]];
    NSLog(@"news to display is %@",self.newsToDisplay);
    
    // sort news with most recent at top
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.newsToDisplay sortedArrayUsingDescriptors:sortDescriptors];
    self.newsToDisplay = [sortedArray mutableCopy];
    
    [self.tableView reloadData];

    // load profile pic thumbnails into core data if they are not yet
    for (id news in self.newsToDisplay) {
        if ([news isKindOfClass:[PBMusicNews class]]) {
            PBMusicNews *musicNews = news;
            if(!musicNews.follower.thumbnail) {
                NSLog(@"music thumbnail");
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",musicNews.follower.fbId];
                musicNews.follower.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
//                [[RKObjectManager sharedManager].objectStore save:nil];
            }
        } else if ([news isKindOfClass:[PBPlacesNews class]]) {
            PBPlacesNews *placesNews = news;
            if(!placesNews.follower.thumbnail) {
                NSLog(@"places thumbnail");
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",placesNews.follower.fbId];
                placesNews.follower.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
//                [[RKObjectManager sharedManager].objectStore save:nil];
            }
        } else if ([news isKindOfClass:[PBVideosNews class]]) {
            PBVideosNews *videosNews = news;
            if(!videosNews.follower.thumbnail) {
                NSLog(@"videos thumbnail");
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",videosNews.follower.fbId];
                videosNews.follower.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
//                [[RKObjectManager sharedManager].objectStore save:nil];
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
    RKObjectMapping *musicResponseMapping = (RKObjectMapping*)[objManager.mappingProvider mappingForKeyPath:@"PBMusicActivity"];
    musicResponseMapping.rootKeyPath = @"PBMusicActivity";
    RKObjectMapping *placesResponseMapping = (RKObjectMapping*)[objManager.mappingProvider mappingForKeyPath:@"PBPlacesActivity"];
    placesResponseMapping.rootKeyPath = @"PBPlacesActivity";
    RKObjectMapping *videosResponseMapping = (RKObjectMapping*)[objManager.mappingProvider mappingForKeyPath:@"PBVideosActivity"];
    videosResponseMapping.rootKeyPath = @"PBVideosActivity";
    NSDictionary *newsParam = [NSDictionary dictionaryWithKeysAndObjects:@"uid", [NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] intValue]], nil];
    
    [objManager loadObjectsAtResourcePath:[@"/musicNews" stringByAppendingQueryParameters:newsParam] usingBlock:^(RKObjectLoader *loader) {
        loader.serializationMIMEType = RKMIMETypeJSON;
        loader.delegate = self;
        loader.objectMapping = musicResponseMapping;
    }];
    
    [objManager loadObjectsAtResourcePath:[@"/placesNews" stringByAppendingQueryParameters:newsParam] usingBlock:^(RKObjectLoader *loader) {
        loader.serializationMIMEType = RKMIMETypeJSON;
        loader.delegate = self;
        loader.objectMapping = placesResponseMapping;
    }];
    
    [objManager loadObjectsAtResourcePath:[@"/videosNews" stringByAppendingQueryParameters:newsParam] usingBlock:^(RKObjectLoader *loader) {
        loader.serializationMIMEType = RKMIMETypeJSON;
        loader.delegate = self;
        loader.objectMapping = videosResponseMapping;
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
    
    NSString *piggybacker;
    NSString *actionAndItem;
    NSString *newsText;
    
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
        
//        cell.newsText.text = [NSString stringWithFormat:@"%@%@ %@ your song \"%@\"", follower.firstName, lastInitial, action, newsItem.musicActivity.musicItem.songTitle];
        cell.date.text = [self timeElapsed:newsItem.dateAdded];
        
        piggybacker = [NSString stringWithFormat:@"%@%@", follower.firstName, lastInitial];
        actionAndItem = [NSString stringWithFormat:@"%@ your song \"%@\"", action, newsItem.musicActivity.musicItem.songTitle];
        newsText = [NSString stringWithFormat:@"%@ %@", piggybacker, actionAndItem];
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
        
//        cell.newsText.text = [NSString stringWithFormat:@"%@%@ %@ your check-in at \"%@\"", follower.firstName, lastInitial, action, newsItem.placesActivity.placesItem.name];
        cell.date.text = [self timeElapsed:newsItem.dateAdded];
        
        piggybacker = [NSString stringWithFormat:@"%@%@", follower.firstName, lastInitial];
        actionAndItem = [NSString stringWithFormat:@"%@ your check-in at \"%@\"", action, newsItem.placesActivity.placesItem.name];
        newsText = [NSString stringWithFormat:@"%@ %@", piggybacker, actionAndItem];
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
        
//        cell.newsText.text = [NSString stringWithFormat:@"%@%@ %@ your video \"%@\"", follower.firstName, lastInitial, action, newsItem.videosActivity.videosItem.name];
        cell.date.text = [self timeElapsed:newsItem.dateAdded];
        
        piggybacker = [NSString stringWithFormat:@"%@%@", follower.firstName, lastInitial];
        actionAndItem = [NSString stringWithFormat:@"%@ your video \"%@\"", action, newsItem.videosActivity.videosItem.name];
        newsText = [NSString stringWithFormat:@"%@ %@", piggybacker, actionAndItem];
    }
    
    PBTextLayer *newsTextLayer = [[PBTextLayer alloc] init];
    newsTextLayer.wrapped = YES;
    CALayer *cellLayer = cell.contentView.layer;
    newsTextLayer.contentsScale = [[UIScreen mainScreen] scale];
    
    UIFont *boldFont = [UIFont boldSystemFontOfSize:13];
    CTFontRef ctBoldFont = CTFontCreateWithName((__bridge CFStringRef)(boldFont.fontName), boldFont.pointSize, NULL);
    UIFont *font = [UIFont systemFontOfSize:13];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize, NULL);
    CGColorRef cgColor = [UIColor colorWithRed:0 green:104/255.0f blue:204/255.0f alpha:1].CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:CFBridgingRelease(ctBoldFont), kCTFontAttributeName, cgColor, kCTForegroundColorAttributeName, nil];
    //        CFRelease(ctBoldFont);
    CGColorRef cgSubColor = [UIColor blackColor].CGColor;
    NSDictionary *subAttributes = [NSDictionary dictionaryWithObjectsAndKeys:CFBridgingRelease(ctFont), kCTFontAttributeName, cgSubColor, kCTForegroundColorAttributeName, nil];
    //        CFRelease(ctFont);
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:newsText attributes:attributes];
    [attrStr addAttributes:subAttributes range:NSMakeRange(piggybacker.length, actionAndItem.length+1)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrStr);
    CGSize labelSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(220.0f, CGFLOAT_MAX), NULL);
    newsTextLayer.frame = CGRectMake(53.0f, 10.0f, 220.0f, labelSize.height);
    
    [cellLayer addSublayer:newsTextLayer];
    newsTextLayer.string = attrStr;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString *piggybacker;
    NSString *actionAndItem;
    NSString *newsText;
    
    if ([[self.newsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBMusicNews class]]) {
        PBMusicNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
        PBUser* follower = newsItem.follower;
        NSString *lastInitial;
        
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
        
        piggybacker = [NSString stringWithFormat:@"%@%@", follower.firstName, lastInitial];
        actionAndItem = [NSString stringWithFormat:@"%@ your song \"%@\"", action, newsItem.musicActivity.musicItem.songTitle];
        newsText = [NSString stringWithFormat:@"%@ %@", piggybacker, actionAndItem];
    } else if ([[self.newsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBPlacesNews class]]) {
        PBPlacesNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
        PBUser* follower = newsItem.follower;
        NSString *lastInitial;
        
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
        
        piggybacker = [NSString stringWithFormat:@"%@%@", follower.firstName, lastInitial];
        actionAndItem = [NSString stringWithFormat:@"%@ your check-in at \"%@\"", action, newsItem.placesActivity.placesItem.name];
        newsText = [NSString stringWithFormat:@"%@ %@", piggybacker, actionAndItem];
        
    } else if ([[self.newsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[PBVideosNews class]]) {
        PBVideosNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
        PBUser* follower = newsItem.follower;
        NSString *lastInitial;
        
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
        
        piggybacker = [NSString stringWithFormat:@"%@%@", follower.firstName, lastInitial];
        actionAndItem = [NSString stringWithFormat:@"%@ your video \"%@\"", action, newsItem.videosActivity.videosItem.name];
        newsText = [NSString stringWithFormat:@"%@ %@", piggybacker, actionAndItem];
    }
    
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    CTFontRef ctBoldFont = CTFontCreateWithName((__bridge CFStringRef)(boldFont.fontName), boldFont.pointSize, NULL);
    UIFont *font = [UIFont systemFontOfSize:13];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize, NULL);
    CGColorRef cgColor = [UIColor purpleColor].CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:CFBridgingRelease(ctBoldFont), kCTFontAttributeName, cgColor, kCTForegroundColorAttributeName, nil];
    //        CFRelease(ctBoldFont);
    CGColorRef cgSubColor = [UIColor blackColor].CGColor;
    NSDictionary *subAttributes = [NSDictionary dictionaryWithObjectsAndKeys:CFBridgingRelease(ctFont), kCTFontAttributeName, cgSubColor, kCTForegroundColorAttributeName, nil];
    //        CFRelease(ctFont);
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:newsText attributes:attributes];
    [attrStr addAttributes:subAttributes range:NSMakeRange(piggybacker.length, actionAndItem.length+1)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrStr);
    CGSize labelSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(220.0f, CGFLOAT_MAX), NULL);
    
    if ((labelSize.height + 5) <= NEWSTABLEROWHEIGHT)
        return NEWSTABLEROWHEIGHT;
    
    return labelSize.height + 5;
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
