//
//  YouTubeTableViewController.m
//  Ambassadors
//
//  Created by Kimberly Hsiao on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YouTubeTableViewController.h"
#import "YouTubeCell.h"
#import "Constants.h"

@interface YouTubeTableViewController ()

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) NSMutableSet *hashToUserID;
@property (nonatomic, strong) NSMutableDictionary* currentConnections;

@end

@implementation YouTubeTableViewController

@synthesize videoList = _videoList;
@synthesize hashToUserID = _hashToUserID;

@synthesize currentConnections = _currentConnections;

#pragma mark - getters and setters

- (NSMutableArray*)videoList {
    if (!_videoList) {
        _videoList = [[NSMutableArray alloc] init];
    }
    return _videoList;
}

- (NSMutableSet*)hashToUserID {
    if (!_hashToUserID) {
        _hashToUserID = [[NSMutableSet alloc] init];
    }
    return _hashToUserID;
}

- (NSMutableDictionary*)currentConnections {
    if (!_currentConnections) {
        _currentConnections = [[NSMutableDictionary alloc] init];
    }
    return _currentConnections;
}

#pragma mark - private helper functions

// get favorites from an ambassador
//- (void)getFavoritesFromAmbassador:(NSString*)uid {
//    NSString *youtubeFavsQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/%@/favorites?v=2&alt=json",uid];
//    
//    NSURLRequest *youtubeFavsRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:youtubeFavsQuery]];
//    NSURLConnection *youtubeFavsConnection = [[NSURLConnection alloc] initWithRequest:youtubeFavsRequest delegate:self];
//    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
//    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
//    [connectionInfo setObject:@"favorites" forKey:@"userInfo"];
//    [self.currentConnections setObject:connectionInfo forKey:youtubeFavsConnection.description];
//}

- (void)getFavoritesFromAmbassadors:(NSMutableSet*)users {
    NSString* userNames = @"";
    for (NSString* user in users) {
        userNames = [NSString stringWithFormat:@"%@,%@",userNames,user];
    }
    
    if (![userNames isEqualToString:@""]) {
        userNames = [userNames substringWithRange:NSMakeRange(1,[userNames length]-1)];
    }
    
    NSLog(@"user names is %@",userNames);
    
    NSString* newVideosQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/events?v=2&author=%@&key=AI39si67YD40HCVtvnAj--EzmTmuFjZCzIYHskBFuRa6jf1KWkbSK_3TpQDLRIJfcNeT4UiGB1eLWz6KjUN3SPn02feOfLt19w&alt=json",userNames];
    
    NSURLRequest *newVideosRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newVideosQuery]];
    NSURLConnection *newVideosConnection = [[NSURLConnection alloc] initWithRequest:newVideosRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"initialFavorites" forKey:@"userInfo"];
    [self.currentConnections setObject:connectionInfo forKey:newVideosConnection.description];
}

- (void)getInfoForInitialVideo:(NSString*)videoID forUser:(NSString*)uid forDate:(NSString*)date forActivity:(NSString*)activity {
    NSString *videoInfoQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=json",videoID];
    NSURLRequest *videoInfoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:videoInfoQuery]];
    NSURLConnection *videoInfoConnection = [[NSURLConnection alloc] initWithRequest:videoInfoRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"initialVideoInfo" forKey:@"userInfo"];
    [connectionInfo setObject:uid forKey:@"uid"];
    [connectionInfo setObject:date forKey:@"date"];
    [connectionInfo setObject:activity forKey:@"activity"];
    [self.currentConnections setObject:connectionInfo forKey:videoInfoConnection.description];
}

// get my hash value upon first login
- (void)getMyActivityStreamHash {
    NSString* myUID = @"kimikul";
    NSString *youtubeActivityFeedQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/%@/events?v=2&key=AI39si67YD40HCVtvnAj--EzmTmuFjZCzIYHskBFuRa6jf1KWkbSK_3TpQDLRIJfcNeT4UiGB1eLWz6KjUN3SPn02feOfLt19w&alt=json",myUID];
    
    NSURLRequest *youtubeActivityFeedRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:youtubeActivityFeedQuery]];
    NSURLConnection *youtubeActivityFeedConnection = [[NSURLConnection alloc] initWithRequest:youtubeActivityFeedRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"myHash" forKey:@"userInfo"];
    [self.currentConnections setObject:connectionInfo forKey:youtubeActivityFeedConnection.description];
}

// get sup stream to see recent youtube updates
- (void)getSupStream {
    NSString* supQuery = @"http://gdata.youtube.com/sup";
    NSURLRequest* newSupRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:supQuery]];
    NSURLConnection* newSupConnection = [[NSURLConnection alloc] initWithRequest:newSupRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"sup" forKey:@"userInfo"];
    [self.currentConnections setObject:connectionInfo forKey:newSupConnection.description];
}

// pull videos from ambassadors who have youtube activity since the previous sup update
- (void)pullNewVideosFromUsers:(NSMutableSet*)users {
    NSString* userNames = @"";
    for (NSDictionary* user in users) {
        userNames = [NSString stringWithFormat:@"%@,%@",userNames,[[user allValues] objectAtIndex:0]];
    }
    
    if (![userNames isEqualToString:@""]) {
        userNames = [userNames substringWithRange:NSMakeRange(1,[userNames length]-1)];
    }
    
    NSLog(@"user names is %@",userNames);
    
    NSString* newVideosQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/events?v=2&author=%@&key=AI39si67YD40HCVtvnAj--EzmTmuFjZCzIYHskBFuRa6jf1KWkbSK_3TpQDLRIJfcNeT4UiGB1eLWz6KjUN3SPn02feOfLt19w&alt=json",userNames];
        
    NSURLRequest *newVideosRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newVideosQuery]];
    NSURLConnection *newVideosConnection = [[NSURLConnection alloc] initWithRequest:newVideosRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"newFavorites" forKey:@"userInfo"];
    [self.currentConnections setObject:connectionInfo forKey:newVideosConnection.description];
}

- (void)getInfoForNewVideo:(NSString*)videoID {
    NSString *videoInfoQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=json",videoID];
    NSURLRequest *videoInfoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:videoInfoQuery]];
    NSURLConnection *videoInfoConnection = [[NSURLConnection alloc] initWithRequest:videoInfoRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"newFavVideoInfo" forKey:@"userInfo"];
    [self.currentConnections setObject:connectionInfo forKey:videoInfoConnection.description];
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
    // check if unit number is greater then append s at the end
    //    if (number > 1) {
    //        unit = [NSString stringWithFormat:@"%@s", unit];
    //    }
    
    NSString* elapsedTime = [NSString stringWithFormat:@"%d%@",number,unit];
    
    if (number == 0) {
        elapsedTime = @"1sec";
    }
    
    return elapsedTime;
}

#pragma mark - nsurlconnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    for (NSString* currentConnection in [self.currentConnections allKeys]) {
        if ([connection.description isEqualToString:currentConnection]) {
            [[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] setLength:0];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    for (NSString* currentConnection in [self.currentConnections allKeys]) {
        if ([connection.description isEqualToString:currentConnection]) {
            [[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] appendData:data];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    for (NSString* currentConnection in [self.currentConnections allKeys]) {
        if ([connection.description isEqualToString:currentConnection]) {
            NSLog(@"Error with YouTube API");
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    for (NSString* currentConnection in [self.currentConnections allKeys]) {
        if ([connection.description isEqualToString:currentConnection]) {
            
            // get favorites from ambassadors
            if ([[[self.currentConnections objectForKey:currentConnection] objectForKey:@"userInfo"] isEqualToString:@"initialFavorites"]) {
                NSError *error = nil;
                NSDictionary *youtubeFavsDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                                        
                NSArray *videoArray = [[youtubeFavsDict objectForKey:@"feed"] objectForKey:@"entry"];
                for (NSDictionary* video in videoArray) {
                    
                    // add favorited to videos list
                    if ([[[video objectForKey:@"title"] objectForKey:@"$t"] rangeOfString:@"favorited"].location != NSNotFound) {
                        [self getInfoForInitialVideo:[[video objectForKey:@"yt$videoid"] objectForKey:@"$t"] 
                                              forUser:[[[[video objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"] 
                                              forDate:[[video objectForKey:@"updated"] objectForKey:@"$t"] 
                                          forActivity:@"favorited"];
                    } 
                    
                    // add liked to videos list
                    else if ([[[video objectForKey:@"title"] objectForKey:@"$t"] rangeOfString:@"rated"].location != NSNotFound) {
                        if ([[[video objectForKey:@"yt$rating"] objectForKey:@"value"] isEqualToString:@"like"]) {
                            [self getInfoForInitialVideo:[[video objectForKey:@"yt$videoid"] objectForKey:@"$t"] 
                                                 forUser:[[[[video objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"] 
                                                 forDate:[[video objectForKey:@"updated"] objectForKey:@"$t"] 
                                             forActivity:@"liked"];
                        }
                    }
                }
            } 

            // get info for initial favorited / liked videos
            else if ([[[self.currentConnections objectForKey:currentConnection] objectForKey:@"userInfo"] isEqualToString:@"initialVideoInfo"]) {
                NSError *error = nil;
                NSDictionary *youtubeVideoInfoDict = [[NSDictionary alloc] init];
                youtubeVideoInfoDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                
                // add one new video to video list
                NSDictionary *videoArray = [youtubeVideoInfoDict objectForKey:@"entry"];
                NSArray* videoTypesArray = [[videoArray objectForKey:@"media$group"] objectForKey:@"media$content"];
                for (NSDictionary* videoType in videoTypesArray) {
                    if ([[videoType objectForKey:@"type"] isEqualToString:@"application/x-shockwave-flash"]) {
                        NSMutableDictionary* videoInformation = [[NSMutableDictionary alloc] init];
                        [videoInformation setObject:[videoType objectForKey:@"url"] forKey:@"url"];
                        [videoInformation setObject:[[[videoArray objectForKey:@"media$group"] objectForKey:@"media$title"] objectForKey:@"$t"] forKey:@"name"];
                        [videoInformation setObject:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"uid"] forKey:@"uid"];
                        [videoInformation setObject:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"activity"] forKey:@"activity"];
                        
                        // convert date string to nsdate
                        NSString *formattedString = [[[self.currentConnections objectForKey:currentConnection] objectForKey:@"date"] stringByReplacingOccurrencesOfString:@"T" withString:@""];
                        formattedString = [formattedString stringByReplacingCharactersInRange:NSMakeRange(18, 5) withString:@""];
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                        NSDate *date = [df dateFromString: formattedString];
                        [videoInformation setObject:date forKey:@"date"];
                        [self.videoList addObject:videoInformation];
                        break;
                    }
                }
                
                self.videoList = [[self.videoList sortedArrayUsingComparator: ^(NSDictionary* a, NSDictionary* b) {
                    NSComparisonResult result = [[b objectForKey:@"date"] compare:[a objectForKey:@"date"]];
                    return result;
                }] mutableCopy];
                NSLog(@"video list is %@",self.videoList);
                [self.tableView reloadData];
            }
            
            // get my hash value
            else if ([[[self.currentConnections objectForKey:currentConnection] objectForKey:@"userInfo"] isEqualToString:@"myHash"]) {
                NSError *error = nil;
                NSDictionary *youtubeActivityFeedDict = [[NSDictionary alloc] init];
                youtubeActivityFeedDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                
                NSArray* updateHash = [[youtubeActivityFeedDict objectForKey:@"feed"] objectForKey:@"link"];
                for (NSDictionary* link in updateHash) {
                    if ([[link objectForKey:@"rel"] isEqualToString:@"updates"]) {
#warning - store hash, uid, name, etc in user db upon first login to youtube (uid, name will probably be stored in nsuserdefaults already, get hash here)
                        NSDictionary* hashToID = [NSDictionary dictionaryWithObject:@"kimikul" forKey:[[[link objectForKey:@"href"] componentsSeparatedByString:@"#"] objectAtIndex:1]];
                        [self.hashToUserID addObject:hashToID];
                        break;
                    }
                }
                NSLog(@"hash dictionary is %@",self.hashToUserID);
            }
            
            else if ([[[self.currentConnections objectForKey:currentConnection] objectForKey:@"userInfo"] isEqualToString:@"sup"]) {
                NSError *error = nil;
                NSDictionary *youtubeSupDict = [[NSDictionary alloc] init];
                youtubeSupDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                
                // see if any youtube updates are from your ambassadors
                NSMutableSet *usersWithNewVideos = [[NSMutableSet alloc] init];
                for (NSDictionary* user in [self.hashToUserID allObjects]) {
                    NSString* hash = [[user allKeys] objectAtIndex:0];
                    NSLog(@"my hash is %@",hash);
                    for (NSArray* update in [youtubeSupDict objectForKey:@"updates"]) {
                        if ([hash isEqualToString:[update objectAtIndex:0]]) {
                            [usersWithNewVideos addObject:user];
                            break;
                        }
                    }
                }
                
                // if your ambassadors have updated, get their newly favorited videos
                if ([usersWithNewVideos count] != 0) {
                    NSLog(@"users with new videos %@",usersWithNewVideos);
                    [self pullNewVideosFromUsers:usersWithNewVideos];
                }
            }
            
#warning - redo new favorites to use initial favorites code
            else if ([[[self.currentConnections objectForKey:currentConnection] objectForKey:@"userInfo"] isEqualToString:@"newFavorites"]) {
                NSError *error = nil;
                NSDictionary *youtubeNewVideosDict = [[NSDictionary alloc] init];
                youtubeNewVideosDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                
            
                NSLog(@"new favorited videos %@",youtubeNewVideosDict);
                // find newly favorited videos from your ambassadors and call the api to get more info on these videos
                NSDictionary *newEntries = [[youtubeNewVideosDict objectForKey:@"feed"] objectForKey:@"entry"];
                for (NSDictionary* newEntry in newEntries) {
                    if ([[[newEntry objectForKey:@"title"] objectForKey:@"$t"] rangeOfString:@"favorited"].location != NSNotFound) {
                        [self getInfoForNewVideo:[[newEntry objectForKey:@"yt$videoid"] objectForKey:@"$t"]];
                    }
                }
            }
            
            else if ([[[self.currentConnections objectForKey:currentConnection] objectForKey:@"userInfo"] isEqualToString:@"newFavVideoInfo"]) {
                NSError *error = nil;
                NSDictionary *youtubeVideoInfoDict = [[NSDictionary alloc] init];
                youtubeVideoInfoDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                
                // add one new video to video list
                NSDictionary *videoArray = [youtubeVideoInfoDict objectForKey:@"entry"];
                NSArray* videoTypesArray = [[videoArray objectForKey:@"media$group"] objectForKey:@"media$content"];
                for (NSDictionary* videoType in videoTypesArray) {
                    if ([[videoType objectForKey:@"type"] isEqualToString:@"application/x-shockwave-flash"]) {
                        NSMutableDictionary* videoInformation = [[NSMutableDictionary alloc] init];
                        [videoInformation setObject:[videoType objectForKey:@"url"] forKey:@"url"];
                        [videoInformation setObject:[[[videoArray objectForKey:@"media$group"] objectForKey:@"media$title"] objectForKey:@"$t"] forKey:@"name"];
                        //                [videoInformation setObject:[[[[[youtubeFavsDict objectForKey:@"feed"] objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"] forKey:@"uid"];
//                        [self.videoList insertObject:videoInformation atIndex:0];
//                        [self.tableView reloadData];
                        break;
                    }
                }
            }
            [self.currentConnections removeObjectForKey:connection.description];
            NSLog(@"current connections includes %@",self.currentConnections);
        }
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get favorites from all ambassadors
    NSMutableSet *youtubeAmbassadors = [NSMutableSet setWithObjects:@"kimikul",@"mlgao",@"andyjiang",nil];
    [self getFavoritesFromAmbassadors:youtubeAmbassadors];
    
    // call youtube api to get my hash for my realtime activity feed
//    [self getMyActivityStreamHash];

    // get updates in past 5 minutes
//    [self getSupStream];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.videoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YouTubeCell";
    YouTubeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary* currentVideo = [self.videoList objectAtIndex:indexPath.row];
    cell.nameOfVideo.text = [currentVideo objectForKey:@"name"];
    
    if ([[currentVideo objectForKey:@"activity"] isEqualToString:@"favorited"]) {
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ favorited a video",[currentVideo objectForKey:@"uid"]];
    } else if ([[currentVideo objectForKey:@"activity"] isEqualToString:@"liked"]) {
        cell.favoritedBy.text = [NSString stringWithFormat:@"%@ liked a video",[currentVideo objectForKey:@"uid"]];
    }
    
    if ([[currentVideo objectForKey:@"uid"] isEqualToString:@"mlgao"]) {
        cell.profilePic.image = [UIImage imageNamed:@"gao-rounded-corners.png"];
    } else if ([[currentVideo objectForKey:@"uid"] isEqualToString:@"kimikul"]) {
        cell.profilePic.image = [UIImage imageNamed:@"hsiao-rounded-corners.png"];
    }
    
    cell.date.text = [self timeElapsed:[currentVideo objectForKey:@"date"]];
//    NSString *htmlString = [NSString stringWithFormat:@"<html><head>"
//                            "<meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 90\"/></head>"
//                            "<body style=\"background:#F00;margin-top:0px;margin-left:0px\">"
//                            "<div><object width=\"90\" height=\"60\">"
//                            "<param name=\"movie\" value=\"%@\"></param>"
//                            "<param name=\"wmode\" value=\"transparent\"></param>"
//                            "<embed src=\"%@\""
//                            "type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"90\" height=\"60\"></embed>"
//                            "</object></div></body></html>",[currentVideo objectForKey:@"url"],[currentVideo objectForKey:@"url"]];
    
//    [cell.youtubeThumbnailWebView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.your-url.com"]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return VIDEOTABLEROWHEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* videoURL = [[self.videoList objectAtIndex:indexPath.row] objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:videoURL]];
}

@end
