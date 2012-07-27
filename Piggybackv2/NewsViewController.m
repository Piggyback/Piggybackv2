//
//  NewsViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 7/19/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "NewsViewController.h"
#import "PBMusicNews.h"
#import "PBUser.h"
#import "PBMusicActivity.h"
#import "PBMusicItem.h"

@interface NewsViewController ()

@property (nonatomic, strong) NSArray *newsToDisplay;

@end

@implementation NewsViewController

@synthesize tableView;
@synthesize newsToDisplay = _newsToDisplay;

#pragma mark - Getters & Setters
- (void)setNewsToDisplay:(NSArray *)newsToDisplay {
    if (_newsToDisplay != newsToDisplay) {
        _newsToDisplay = newsToDisplay;
        [self.tableView reloadData];
    }
}

#pragma mark - Private helper methods
- (void)loadObjectsFromDataStore {
    NSFetchRequest* request = [PBMusicNews fetchRequest];
//    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"referralDate" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    self.newsToDisplay = [PBMusicNews objectsWithFetchRequest:request];
}

- (void)loadData {
    // load the object model via RestKit
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectMapping *responseMapping = (RKObjectMapping*)[objManager.mappingProvider mappingForKeyPath:@"PBMusicActivity"];
    
    [objManager loadObjectsAtResourcePath:@"/news" usingBlock:^(RKObjectLoader *loader) {
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PBMusicNews *newsItem = [self.newsToDisplay objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@", newsItem.follower.firstName, newsItem.newsActionType, newsItem.musicActivity.musicItem.songTitle];
    
    return cell;
}

//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
//{
//    return HOMETABLEROWHEIGHT;
//}

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
