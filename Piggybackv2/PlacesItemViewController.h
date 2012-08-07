//
//  PlacesItemViewController.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 8/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBPlacesItem.h"

@interface PlacesItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PBPlacesItem *placesItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *vendorTableView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *photoPageControl;

@end
