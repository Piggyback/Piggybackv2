//
//  SetAmbassadorCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/5/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBFriend.h"

@protocol SetAmbassadorDelegate

- (void)setAmbassador:(PBFriend*)friend ForType:(NSString*)type;
- (void)removeAmbassador:(PBFriend*)friend ForType:(NSString*)type;

@end

@interface SetAmbassadorCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UIButton* followMusic;
@property (nonatomic, weak) IBOutlet UIButton* followPlaces;
@property (nonatomic, weak) IBOutlet UIButton* followVideos;
@property (nonatomic, strong) PBFriend* friend;
@property (nonatomic, weak) id<SetAmbassadorDelegate> setAmbassadorDelegate;

- (IBAction)clickFollowMusic;
- (IBAction)clickFollowPlaces;
- (IBAction)clickFollowVideos;

@end
