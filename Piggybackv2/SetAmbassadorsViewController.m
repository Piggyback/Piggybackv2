//
//  SetAmbassadorsViewController.m
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SetAmbassadorsViewController.h"
#import "SetAmbassadorCell.h"
#import "Constants.h"
#import "PBFriend.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import <QuartzCore/QuartzCore.h>

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
    
    cell.profilePic.layer.cornerRadius = 5.0;
    cell.profilePic.layer.masksToBounds = YES;
    
    PBFriend* friend = [self.displayFriends objectAtIndex:indexPath.row];
    cell.name.text = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName];
    cell.profilePic.image = [UIImage imageNamed:@"blankFacebookPhoto.gif"];
    
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
