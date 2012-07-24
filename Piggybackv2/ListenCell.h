//
//  ListenCell.h
//  Piggybackv2
//
//  Created by Michael Gao on 6/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListenCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *activity;
@property (nonatomic, weak) IBOutlet UILabel *action;
@property (nonatomic, weak) IBOutlet UIImageView *profilePic;
@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (nonatomic, weak) IBOutlet UIButton* heart;
@property (nonatomic, weak) IBOutlet UIButton* todo;

- (IBAction)heart:(id)sender;
- (IBAction)todo:(id)sender;

@end
