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
@property (nonatomic, strong) NSMutableArray* friends;
@end

@implementation SetAmbassadorsViewController
@synthesize tableView = _tableView;
@synthesize searchText = _searchText;
@synthesize friends = _friends;

#pragma mark - setters and getters

- (NSMutableArray*)friends {
    if (!_friends) {
        _friends = [[NSMutableArray alloc] init];
    }
    return _friends;
}

#pragma mark - private methods

- (void)hideKeyboard {
    [self.searchText resignFirstResponder]; 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"setAmbassadorCell";
    SetAmbassadorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.profilePic.layer.cornerRadius = 5.0;
    cell.profilePic.layer.masksToBounds = YES;
    
    PBFriend* friend = [self.friends objectAtIndex:indexPath.row];
    cell.name.text = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName];
    
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
    
    // hide keyboard when tap outside
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];

    NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorFirstName,sortDescriptorLastName,nil];
    self.friends = [[[PBFriend allObjects] sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchText:nil];
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
