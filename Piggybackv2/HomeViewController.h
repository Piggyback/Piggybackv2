//
//  HomeViewController.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UIButton *placesFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *musicFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *videosFilterButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)getFriendsTopTracks;

@end
