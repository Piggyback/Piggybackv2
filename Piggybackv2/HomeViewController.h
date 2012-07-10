//
//  HomeViewController.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/10/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *placesFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *musicFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *videosFilterButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
