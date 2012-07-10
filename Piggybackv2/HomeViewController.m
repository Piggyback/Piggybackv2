//
//  HomeViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "HomeTableCell.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableSet* selectedFilters;
@end

@implementation HomeViewController

@synthesize musicFilterButton = _musicFilterButton;
@synthesize videosFilterButton = _videosFilterButton;
@synthesize tableView = _tableView;
@synthesize placesFilterButton = _placesFilterButton;
@synthesize selectedFilters = _selectedFilters;

#pragma mark - setters and getters 

- (NSMutableSet*)selectedFilters {
    if (!_selectedFilters) {
        _selectedFilters = [[NSMutableSet alloc] init];
    }
    return _selectedFilters;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
//    return [self.displayFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"homeTableCell";
    HomeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
//    return SETAMBASSADORSROWHEIGHT;
    return 50;
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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setPlacesFilterButton:nil];
    [self setMusicFilterButton:nil];
    [self setVideosFilterButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ib action methods

- (IBAction)clickPlacesButton:(id)sender {
    if ([self.selectedFilters containsObject:@"places"]) {
        [self.placesFilterButton setImage:[UIImage imageNamed:@"media-filter-places-button-normal"] forState:UIControlStateNormal];
        [self.selectedFilters removeObject:@"places"];
    } else {
        [self.placesFilterButton setImage:[UIImage imageNamed:@"media-filter-places-button-active"] forState:UIControlStateNormal];
        [self.selectedFilters addObject:@"places"];
    }
}

- (IBAction)clickMusicButton:(id)sender {
    
}

- (IBAction)clickVideosButton:(id)sender {
    
}

@end
