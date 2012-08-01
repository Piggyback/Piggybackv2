//
//  SetAmbassadorsViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SetAmbassadorsViewController.h"
#import "Constants.h"
#import "PBFriend.h"
#import <QuartzCore/QuartzCore.h>
#import "PBUser.h"
#import "PiggybackTabBarController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface SetAmbassadorsViewController ()
@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, strong) NSArray *displayFriends;
@property (nonatomic, strong) NSMutableSet *selectedMusicAmbassadorIndexes;
@property (nonatomic, strong) NSMutableSet *selectedPlacesAmbassadorIndexes;
@property (nonatomic, strong) NSMutableSet *selectedVideosAmbassadorIndexes;
@end

@implementation SetAmbassadorsViewController
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize friends = _friends;
@synthesize displayFriends = _displayFriends;
@synthesize selectedMusicAmbassadorIndexes = _selectedMusicAmbassadorIndexes;
@synthesize selectedPlacesAmbassadorIndexes = _selectedPlacesAmbassadorIndexes;
@synthesize selectedVideosAmbassadorIndexes = _selectedVideosAmbassadorIndexes;

#pragma mark - setters and getters

- (NSArray*)friends {
    if (!_friends) {
        _friends = [[NSArray alloc] init];
    }
    return _friends;
}

- (void)setDisplayFriends:(NSArray *)displayFriends {
    _displayFriends = displayFriends;
    [self.tableView reloadData];
}

- (NSMutableSet*)selectedMusicAmbassadorIndexes {
    if (!_selectedMusicAmbassadorIndexes) {
        _selectedMusicAmbassadorIndexes = [[NSMutableSet alloc] init];
    }
    return _selectedMusicAmbassadorIndexes;
}

- (NSMutableSet*)selectedPlacesAmbassadorIndexes {
    if (!_selectedPlacesAmbassadorIndexes) {
        _selectedPlacesAmbassadorIndexes = [[NSMutableSet alloc] init];
    }
    return _selectedPlacesAmbassadorIndexes;
}

- (NSMutableSet*)selectedVideosAmbassadorIndexes {
    if (!_selectedVideosAmbassadorIndexes) {
        _selectedVideosAmbassadorIndexes = [[NSMutableSet alloc] init];
    }
    return _selectedVideosAmbassadorIndexes;
}

#pragma mark - private methods

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - SetAmbassadorDelegate methods

- (void)setAmbassador:(PBFriend*)friend ForType:(NSString *)type {
    // get me
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSPredicate *getMyUserPredicate = [NSPredicate predicateWithFormat:@"uid = %@",[defaults objectForKey:@"UID"]];
    PBUser *me = [PBUser objectWithPredicate:getMyUserPredicate];
    NSLog(@" i am %@ ", me);
    
    // check if user exists already
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbId = %@",friend.fbId];
    PBUser *friendUser = [PBUser objectWithPredicate:userPredicate];
    
    // if user does not exist, add user
    if (!friendUser) {
        PBUser *newUser = [PBUser object];
        newUser.fbId = [NSNumber numberWithLongLong:[friend.fbId longLongValue]];
        newUser.email = friend.email;
        newUser.firstName = friend.firstName;
        newUser.lastName = friend.lastName;
        newUser.spotifyUsername = friend.spotifyUsername;
        newUser.youtubeUsername = friend.youtubeUsername;
        newUser.foursquareId = friend.foursquareId;
        newUser.isPiggybackUser = [NSNumber numberWithBool:NO];
        
        if ([newUser.firstName isEqualToString:@"Haines"]) {
            newUser.youtubeUsername = @"NerdsInNewYork";
        } else if ([newUser.firstName isEqualToString:@"Lianna"]) {
            newUser.youtubeUsername = @"mlgao";
        }
        
        // add user and add ambassador
        [[RKObjectManager sharedManager] postObject:newUser usingBlock:^(RKObjectLoader* loader) {
            loader.onDidLoadObjects = ^(NSArray* objects) {
                if ([type isEqualToString:@"music"]) {
                    [newUser addMusicFollowersObject:me];
                    
                    // add ambassador to db
                    // [[RKObjectManager sharedManager] postObject:newAmbassador delegate:self];
                    
                } else if ([type isEqualToString:@"places"]) {
                    [newUser addPlacesFollowersObject:me];
                    
                    // add ambassador to db
                    // [[RKObjectManager sharedManager] postObject:newAmbassador delegate:self];
                } else if ([type isEqualToString:@"videos"]) {
                    [newUser addVideosFollowersObject:me];
                    
                    // add ambassador to db
                    // [[RKObjectManager sharedManager] postObject:newAmbassador delegate:self];
                }
                
                if (!friend.thumbnail) {
                    NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",newUser.fbId];
                    newUser.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
                    [[RKObjectManager sharedManager].objectStore save:nil];
                } else {
                    newUser.thumbnail = friend.thumbnail;
                    [[RKObjectManager sharedManager].objectStore save:nil];
                }
                
                NSLog(@"me is %@",me);
                NSLog(@"new user is %@",newUser);
            };
        }];
    } 
    
    // user exists already, only update ambassador table
    else {
        
        // if ambassador does not exist yet, add ambassador
        if ([type isEqualToString:@"music"]) {
            if (![friendUser.musicFollowers containsObject:me]) {
                [friendUser addMusicFollowersObject:me];
                
                // add ambassador to db
            }
        } else if ([type isEqualToString:@"places"]) {
            if (![friendUser.placesFollowers containsObject:me]) {
                [friendUser addPlacesFollowersObject:me];
                
                // add ambassador to db
            }
        } else if ([type isEqualToString:@"videos"]) {
            if (![friendUser.videosFollowers containsObject:me]) {
                [friendUser addVideosFollowersObject:me];
                
                // add ambassador to db
            }
        }
            
        NSLog(@"user is %@",friendUser);
        NSLog(@"i am %@",me);
    }
}

- (void)removeAmbassador:(PBFriend*)friend ForType:(NSString*)type {
    // get me
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSPredicate *getMyUserPredicate = [NSPredicate predicateWithFormat:@"uid = %@",[defaults objectForKey:@"UID"]];
    PBUser *me = [PBUser objectWithPredicate:getMyUserPredicate];
    
    // fetch user from friend
    NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"fbId = %@",friend.fbId];
    PBUser* removedUser = [PBUser objectWithPredicate:userPredicate];
    
    if (removedUser) {
        if ([type isEqualToString:@"music"]) {
            // remove ambassador linkage from core data
            [me removeMusicAmbassadorsObject:removedUser];
            
            // remove ambassador from database
        } else if ([type isEqualToString:@"places"]) {
            // remove ambassador linkage from core data
            [me removePlacesAmbassadorsObject:removedUser];
            
            // remove ambassador from database
        } else if ([type isEqualToString:@"videos"]) {
            
        }
    
        // if removed user has no other followers and is not my follower, remove user from core data
        int count = [removedUser.musicFollowers count] + [removedUser.placesFollowers count];
        if (count == 0 && ![removedUser.placesAmbassadors containsObject:me] && ![removedUser.musicAmbassadors containsObject:me]) {
            RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
            [[objectStore managedObjectContextForCurrentThread] deleteObject:removedUser];
            [objectStore save:nil];
        }
    
        NSLog(@"i am %@",me);
        NSLog(@"removed user is %@",removedUser);
    }
}

- (void)clickFollow:(PBFriend*)friend forType:(NSString*)type {
    NSMutableSet* ambassadors = [[NSMutableSet alloc] init];
    if ([type isEqualToString:@"music"]) {
        ambassadors = self.selectedMusicAmbassadorIndexes;
    } else if ([type isEqualToString:@"places"]) {
        ambassadors = self.selectedPlacesAmbassadorIndexes;
    } else if ([type isEqualToString:@"videos"]) {
        ambassadors = self.selectedVideosAmbassadorIndexes;
    }

    if ([ambassadors containsObject:friend.fbId]) {
        [ambassadors removeObject:friend.fbId];
        [self removeAmbassador:friend ForType:type];
        for (NSIndexPath* indexPath in [self.tableView indexPathsForVisibleRows]) {
            if ([(SetAmbassadorCell*)[self.tableView cellForRowAtIndexPath:indexPath] friend] == friend) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    } else {
        [ambassadors addObject:friend.fbId];
        [self setAmbassador:friend ForType:type];
        for (NSIndexPath* indexPath in [self.tableView indexPathsForVisibleRows]) {
            if ([(SetAmbassadorCell*)[self.tableView cellForRowAtIndexPath:indexPath] friend] == friend) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"objects from user insert are %@",objects);
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"restkit failed with error from setting ambassador");
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    NSLog(@"Retrieved JSON2: %@", [response bodyAsString]);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"setAmbassadorCell";
    SetAmbassadorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.setAmbassadorDelegate = self;
    
    cell.profilePic.layer.cornerRadius = 5.0;
    cell.profilePic.layer.masksToBounds = YES;
    
    // get current friend and set cell
    NSLog(@"indexrow is %i",indexPath.row);
    PBFriend* friend = [self.displayFriends objectAtIndex:indexPath.row];
    cell.friend = friend;
    cell.name.text = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName];
    cell.profilePic.image = [UIImage imageNamed:@"blankFacebookPhoto.gif"];
    
    // display music button
    if ([self.selectedMusicAmbassadorIndexes containsObject:friend.fbId]) {
        [cell.followMusic setImage:[UIImage imageNamed:@"follow-music-button-pressed"] forState:UIControlStateNormal];
    } else {
        [cell.followMusic setImage:[UIImage imageNamed:@"follow-music-button-normal"] forState:UIControlStateNormal];
    }
    
    // display places button
    if ([self.selectedPlacesAmbassadorIndexes containsObject:friend.fbId]) {
        [cell.followPlaces setImage:[UIImage imageNamed:@"follow-places-button-pressed"] forState:UIControlStateNormal];
    } else {
        [cell.followPlaces setImage:[UIImage imageNamed:@"follow-places-button-normal"] forState:UIControlStateNormal];
    }
    
    // display video button
    if ([self.selectedVideosAmbassadorIndexes containsObject:friend.fbId]) {
        [cell.followVideos setImage:[UIImage imageNamed:@"follow-video-button-pressed"] forState:UIControlStateNormal];
    } else {
        [cell.followVideos setImage:[UIImage imageNamed:@"follow-video-button-normal"] forState:UIControlStateNormal];
    }
    
    // if thumbnail already stored in local friend array, then display thumbnail
    if (friend.thumbnail) {
        cell.profilePic.image = friend.thumbnail;
    } 
    
    // if thumbnail not stored in local friend array, fetch it and store it in core data and local friend array
    else {
        dispatch_queue_t getFriendPicQueue = dispatch_queue_create("storeFriendsInCoreData",NULL);
        dispatch_async(getFriendPicQueue, ^{
            
            // store thumbnail in core data if it is not yet
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fbId = %@) AND (thumbnail == nil)",friend.fbId];
            NSArray *friendArray = [PBFriend objectsWithPredicate:predicate];
            if ([friendArray count] > 0) {
                NSString* thumbnailURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",friend.fbId];
                PBFriend* newFriend = [friendArray objectAtIndex:0];
                newFriend.thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailURL]]];
                [[RKObjectManager sharedManager].objectStore save:nil];
                
                // display thumbnail in tableview
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.profilePic.image = newFriend.thumbnail;
                });
                
                // set thumbnail in local friend array to reflect core data
                if (friend.fbId = newFriend.fbId) {
                    friend.thumbnail = newFriend.thumbnail;
                }
            }
        });
    }
        
//    cell.profilePic.image = friend.thumbnail;

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return SETAMBASSADORSROWHEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - searchbar delegate methods
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    NSMutableArray *lastNameSearchArray = [[NSMutableArray alloc] init];
    BOOL alreadyAdded = NO;
    
    for (PBFriend *currentFriend in self.friends) {
        alreadyAdded = NO;
        NSString *currentFriendName = [NSString stringWithFormat:@"%@ %@", currentFriend.firstName, currentFriend.lastName];
        NSRange range = {0, [searchText length]};
        if ([searchText length] <= [currentFriendName length]) {
            NSRange nameRange = [currentFriendName rangeOfString:searchText options:NSCaseInsensitiveSearch range:range];
        
            if (nameRange.length > 0) {
                [searchArray addObject:currentFriend];
                alreadyAdded = YES;
            }
        }
        
        if ([searchText length] <= [currentFriend.lastName length]) {
            NSRange lastNameRange = [currentFriend.lastName rangeOfString:searchText options:NSCaseInsensitiveSearch range:range];
            if (lastNameRange.length > 0 && !alreadyAdded) {
                [lastNameSearchArray addObject:currentFriend];
            }
        }
    }
    
    [searchArray addObjectsFromArray:lastNameSearchArray];
    
    if (![searchText isEqualToString:@""]) {
        self.displayFriends = searchArray;
    } else {
        self.displayFriends = self.friends;
    }
    
}

#pragma mark - UIScrollViewDelegate protocol methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideKeyboard];
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
    NSLog(@"display friends");
    
    // get me
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSPredicate *getMyUserPredicate = [NSPredicate predicateWithFormat:@"uid = %@",[defaults objectForKey:@"UID"]];
    PBUser *me = [PBUser objectWithPredicate:getMyUserPredicate];
    
    // get my ambassadors and add to array
    if (me) {
        for (PBUser* ambassador in me.musicAmbassadors) {
            [self.selectedMusicAmbassadorIndexes addObject:ambassador.fbId];
        }
    }
    
    // replace keyboard 'Search' button with 'Done'
    for (UIView *searchBarSubview in [self.searchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
                [(UITextField *)searchBarSubview setEnablesReturnKeyAutomatically:NO];
                [(UITextField *)searchBarSubview addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
            }
            @catch (NSException * e) {

            }
        }
    }
    
    [self reloadFriendsList];
}

- (void)reloadFriendsList {
    NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorFirstName,sortDescriptorLastName,nil];
    self.friends = [[PBFriend allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    self.displayFriends = self.friends;
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ib actions

- (IBAction)readyButton:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    HomeViewController* homeViewController = (HomeViewController*)[[[(PiggybackTabBarController*)appDelegate.window.rootViewController viewControllers] objectAtIndex:0] topViewController];
    [homeViewController loadAmbassadorData];
}

@end
