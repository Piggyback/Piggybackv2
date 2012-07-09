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
#import "PBAmbassador.h"

@interface SetAmbassadorsViewController ()
@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, strong) NSArray *displayFriends;
@end

@implementation SetAmbassadorsViewController
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize friends = _friends;
@synthesize displayFriends = _displayFriends;

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

#pragma mark - private methods

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - SetAmbassadorDelegate methods
- (void)setAmbassador:(PBFriend*)friend ForType:(NSString *)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // check if user exists already
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"fbId = %@",friend.fbId];
    PBUser *friendUser = [PBUser objectWithPredicate:userPredicate];
    
    // if user does not exist, add user
    if (!friendUser) {
        PBUser *newUser = [PBUser object];
        newUser.fbId = [NSNumber numberWithLongLong:[friend.fbId longLongValue]];
        NSLog(@"new user fbid: %@", newUser.fbId);
        newUser.email = friend.email;
        newUser.firstName = friend.firstName;
        newUser.lastName = friend.lastName;
        newUser.spotifyUsername = friend.spotifyUsername;
        newUser.youtubeUsername = friend.youtubeUsername;
        newUser.foursquareId = friend.foursquareId;
        newUser.isPiggybackUser = [NSNumber numberWithBool:NO];
        
        // add user and add ambassador
        [[RKObjectManager sharedManager] postObject:newUser usingBlock:^(RKObjectLoader* loader) {
            loader.onDidLoadObjects = ^(NSArray* objects) {                
                PBAmbassador *newAmbassador = [PBAmbassador object];
                newAmbassador.ambassadorUid = [[objects objectAtIndex:0] uid];
                newAmbassador.followerUid = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];
                newAmbassador.ambassadorType = type;
                
                [[RKObjectManager sharedManager] postObject:newAmbassador delegate:self];
            };
        }];
    } 
    
    // user exists already, only update ambassador table
    else {
        // check if ambassador exists already
        NSNumber *myUID = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];
        NSPredicate* ambassadorPredicate = [NSPredicate predicateWithFormat:@"(followerUid = %@) AND (ambassadorUid = %@) AND (ambassadorType = %@)", myUID, friendUser.uid, type];
        PBAmbassador *addedAmbassador = [PBAmbassador objectWithPredicate:ambassadorPredicate];
        
        // if ambassador does not exist already, add them
        if (!addedAmbassador) {
            PBAmbassador *newAmbassador = [PBAmbassador object];
            newAmbassador.ambassadorUid = friendUser.uid;
            newAmbassador.followerUid = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];
            newAmbassador.ambassadorType = type;
            
            [[RKObjectManager sharedManager] postObject:newAmbassador delegate:self];
        }
    }
}

- (void)removeAmbassador:(PBFriend*)friend ForType:(NSString*)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *myUID = [NSNumber numberWithInt:[[defaults objectForKey:@"UID"] intValue]];

    // fetch user from friend
    NSPredicate* userPredicate = [NSPredicate predicateWithFormat:@"fbId = %@",friend.fbId];
    PBUser* removedUser = [PBUser objectWithPredicate:userPredicate];
    
    //fetch ambassador from user
    NSPredicate* ambassadorPredicate = [NSPredicate predicateWithFormat:@"(followerUid = %@) AND (ambassadorUid = %@) AND (ambassadorType = %@)", myUID, removedUser.uid, type];
    PBAmbassador *removedAmbassador = [PBAmbassador objectWithPredicate:ambassadorPredicate];
    [[RKObjectManager sharedManager] putObject:removedAmbassador usingBlock:^(RKObjectLoader* loader) {
        loader.onDidLoadObjects = ^(NSArray* objects) {
            // delete ambassador row from core data
            RKManagedObjectStore *objectStore = [[RKObjectManager sharedManager] objectStore];
            [[objectStore managedObjectContextForCurrentThread] deleteObject:removedAmbassador];
            [objectStore save:nil];
            NSLog(@"removed ambassador!");  
        };
    }];
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
    
    PBFriend* friend = [self.displayFriends objectAtIndex:indexPath.row];
    cell.name.text = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName];
    cell.profilePic.image = [UIImage imageNamed:@"blankFacebookPhoto.gif"];
    cell.friend = friend;
    
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

    NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorFirstName,sortDescriptorLastName,nil];
    self.friends = [[PBFriend allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    self.displayFriends = self.friends;
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
}

@end
