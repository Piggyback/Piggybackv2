//
//  HomeSquareTableCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBMusicActivity.h"

@protocol HomeMusicCellDelegate

- (void)addMusicTodo:(PBMusicActivity*)musicActivity;

@end

@interface HomeMusicCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameOfItem;
@property (nonatomic, weak) IBOutlet UILabel* favoritedBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UIButton* heart;
@property (nonatomic, weak) IBOutlet UIButton* todo;
@property (nonatomic, weak) IBOutlet UIImageView* icon;
@property (nonatomic, weak) IBOutlet UIImageView* mainPic;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) NSString* spotifyURL;
@property (nonatomic, strong) PBMusicActivity *musicActivity;
@property (nonatomic, weak) id<HomeMusicCellDelegate> delegate;

- (IBAction)heart:(id)sender;
- (IBAction)todo:(id)sender;
- (IBAction)clickPlay:(id)sender;

@end
