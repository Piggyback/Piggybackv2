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

- (void)addPlacesTodo:(PBPlacesActivity*)placesActivity;
- (void)removePlacesTodo:(PBPlacesActivity*)placesActivity;
- (void)addPlacesLike:(PBPlacesActivity*)placesActivity;
- (void)removePlacesLike:(PBPlacesActivity*)placesActivity;

@end

@interface HomePlacesCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameOfItem;
@property (nonatomic, weak) IBOutlet UILabel* favoritedBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UIImageView* icon;
@property (weak, nonatomic) IBOutlet UIImageView *mainPic;
@property (nonatomic, strong) PBPlacesActivity *placesActivity;
@property (nonatomic, weak) id<HomePlacesCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *heart;
@property (weak, nonatomic) IBOutlet UIButton *todo;

@end
