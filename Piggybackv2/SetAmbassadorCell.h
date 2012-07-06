//
//  SetAmbassadorCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetAmbassadorCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UIButton* followMusic;
@property (nonatomic, weak) IBOutlet UIButton* followPlaces;
@property (nonatomic, weak) IBOutlet UIButton* followVideos;

- (IBAction)clickFollowMusic;
- (IBAction)clickFollowPlaces;
- (IBAction)clickFollowVideos;

@end
