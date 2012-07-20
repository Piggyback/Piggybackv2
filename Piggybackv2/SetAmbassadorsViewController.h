//
//  SetAmbassadorsViewController.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetAmbassadorCell.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface SetAmbassadorsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SetAmbassadorDelegate, RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)readyButton:(id)sender;
- (void)reloadFriendsList;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
