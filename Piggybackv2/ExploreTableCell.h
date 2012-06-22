//
//  ExploreTableCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExploreTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameOfPlace;
@property (nonatomic, weak) IBOutlet UILabel* checkedInBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UIButton* heart;
@property (nonatomic, weak) IBOutlet UIButton* todo;

- (IBAction)heart:(id)sender;
- (IBAction)todo:(id)sender;

@end
