//
//  NewsViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 7/19/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "NewsViewController.h"

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
- (void)loadData {
    // load the object model via RestKit
//    NSString *newsPath = [[RKObjectManager sharedManager] get
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"objects from news feed are %@",objects);
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
    return 1;
//    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newsTableCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = @"test";
    
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
