//
//  HomeVideosCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBVideosActivity.h"

@protocol HomeVideosCellDelegate

- (void)addVideosFeedback:(PBVideosActivity*)videosActivity forFeedbackType:(NSString *)feedbackType;
- (void)removeVideosFeedback:(PBVideosActivity*)videosActivity forFeedbackType:(NSString *)feedbackType;

@end

@interface HomeVideosCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameOfItem;
@property (nonatomic, weak) IBOutlet UILabel* favoritedBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UIImageView* icon;
@property (weak, nonatomic) IBOutlet UIButton *heart;
@property (weak, nonatomic) IBOutlet UIButton *todo;
@property (nonatomic, strong) PBVideosActivity *videosActivity;
@property (nonatomic, weak) id<HomeVideosCellDelegate> delegate;

- (IBAction)heart:(id)sender;
- (IBAction)todo:(id)sender;


@end
