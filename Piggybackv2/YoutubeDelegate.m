//
//  YoutubeDelegate.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/25/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "YoutubeDelegate.h"
#import "PBUser.h"

@interface YoutubeDelegate ()
@property (nonatomic, strong) NSMutableDictionary* currentConnections;
@end

@implementation YoutubeDelegate

@synthesize delegate = _delegate;
@synthesize currentConnections = _currentConnections;

#pragma mark - getters and setters

- (NSMutableDictionary*)currentConnections {
    if (!_currentConnections) {
        _currentConnections = [[NSMutableDictionary alloc] init];
    }
    return _currentConnections;
}

#pragma mark - public methods

-(void)getAmbassadorsFavoriteVideos:(NSMutableSet*)videosAmbassadors {
    NSString* userNames = @"";
//    for (PBUser* ambassador in videosAmbassadors) {
//        userNames = [NSString stringWithFormat:@"%@,%@",userNames,ambassador.youtubeUsername];
//    }
    
    for (PBUser* ambassador in videosAmbassadors) {
        if ([ambassador.firstName isEqualToString:@"Haines"]) {
            userNames = [NSString stringWithFormat:@"%@,%@",userNames,@"NerdsInNewYork"];
        } else if ([ambassador.firstName isEqualToString:@"Michael"]) {
            userNames = [NSString stringWithFormat:@"%@,%@",userNames,@"mlgao"];
        } else if ([ambassador.lastName isEqualToString:@"Hsiao"]) {
            userNames = [NSString stringWithFormat:@"%@,%@",userNames,@"kimikul"];
        }
    }
    
    if (![userNames isEqualToString:@""]) {
        userNames = [userNames substringWithRange:NSMakeRange(1,[userNames length]-1)];
    }
    
    NSLog(@"usernames are %@",userNames);
    
    NSString* newVideosQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/events?v=2&author=%@&key=AI39si67YD40HCVtvnAj--EzmTmuFjZCzIYHskBFuRa6jf1KWkbSK_3TpQDLRIJfcNeT4UiGB1eLWz6KjUN3SPn02feOfLt19w&alt=json",userNames];
    
    NSURLRequest *newVideosRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newVideosQuery]];
    NSURLConnection *newVideosConnection = [[NSURLConnection alloc] initWithRequest:newVideosRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"initialFavorites" forKey:@"userInfo"];
    [self.currentConnections setObject:connectionInfo forKey:newVideosConnection.description];
}

#pragma mark - private helper methods

- (void)getInfoForInitialVideo:(NSString*)videoID forUser:(NSString*)youtubeUsername forDate:(NSString*)date forActivity:(NSString*)activity {
    NSString *videoInfoQuery = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=json",videoID];
    NSURLRequest *videoInfoRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:videoInfoQuery]];
    NSURLConnection *videoInfoConnection = [[NSURLConnection alloc] initWithRequest:videoInfoRequest delegate:self];
    NSMutableDictionary* connectionInfo = [[NSMutableDictionary alloc] init];
    [connectionInfo setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
    [connectionInfo setObject:@"initialVideoInfo" forKey:@"userInfo"];
    [connectionInfo setObject:youtubeUsername forKey:@"youtubeUsername"];
    [connectionInfo setObject:date forKey:@"date"];
    [connectionInfo setObject:activity forKey:@"activity"];
    [self.currentConnections setObject:connectionInfo forKey:videoInfoConnection.description];
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
                NSDictionary *youtubeVideoInfoDict = [NSJSONSerialization JSONObjectWithData:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"responseData"] options:NSJSONWritingPrettyPrinted error:&error];
                
                // add one new video to video list
                NSDictionary *videoArray = [youtubeVideoInfoDict objectForKey:@"entry"];
                NSArray* videoTypesArray = [[videoArray objectForKey:@"media$group"] objectForKey:@"media$content"];
                NSArray* thumbnailTypesArray = [[videoArray objectForKey:@"media$group"] objectForKey:@"media$thumbnail"];
                
                // initialize return dictionary
                NSMutableDictionary* videoInformation = [[NSMutableDictionary alloc] init];
                
                // get thumbnail
                for (NSDictionary* thumbnailType in thumbnailTypesArray) {
                    if ([[thumbnailType objectForKey:@"width"] isEqualToNumber:[NSNumber numberWithInt:480]]) {
                        [videoInformation setObject:[thumbnailType objectForKey:@"url"] forKey:@"thumbnailURL"];
                    }
                }
                
                // get video url
                for (NSDictionary* videoType in videoTypesArray) {
                    if ([[videoType objectForKey:@"type"] isEqualToString:@"application/x-shockwave-flash"]) {
                        [videoInformation setObject:[videoType objectForKey:@"url"] forKey:@"url"];
                        [videoInformation setObject:[[[videoArray objectForKey:@"media$group"] objectForKey:@"media$title"] objectForKey:@"$t"] forKey:@"name"];
                        [videoInformation setObject:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"youtubeUsername"] forKey:@"youtubeUsername"];
                        [videoInformation setObject:[[self.currentConnections objectForKey:currentConnection] objectForKey:@"activity"] forKey:@"activity"];
                        
                        // convert date string to nsdate
                        NSString *formattedString = [[[self.currentConnections objectForKey:currentConnection] objectForKey:@"date"] stringByReplacingOccurrencesOfString:@"T" withString:@""];
                        formattedString = [formattedString stringByReplacingCharactersInRange:NSMakeRange(18, 5) withString:@""];
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
                        NSDate *date = [df dateFromString: formattedString];
                        [videoInformation setObject:date forKey:@"date"];
                        [self.delegate updateFavoriteVideos:videoInformation];
                        NSLog(@"video information is %@",videoInformation);
                        break;
                    }
                }
                
//                self.videoList = [[self.videoList sortedArrayUsingComparator: ^(NSDictionary* a, NSDictionary* b) {
//                    NSComparisonResult result = [[b objectForKey:@"date"] compare:[a objectForKey:@"date"]];
//                    return result;
//                }] mutableCopy];
            }
                        
            [self.currentConnections removeObjectForKey:connection.description];
        }
    }
}

@end
