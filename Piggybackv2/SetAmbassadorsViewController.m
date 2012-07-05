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

@interface SetAmbassadorsViewController ()
@property (nonatomic, strong) NSArray* friends;
@end

@implementation SetAmbassadorsViewController
@synthesize tableView = _tableView;
@synthesize friends = _friends;

#pragma mark - setters and getters

- (NSArray*)friends {
    if (!_friends) {
        _friends = [[NSArray alloc] init];
    }
    return _friends;
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
    
    PBFriend* friend = [self.friends objectAtIndex:indexPath.row];
    cell.name.text = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return VIDEOTABLEROWHEIGHT;
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
//    self.friends = [PBFriend objectsWithPredicate:nil];
//    [self.tableView reloadData];
//    NSLog(@"friends are %@",self.friends);
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ib actions

- (IBAction)readyButton:(id)sender {
    self.friends = [PBFriend allObjects];
    [self.tableView reloadData];
    NSLog(@"friends are %@",self.friends);
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
