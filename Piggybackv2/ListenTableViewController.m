//
//  ListenTableViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ListenTableViewController.h"
#import "CocoaLibSpotify.h"
#import "ListenCell.h"
#import "Constants.h"
#import "SongViewController.h"
#import "AppDelegate.h"

@interface ListenTableViewController ()

@property (nonatomic, strong) SPToplist *topList;
@property (nonatomic, strong) NSArray *topTracks;

@end

@implementation ListenTableViewController

@synthesize topList = _topList;
@synthesize topTracks = _topTracks;

#pragma mark - Getters & Setters
-(NSArray *)topTracks {
    if (!_topTracks) {
        _topTracks = [[NSArray alloc] init];
    }
    
    return _topTracks;
}

-(void)setTopTracks:(NSArray *)topTracks {
    if (_topTracks != topTracks) {
        _topTracks = topTracks;
        [self.tableView reloadData];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"topList.tracks"]) {
        NSLog(@"peter's top tracks: %@", self.topList.tracks);
        self.topTracks = self.topList.tracks;
    }
}

- (void)getFriendsTopTracks {
    [SPUser userWithURL:[NSURL URLWithString:@"spotify:user:facebook:1230930066"] inSession:[SPSession sharedSession] callback:^(SPUser *user) {
        NSLog(@"user: %@", user);
    }];
    [[SPSession sharedSession] userForURL:[NSURL URLWithString:@"spotify:user:lemikegao"] callback:^(SPUser *user) {
        NSLog(@"user: %@", user);
    }];
//    self.topList = [SPToplist toplistForUserWithName:@"ptpells" inSession:[SPSession sharedSession]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addObserver:self forKeyPath:@"topList.tracks" options:0 context:nil];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.topTracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listenCell";
    ListenCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.trackDetails.text = [NSString stringWithFormat:@"\"%@\" - %@", [[self.topTracks objectAtIndex:indexPath.row] name], [[[[self.topTracks objectAtIndex:indexPath.row] artists] valueForKey:@"name"] componentsJoinedByString:@","]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return VIDEOTABLEROWHEIGHT;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"musicToSong"]) {
        [segue.destinationViewController setTrack:[self.topTracks objectAtIndex:[self.tableView indexPathForCell:sender].row]];
        [segue.destinationViewController setPlaybackManager:[(AppDelegate *)[[UIApplication sharedApplication] delegate] playbackManager]];
    }
}

@end
