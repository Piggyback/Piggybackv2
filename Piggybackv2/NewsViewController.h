//
//  NewsViewController.h
//  Piggybackv2
//
//  Created by Michael Gao on 7/19/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@interface NewsViewController : UIViewController <RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
