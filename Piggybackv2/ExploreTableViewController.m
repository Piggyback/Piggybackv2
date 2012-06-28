//
//  ExploreTableViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ExploreTableViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ExploreTableCell.h"
#import "PBFriend.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface ExploreTableViewController ()

@property (nonatomic, strong) BZFoursquareRequest *request;
@property (nonatomic, strong) NSArray *results;
@property int requestType;

@end

@implementation ExploreTableViewController

@synthesize request = _request;
@synthesize results = _results;
@synthesize requestType = _requestType;

#pragma mark - Getters & Setters
- (void)setResults:(NSArray *)results {
    _results = results;
    [self.tableView reloadData];
}

#pragma mark - private helper functions

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

#pragma mark -
#pragma mark - Public Instance Methods
- (void)getRecentFriendCheckins {
    NSLog(@"getting recent friends checkins...");
    self.request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:@"checkins/recent" HTTPMethod:@"GET" parameters:nil delegate:self];
    self.requestType = fsAPIGetRecentCheckins;
    [self.request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)getFoursquareFriends {
    self.request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:@"users/self/friends" HTTPMethod:@"GET" parameters:nil delegate:self];
    self.requestType = fsAPIGetFriends;
    [self.request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    NSLog(@"success: %@", request.response);
    if (self.requestType == fsAPIGetRecentCheckins) {
        self.results = [request.response objectForKey:@"recent"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else if (self.requestType == fsAPIGetFriends) {
        // link foursquare id's with friends and store in friends db
        NSArray* foursquareFriends = [[request.response objectForKey:@"friends"] objectForKey:@"items"];
        for (NSDictionary* foursquareFriend in foursquareFriends) {
            if ([[foursquareFriend objectForKey:@"contact"] objectForKey:@"facebook"]) {
                
                // add foursquare acct to friend based on fbid match
                NSLog(@"fb id is %@",[[foursquareFriend objectForKey:@"contact"] objectForKey:@"facebook"]);
                NSLog(@"foursquare id that matches is %@",[foursquareFriend objectForKey:@"id"]);
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbid = %@",[NSNumber numberWithLongLong:[[[foursquareFriend objectForKey:@"contact"] objectForKey:@"facebook"] longLongValue]]];
                NSArray *friendArray = [PBFriend objectsWithPredicate:predicate];
                if ([friendArray count] > 0) {
                    PBFriend *friend = [friendArray objectAtIndex:0];
                    [friend setValue:[NSNumber numberWithLong:[[foursquareFriend objectForKey:@"id"] intValue]] forKey:@"foursquareId"];
                }

                // add foursquare acct to friend based on email match
            }
        }
        
        [[RKObjectManager sharedManager].objectStore save:nil];

    }
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"failure: %@", error);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark - View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"explore view did load");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"explore view did unload");
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    NSLog(@"explore view did dealloc");
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
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"exploreCell";
    ExploreTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.nameOfPlace.text = [[[self.results objectAtIndex:indexPath.row] objectForKey:@"venue"] objectForKey:@"name"];
    
    NSString* fullName = [NSString stringWithFormat:@"%@ %@",[[[self.results objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"firstName"],[[[self.results objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"lastName"]];
    cell.checkedInBy.text = [NSString stringWithFormat:@"%@ checked in to",fullName];
    
    if ([fullName isEqualToString:@"Matthew Harrison"]) {
        cell.profilePic.image = [UIImage imageNamed:@"harrison-rounded-corners"];
    } else if ([fullName isEqualToString:@"Andy Jiang"]) {
        cell.profilePic.image = [UIImage imageNamed:@"jiang-rounded-corners"];
    } else if ([fullName isEqualToString:@"Kim H"]) {
        cell.profilePic.image = [UIImage imageNamed:@"hsiao-rounded-corners"];
    } else if ([fullName isEqualToString:@"Joshua Lu"]) {
        cell.profilePic.image = [UIImage imageNamed:@"josh-lu-rounded-corners"];
    } else if ([fullName isEqualToString:@"Ricky Yean"]) {
        cell.profilePic.image = [UIImage imageNamed:@"yean-rounded-corners"];
    } else if ([fullName isEqualToString:@"Sam Olstein"]) {
        cell.profilePic.image = [UIImage imageNamed:@"olstein-rounded-corners"];
    } else if ([fullName isEqualToString:@"Michael Gao"]) {
        cell.profilePic.image = [UIImage imageNamed:@"gao-rounded-corners"];
    }
    
    NSString* epochTime = [[self.results objectAtIndex:indexPath.row] objectForKey:@"createdAt"];
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:[epochTime doubleValue]];
    cell.date.text = [self timeElapsed:epochNSDate];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return VIDEOTABLEROWHEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
