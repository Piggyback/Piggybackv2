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

@interface ExploreTableViewController ()

@property (nonatomic, strong) BZFoursquareRequest *request;
@property (nonatomic, strong) NSArray *results;

@end

@implementation ExploreTableViewController

@synthesize request = _request;
@synthesize results = _results;

#pragma mark - Getters & Setters
- (void)setResults:(NSArray *)results {
    _results = results;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Public Instance Methods
- (void)getRecentFriendCheckins {
    NSLog(@"getting recent friends checkins...");
    self.request = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] foursquare] requestWithPath:@"checkins/recent" HTTPMethod:@"GET" parameters:nil delegate:self];
    [self.request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    NSLog(@"success: %@", request.response);
    self.results = [request.response objectForKey:@"recent"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
        cell.profilePic.image = [UIImage imageNamed:@""];
    } else if ([fullName isEqualToString:@"Ricky Yean"]) {
        cell.profilePic.image = [UIImage imageNamed:@""];
    } else if ([fullName isEqualToString:@"Sam Olstein"]) {
        cell.profilePic.image = [UIImage imageNamed:@""];
    } else if ([fullName isEqualToString:@"Michael Gao"]) {
        cell.profilePic.image = [UIImage imageNamed:@"gao-rounded-corners"];
    } else if ([fullName isEqualToString:@"Christine Vuong"]) {
        cell.profilePic.image = [UIImage imageNamed:@""];        
    }
    
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
