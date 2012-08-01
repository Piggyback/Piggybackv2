//
//  HomeSquareTableCell.h
//  Piggybackv2
//
//  Created by Kimberly Hsiao on 7/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@protocol HomeTableCellDelegate

//- (void)clickFollow:(PBFriend*)friend forType:(NSString*)type;
#warning - continue here

@end

@interface HomeSquareTableCell : UITableViewCell <RKRequestDelegate>

@property (nonatomic, weak) IBOutlet UILabel* nameOfItem;
@property (nonatomic, weak) IBOutlet UILabel* favoritedBy;
@property (nonatomic, weak) IBOutlet UIImageView* profilePic;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UIButton* heart;
@property (nonatomic, weak) IBOutlet UIButton* todo;
@property (nonatomic, weak) IBOutlet UIImageView* icon;
@property (nonatomic, weak) IBOutlet UIImageView* mainPic;
@property (nonatomic, strong) NSString* mediaType;
@property (nonatomic, weak) id<HomeTableCellDelegate> homeTableCellDelegate;

- (IBAction)heart:(id)sender;
- (IBAction)todo:(id)sender;

@end
