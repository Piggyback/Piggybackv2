//
//  HomePlacesCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/27/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBPlacesActivity.h"

@protocol HomePlacesCellDelegate

- (void)addPlacesFeedback:(PBPlacesActivity*)placesActivity forFeedbackType:(NSString *)feedbackType;
- (void)removePlacesFeedback:(PBPlacesActivity*)placesActivity forFeedbackType:(NSString *)feedbackType;

@end

@interface HomePlacesCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameOfItem;
@property (nonatomic, weak) IBOutlet UILabel* favoritedBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UIButton* heart;
@property (nonatomic, weak) IBOutlet UIButton* todo;
@property (nonatomic, weak) IBOutlet UIImageView* icon;
@property (nonatomic, weak) IBOutlet UIImageView* mainPic;
@property (nonatomic, strong) PBPlacesActivity *placesActivity;
@property (nonatomic, weak) id<HomePlacesCellDelegate> delegate;

- (IBAction)heart:(id)sender;
- (IBAction)todo:(id)sender;

@end
